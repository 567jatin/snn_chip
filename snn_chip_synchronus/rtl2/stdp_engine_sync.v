`timescale 1ns / 1ps

// Clocked, single-pair STDP update engine. The top-level scanner supplies one
// pre/post pair per request and holds the request until acknowledge.
module stdp_engine_sync #(
    parameter NUM_NEURONS = 64,
    parameter N_BITS      = 6,
    parameter DW          = 16,
    parameter TW          = 16,
    parameter W_ADDR_W    = 12,
    parameter [TW-1:0] T_WINDOW = 16'd64,
    parameter [DW-1:0] A_POS = 16'd100,
    parameter [DW-1:0] A_NEG = 16'd80,
    parameter [DW-1:0] W_MIN = 16'd0,
    parameter [DW-1:0] W_MAX = 16'd32767,
    parameter integer DECAY_SHIFT = 2
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 spike_req,
    output wire                 spike_ack,
    input  wire                 spike_is_post,
    input  wire [N_BITS-1:0]    spike_pre_id,
    input  wire [N_BITS-1:0]    spike_post_id,
    input  wire [TW-1:0]        event_time,

    output wire                 w_rd_en,
    output wire [W_ADDR_W-1:0]  w_rd_addr,
    input  wire [DW-1:0]        w_rd_data,
    output wire                 w_wr_en,
    output wire [W_ADDR_W-1:0]  w_wr_addr,
    output reg  [DW-1:0]        w_wr_data,
    input  wire                 w_rd_ready,
    input  wire                 w_wr_ready
);
    localparam IDLE      = 3'd0;
    localparam PREPARE   = 3'd1;
    localparam READ_REQ  = 3'd2;
    localparam READ_WAIT = 3'd3;
    localparam WRITE     = 3'd4;
    localparam ACK       = 3'd5;
    localparam READ_USE  = 3'd6;

    reg [2:0] state;
    reg lat_is_post;
    reg [TW-1:0] lat_dt;
    reg [W_ADDR_W-1:0] lat_waddr;
    reg trace_valid;
    reg [DW-1:0] delta_w;

    reg [TW-1:0] pre_trace [0:NUM_NEURONS-1];
    reg [TW-1:0] post_trace [0:NUM_NEURONS-1];
    reg [NUM_NEURONS-1:0] pre_trace_valid;
    reg [NUM_NEURONS-1:0] post_trace_valid;

    assign spike_ack = (state == ACK);
    assign w_rd_en = (state == READ_REQ);
    assign w_rd_addr = lat_waddr;
    assign w_wr_en = (state == WRITE);
    assign w_wr_addr = lat_waddr;

    always @(posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            lat_is_post <= 1'b0;
            lat_dt <= {TW{1'b0}};
            lat_waddr <= {W_ADDR_W{1'b0}};
            trace_valid <= 1'b0;
            pre_trace_valid <= {NUM_NEURONS{1'b0}};
            post_trace_valid <= {NUM_NEURONS{1'b0}};
            delta_w <= {DW{1'b0}};
            w_wr_data <= {DW{1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    if (spike_req) begin
                        lat_is_post <= spike_is_post;
                        lat_waddr <= {spike_pre_id, spike_post_id};
                        if (spike_is_post) begin
                            trace_valid <= pre_trace_valid[spike_pre_id];
                            if (pre_trace_valid[spike_pre_id])
                                lat_dt <= event_time - pre_trace[spike_pre_id];
                            post_trace[spike_post_id] <= event_time;
                            post_trace_valid[spike_post_id] <= 1'b1;
                        end else begin
                            trace_valid <= post_trace_valid[spike_post_id];
                            if (post_trace_valid[spike_post_id])
                                lat_dt <= event_time - post_trace[spike_post_id];
                            pre_trace[spike_pre_id] <= event_time;
                            pre_trace_valid[spike_pre_id] <= 1'b1;
                        end
                        state <= PREPARE;
                    end
                end

                PREPARE: begin
                    if (trace_valid && (lat_dt != 0) && (lat_dt <= T_WINDOW)) begin
                        if (lat_is_post)
                            delta_w <= A_POS >> (lat_dt >> DECAY_SHIFT);
                        else
                            delta_w <= A_NEG >> (lat_dt >> DECAY_SHIFT);
                        state <= READ_REQ;
                    end else begin
                        state <= ACK;
                    end
                end

                READ_REQ: if (w_rd_ready) state <= READ_WAIT;

                READ_WAIT: begin
                    state <= READ_USE;
                end

                READ_USE: begin
                    if (delta_w == {DW{1'b0}}) begin
                        state <= ACK;
                    end else if (lat_is_post) begin
                        if ((w_rd_data >= W_MAX) ||
                            ({1'b0, w_rd_data} + {1'b0, delta_w} > {1'b0, W_MAX}))
                            w_wr_data <= W_MAX;
                        else
                            w_wr_data <= (w_rd_data + delta_w);
                        state <= WRITE;
                    end else begin
                        if ({1'b0, w_rd_data} < ({1'b0, W_MIN} + {1'b0, delta_w}))
                            w_wr_data <= W_MIN;
                        else
                            w_wr_data <= w_rd_data - delta_w;
                        state <= WRITE;
                    end
                end

                WRITE: if (w_wr_ready) state <= ACK;
                ACK: if (!spike_req) state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end
endmodule
