`timescale 1ns / 1ps

module stdp_engine_async #(
    parameter N_BITS      = 6,
    parameter DW          = 16,
    parameter TW          = 16,
    parameter W_ADDR_W    = 12,
    parameter [TW-1:0] T_WINDOW    = 16'd64,
    parameter [DW-1:0] A_POS       = 16'd100,
    parameter [DW-1:0] A_NEG       = 16'd80,
    parameter [DW-1:0] W_MIN       = 16'd0,
    parameter [DW-1:0] W_MAX       = 16'd32767,
    parameter integer  DECAY_SHIFT = 2,
    parameter integer  STAGE_DELAY = 2
)(
    input  wire              rst_n,

    input  wire              spike_req,
    output reg               spike_ack,
    input  wire              spike_is_post,
    input  wire [N_BITS-1:0] spike_pre_id,
    input  wire [N_BITS-1:0] spike_post_id,
    input  wire [TW-1:0]     current_time,

    output reg  [N_BITS-1:0] pre_trace_rd_addr,
    input  wire [TW-1:0]     pre_trace_rd_data,
    output reg               pre_trace_wr_en,
    output reg  [N_BITS-1:0] pre_trace_wr_addr,
    output reg  [TW-1:0]     pre_trace_wr_data,

    output reg  [N_BITS-1:0] post_trace_rd_addr,
    input  wire [TW-1:0]     post_trace_rd_data,
    output reg               post_trace_wr_en,
    output reg  [N_BITS-1:0] post_trace_wr_addr,
    output reg  [TW-1:0]     post_trace_wr_data,

    output reg  [W_ADDR_W-1:0] w_rd_addr,
    input  wire [DW-1:0]       w_rd_data,
    output reg                 w_wr_en,
    output reg  [W_ADDR_W-1:0] w_wr_addr,
    output reg  [DW-1:0]       w_wr_data
);

    reg              lat_is_post;
    reg [N_BITS-1:0] lat_pre_id;
    reg [N_BITS-1:0] lat_post_id;
    reg [TW-1:0]     lat_time;
    reg [W_ADDR_W-1:0] lat_waddr;
    reg [TW-1:0]     trace_val;
    reg [TW-1:0]     dt;
    reg [DW-1:0]     old_w;
    reg [DW-1:0]     delta_w;
    reg [DW-1:0]     new_w;

    initial begin
        spike_ack          = 1'b0;
        pre_trace_rd_addr  = {N_BITS{1'b0}};
        pre_trace_wr_en    = 1'b0;
        pre_trace_wr_addr  = {N_BITS{1'b0}};
        pre_trace_wr_data  = {TW{1'b0}};
        post_trace_rd_addr = {N_BITS{1'b0}};
        post_trace_wr_en   = 1'b0;
        post_trace_wr_addr = {N_BITS{1'b0}};
        post_trace_wr_data = {TW{1'b0}};
        w_rd_addr          = {W_ADDR_W{1'b0}};
        w_wr_en            = 1'b0;
        w_wr_addr          = {W_ADDR_W{1'b0}};
        w_wr_data          = {DW{1'b0}};
        lat_is_post        = 1'b0;
        lat_pre_id         = {N_BITS{1'b0}};
        lat_post_id        = {N_BITS{1'b0}};
        lat_time           = {TW{1'b0}};
        lat_waddr          = {W_ADDR_W{1'b0}};
        trace_val          = {TW{1'b0}};
        dt                 = {TW{1'b0}};
        old_w              = {DW{1'b0}};
        delta_w            = {DW{1'b0}};
        new_w              = {DW{1'b0}};
    end

    always begin : async_pipeline

        spike_ack        = 1'b0;
        pre_trace_wr_en  = 1'b0;
        post_trace_wr_en = 1'b0;
        w_wr_en          = 1'b0;

        @(posedge spike_req);

        lat_is_post = spike_is_post;
        lat_pre_id  = spike_pre_id;
        lat_post_id = spike_post_id;
        lat_time    = current_time;
        lat_waddr   = {spike_pre_id, spike_post_id};

        pre_trace_rd_addr  = lat_pre_id;
        post_trace_rd_addr = lat_post_id;
        w_rd_addr          = lat_waddr;

        if (lat_is_post) begin
            post_trace_wr_addr = lat_post_id;
            post_trace_wr_data = lat_time;
        end else begin
            pre_trace_wr_addr = lat_pre_id;
            pre_trace_wr_data = lat_time;
        end

        #(STAGE_DELAY);

        if (lat_is_post)
            post_trace_wr_en = 1'b1;
        else
            pre_trace_wr_en = 1'b1;

        #(STAGE_DELAY);

        pre_trace_wr_en  = 1'b0;
        post_trace_wr_en = 1'b0;

        if (lat_is_post)
            trace_val = pre_trace_rd_data;
        else
            trace_val = post_trace_rd_data;

        dt = lat_time - trace_val;

        #(STAGE_DELAY);

        old_w = w_rd_data;

        if (trace_val != {TW{1'b0}} && dt > 0 && dt <= T_WINDOW) begin
            if (lat_is_post) begin
                delta_w = A_POS >> (dt >> DECAY_SHIFT);
                if (old_w + delta_w > W_MAX)
                    new_w = W_MAX;
                else
                    new_w = old_w + delta_w;
            end else begin
                delta_w = A_NEG >> (dt >> DECAY_SHIFT);
                if (old_w < W_MIN + delta_w)
                    new_w = W_MIN;
                else
                    new_w = old_w - delta_w;
            end

            w_wr_addr = lat_waddr;
            w_wr_data = new_w;
            #1;
            w_wr_en = 1'b1;
            #(STAGE_DELAY);
            w_wr_en = 1'b0;
        end

        spike_ack = 1'b1;

        @(negedge spike_req);

        spike_ack = 1'b0;
    end

endmodule
