`timescale 1ns / 1ps

module neuromorphic_top #(
    parameter NUM_NEURONS = 64,
    parameter N_BITS      = 6,
    parameter DW          = 16,
    parameter TW          = 16,
    parameter W_ADDR_W    = 12,
    parameter signed [DW-1:0] V_THRESH = 16'sd1000,
    parameter signed [DW-1:0] V_RESET  = 16'sd0,
    parameter integer LEAK_SHIFT       = 3,
    parameter [TW-1:0] T_WINDOW        = 16'd64,
    parameter [DW-1:0] A_POS           = 16'd100,
    parameter [DW-1:0] A_NEG           = 16'd80,
    parameter [DW-1:0] W_MIN           = 16'd0,
    parameter [DW-1:0] W_MAX           = 16'd32767,
    parameter integer DECAY_SHIFT      = 2
)(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          cfg_w_wr_en,
    input  wire [W_ADDR_W-1:0]           cfg_w_addr,
    input  wire [DW-1:0]                 cfg_w_data,

    input  wire                          w_mon_rd_en,
    input  wire [W_ADDR_W-1:0]           w_mon_addr,
    output wire [DW-1:0]                 w_mon_data,

    input  wire                          ext_aer_req,
    input  wire [N_BITS-1:0]             ext_aer_pre_id,
    input  wire [N_BITS-1:0]             ext_aer_post_id,
    output reg                           ext_aer_ack,

    input  wire [NUM_NEURONS-1:0]        ext_syn_valid,
    input  wire [NUM_NEURONS*DW-1:0]     ext_syn_current,

    output wire [NUM_NEURONS-1:0]        neuron_spikes,
    output wire [NUM_NEURONS*DW-1:0]     neuron_v_mems,
    output wire [TW-1:0]                 current_timestamp,
    output wire                          stdp_ready
);

    wire [TW-1:0] g_time;
    assign current_timestamp = g_time;

    timestamp_counter #(.WIDTH(TW)) u_timer (
        .clk       (clk),
        .rst_n     (rst_n),
        .timestamp (g_time)
    );

    reg                   sram_w_wr_en;
    reg  [W_ADDR_W-1:0]   sram_w_addr;
    reg  [DW-1:0]         sram_w_wr_data;
    reg                   sram_w_rd_en;
    wire [DW-1:0]         sram_w_rd_data;

    wire [W_ADDR_W-1:0]   stdp_async_rd_addr;
    wire [DW-1:0]         stdp_async_rd_data;
    wire                  stdp_async_wr_en;
    wire [W_ADDR_W-1:0]   stdp_async_wr_addr;
    wire [DW-1:0]         stdp_async_wr_data;

    localparam AER_IDLE   = 2'b00;
    localparam AER_FETCHW = 2'b01;
    localparam AER_DELIV  = 2'b10;

    reg [1:0]        aer_state;
    reg [N_BITS-1:0] aer_latched_pre;
    reg [N_BITS-1:0] aer_latched_post;

    always @(*) begin
        if (cfg_w_wr_en) begin
            sram_w_wr_en   = 1'b1;
            sram_w_rd_en   = 1'b0;
            sram_w_addr    = cfg_w_addr;
            sram_w_wr_data = cfg_w_data;
        end else if (w_mon_rd_en) begin
            sram_w_wr_en   = 1'b0;
            sram_w_rd_en   = 1'b1;
            sram_w_addr    = w_mon_addr;
            sram_w_wr_data = {DW{1'b0}};
        end else if (aer_state == AER_IDLE && ext_aer_req) begin
            sram_w_wr_en   = 1'b0;
            sram_w_rd_en   = 1'b1;
            sram_w_addr    = {ext_aer_pre_id, ext_aer_post_id};
            sram_w_wr_data = {DW{1'b0}};
        end else if (aer_state == AER_FETCHW) begin
            sram_w_wr_en   = 1'b0;
            sram_w_rd_en   = 1'b1;
            sram_w_addr    = {aer_latched_pre, aer_latched_post};
            sram_w_wr_data = {DW{1'b0}};
        end else begin
            sram_w_wr_en   = 1'b0;
            sram_w_rd_en   = 1'b0;
            sram_w_addr    = {W_ADDR_W{1'b0}};
            sram_w_wr_data = {DW{1'b0}};
        end
    end

    assign w_mon_data = sram_w_rd_data;

    weight_sram #(
        .DEPTH     (4096),
        .WIDTH     (DW),
        .ADDR_BITS (W_ADDR_W)
    ) u_weight_sram (
        .clk           (clk),
        .rst_n         (rst_n),
        .wr_en         (sram_w_wr_en),
        .rd_en         (sram_w_rd_en),
        .addr          (sram_w_addr),
        .wr_data       (sram_w_wr_data),
        .rd_data       (sram_w_rd_data),
        .async_rd_addr (stdp_async_rd_addr),
        .async_rd_data (stdp_async_rd_data),
        .async_wr_en   (stdp_async_wr_en),
        .async_wr_addr (stdp_async_wr_addr),
        .async_wr_data (stdp_async_wr_data)
    );

    wire [N_BITS-1:0] pre_trace_rd_addr;
    wire [TW-1:0]     pre_trace_rd_data;
    wire              pre_trace_wr_en;
    wire [N_BITS-1:0] pre_trace_wr_addr;
    wire [TW-1:0]     pre_trace_wr_data;

    trace_mem_async #(
        .DEPTH     (NUM_NEURONS),
        .WIDTH     (TW),
        .ADDR_BITS (N_BITS)
    ) u_pre_trace (
        .rst_n   (rst_n),
        .wr_en   (pre_trace_wr_en),
        .wr_addr (pre_trace_wr_addr),
        .wr_data (pre_trace_wr_data),
        .rd_addr (pre_trace_rd_addr),
        .rd_data (pre_trace_rd_data)
    );

    wire [N_BITS-1:0] post_trace_rd_addr;
    wire [TW-1:0]     post_trace_rd_data;
    wire              post_trace_wr_en;
    wire [N_BITS-1:0] post_trace_wr_addr;
    wire [TW-1:0]     post_trace_wr_data;

    trace_mem_async #(
        .DEPTH     (NUM_NEURONS),
        .WIDTH     (TW),
        .ADDR_BITS (N_BITS)
    ) u_post_trace (
        .rst_n   (rst_n),
        .wr_en   (post_trace_wr_en),
        .wr_addr (post_trace_wr_addr),
        .wr_data (post_trace_wr_data),
        .rd_addr (post_trace_rd_addr),
        .rd_data (post_trace_rd_data)
    );

    reg              stdp_req;
    wire             stdp_ack;
    reg              stdp_is_post;
    reg [N_BITS-1:0] stdp_pre_id;
    reg [N_BITS-1:0] stdp_post_id;

    stdp_engine_async #(
        .N_BITS      (N_BITS),
        .DW          (DW),
        .TW          (TW),
        .W_ADDR_W    (W_ADDR_W),
        .T_WINDOW    (T_WINDOW),
        .A_POS       (A_POS),
        .A_NEG       (A_NEG),
        .W_MIN       (W_MIN),
        .W_MAX       (W_MAX),
        .DECAY_SHIFT (DECAY_SHIFT),
        .STAGE_DELAY (2)
    ) u_stdp_async (
        .rst_n              (rst_n),
        .spike_req          (stdp_req),
        .spike_ack          (stdp_ack),
        .spike_is_post      (stdp_is_post),
        .spike_pre_id       (stdp_pre_id),
        .spike_post_id      (stdp_post_id),
        .current_time       (g_time),
        .pre_trace_rd_addr  (pre_trace_rd_addr),
        .pre_trace_rd_data  (pre_trace_rd_data),
        .pre_trace_wr_en    (pre_trace_wr_en),
        .pre_trace_wr_addr  (pre_trace_wr_addr),
        .pre_trace_wr_data  (pre_trace_wr_data),
        .post_trace_rd_addr (post_trace_rd_addr),
        .post_trace_rd_data (post_trace_rd_data),
        .post_trace_wr_en   (post_trace_wr_en),
        .post_trace_wr_addr (post_trace_wr_addr),
        .post_trace_wr_data (post_trace_wr_data),
        .w_rd_addr          (stdp_async_rd_addr),
        .w_rd_data          (stdp_async_rd_data),
        .w_wr_en            (stdp_async_wr_en),
        .w_wr_addr          (stdp_async_wr_addr),
        .w_wr_data          (stdp_async_wr_data)
    );

    reg [NUM_NEURONS-1:0]    routed_syn_valid;
    reg [NUM_NEURONS*DW-1:0] routed_syn_current;

    always @(posedge clk) begin
        if (!rst_n) begin
            aer_state          <= AER_IDLE;
            ext_aer_ack        <= 1'b0;
            routed_syn_valid   <= {NUM_NEURONS{1'b0}};
            routed_syn_current <= {NUM_NEURONS*DW{1'b0}};
            aer_latched_pre    <= {N_BITS{1'b0}};
            aer_latched_post   <= {N_BITS{1'b0}};
        end else begin
            case (aer_state)
                AER_IDLE: begin
                    ext_aer_ack      <= 1'b0;
                    routed_syn_valid <= {NUM_NEURONS{1'b0}};
                    if (ext_aer_req) begin
                        aer_latched_pre  <= ext_aer_pre_id;
                        aer_latched_post <= ext_aer_post_id;
                        aer_state        <= AER_FETCHW;
                    end
                end

                AER_FETCHW: begin
                    if (aer_latched_post < NUM_NEURONS) begin
                        routed_syn_valid[aer_latched_post]             <= 1'b1;
                        routed_syn_current[aer_latched_post*DW +: DW] <= sram_w_rd_data;
                    end
                    aer_state <= AER_DELIV;
                end

                AER_DELIV: begin
                    ext_aer_ack <= 1'b1;
                    aer_state   <= AER_IDLE;
                end
            endcase
        end
    end

    localparam HS_IDLE         = 2'b00;
    localparam HS_WAIT_ACK     = 2'b01;
    localparam HS_WAIT_ACK_LOW = 2'b10;

    reg [1:0]             hs_state;
    reg [NUM_NEURONS-1:0] prev_spikes;
    reg [N_BITS-1:0]      last_active_pre;
    integer               post_scan;

    reg stdp_ack_sync1, stdp_ack_sync2;

    assign stdp_ready = (hs_state == HS_IDLE);

    always @(posedge clk) begin
        if (!rst_n) begin
            stdp_ack_sync1 <= 1'b0;
            stdp_ack_sync2 <= 1'b0;
        end else begin
            stdp_ack_sync1 <= stdp_ack;
            stdp_ack_sync2 <= stdp_ack_sync1;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            hs_state        <= HS_IDLE;
            stdp_req        <= 1'b0;
            stdp_is_post    <= 1'b0;
            stdp_pre_id     <= {N_BITS{1'b0}};
            stdp_post_id    <= {N_BITS{1'b0}};
            prev_spikes     <= {NUM_NEURONS{1'b0}};
            last_active_pre <= {N_BITS{1'b0}};
        end else begin
            case (hs_state)
                HS_IDLE: begin
                    if (aer_state == AER_IDLE && ext_aer_req) begin
                        stdp_req     <= 1'b1;
                        stdp_is_post <= 1'b0;
                        stdp_pre_id  <= ext_aer_pre_id;
                        stdp_post_id <= ext_aer_post_id;
                        last_active_pre <= ext_aer_pre_id;
                        hs_state     <= HS_WAIT_ACK;
                    end else begin
                        for (post_scan = 0; post_scan < NUM_NEURONS; post_scan = post_scan + 1) begin
                            if (neuron_spikes[post_scan] && !prev_spikes[post_scan] && hs_state == HS_IDLE) begin
                                stdp_req     <= 1'b1;
                                stdp_is_post <= 1'b1;
                                stdp_pre_id  <= last_active_pre;
                                stdp_post_id <= post_scan[N_BITS-1:0];
                                hs_state     <= HS_WAIT_ACK;
                            end
                        end
                    end
                end

                HS_WAIT_ACK: begin
                    if (stdp_ack_sync2) begin
                        stdp_req <= 1'b0;
                        hs_state <= HS_WAIT_ACK_LOW;
                    end
                end

                HS_WAIT_ACK_LOW: begin
                    if (!stdp_ack_sync2) begin
                        hs_state <= HS_IDLE;
                    end
                end
            endcase

            prev_spikes <= neuron_spikes;
        end
    end

    wire [NUM_NEURONS-1:0]    arr_syn_valid;
    wire [NUM_NEURONS*DW-1:0] arr_syn_current;

    genvar ni;
    generate
        for (ni = 0; ni < NUM_NEURONS; ni = ni + 1) begin : gen_arr_in
            assign arr_syn_valid[ni] = ext_syn_valid[ni] | routed_syn_valid[ni];
            assign arr_syn_current[ni*DW +: DW] =
                routed_syn_valid[ni] ? routed_syn_current[ni*DW +: DW] : ext_syn_current[ni*DW +: DW];
        end
    endgenerate

    neuron_array #(
        .NUM_NEURONS (NUM_NEURONS),
        .DW          (DW),
        .TW          (TW),
        .V_THRESH    (V_THRESH),
        .V_RESET     (V_RESET),
        .LEAK_SHIFT  (LEAK_SHIFT)
    ) u_neuron_array (
        .clk         (clk),
        .rst_n       (rst_n),
        .syn_valid   (arr_syn_valid),
        .syn_current (arr_syn_current),
        .spike_out   (neuron_spikes),
        .v_mem       (neuron_v_mems)
    );

endmodule
