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
    parameter integer DECAY_SHIFT      = 2,
    // Each queue entry batches all events arriving in one cycle. A batch
    // contains one optional external pre-event and a local-spike bit mask.
    parameter integer STDP_QUEUE_DEPTH = 128
)(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          cfg_w_wr_en,
    input  wire [W_ADDR_W-1:0]           cfg_w_addr,
    input  wire [DW-1:0]                 cfg_w_data,
    output wire                          cfg_w_ready,

    input  wire                          w_mon_rd_en,
    input  wire [W_ADDR_W-1:0]           w_mon_addr,
    output wire [DW-1:0]                 w_mon_data,
    output wire                          w_mon_ready,

    input  wire                          ext_aer_req,
    input  wire [N_BITS-1:0]             ext_aer_neuron_id,
    output wire                          ext_aer_ack,

    // Scalar addressed synaptic injection interface. One event selects one
    // neuron and supplies its current, reducing the former per-neuron buses.
    input  wire                          ext_syn_valid,
    input  wire [N_BITS-1:0]             ext_syn_neuron_id,
    input  wire [DW-1:0]                 ext_syn_current,
    output wire                          ext_syn_ready,

    output wire                          out_aer_req,
    output wire [N_BITS-1:0]             out_aer_addr,
    input  wire                          out_aer_ack,
    output wire                          out_aer_overflow,

    output wire [NUM_NEURONS-1:0]        neuron_spikes,
    output wire [TW-1:0]                 current_timestamp,
    output wire                          stdp_ready,
    output reg                           stdp_event_overflow
`ifdef USE_POWER_PINS
    , inout wire                         VPWR,
    inout wire                         VGND
`endif
);

    wire [TW-1:0] g_time;
    assign current_timestamp = g_time;

    timestamp_counter #(.WIDTH(TW)) u_timer (
        .clk       (clk),
        .rst_n     (rst_n),
        .timestamp (g_time)
    );

    reg                   sram_a_wr_en;
    reg                   sram_a_rd_en;
    reg  [W_ADDR_W-1:0]   sram_a_addr;
    reg  [DW-1:0]         sram_a_wr_data;
    wire [DW-1:0]         sram_a_rd_data;
    wire                  sram_a_ready;
    wire                  sram_b_ready;
    wire                  sram_r_ready;
    wire [DW-1:0]         sram_r_rd_data;

    wire                  stdp_w_rd_en;
    wire [W_ADDR_W-1:0]   stdp_w_rd_addr;
    wire [DW-1:0]         stdp_w_rd_data;
    wire                  stdp_w_wr_en;
    wire [W_ADDR_W-1:0]   stdp_w_wr_addr;
    wire [DW-1:0]         stdp_w_wr_data;

    wire aer_weight_rd_req;
    wire [W_ADDR_W-1:0] aer_weight_rd_addr;
    wire aer_pre_event;
    wire [N_BITS-1:0] aer_pre_event_id;
    wire [NUM_NEURONS-1:0] aer_syn_valid;
    wire [DW-1:0] aer_syn_weight;
    reg [TW-1:0] scan_event_time;

    aer_interface #(
        .NUM_NEURONS (NUM_NEURONS), .N_BITS (N_BITS), .DW (DW),
        .W_ADDR_W (W_ADDR_W)
    ) u_aer_interface (
        .clk (clk), .rst_n (rst_n),
        .in_req (ext_aer_req), .in_neuron_id (ext_aer_neuron_id),
        .in_ack (ext_aer_ack), .pre_event (aer_pre_event),
        .pre_event_id (aer_pre_event_id),
        .syn_valid (aer_syn_valid), .syn_weight (aer_syn_weight),
        .weight_rd_req (aer_weight_rd_req), .weight_rd_addr (aer_weight_rd_addr),
        .weight_rd_ready (sram_r_ready),
        .weight_rd_data (sram_r_rd_data),
        .spike_in (neuron_spikes), .out_req (out_aer_req),
        .out_addr (out_aer_addr), .out_ack (out_aer_ack),
        .out_overflow (out_aer_overflow)
    );

    always @(*) begin
        if (cfg_w_wr_en) begin
            sram_a_wr_en   = 1'b1;
            sram_a_rd_en   = 1'b0;
            sram_a_addr    = cfg_w_addr;
            sram_a_wr_data = cfg_w_data;
        end else if (w_mon_rd_en) begin
            sram_a_wr_en   = 1'b0;
            sram_a_rd_en   = 1'b1;
            sram_a_addr    = w_mon_addr;
            sram_a_wr_data = {DW{1'b0}};
        end else begin
            sram_a_wr_en   = 1'b0;
            sram_a_rd_en   = 1'b0;
            sram_a_addr    = {W_ADDR_W{1'b0}};
            sram_a_wr_data = {DW{1'b0}};
        end
    end

    assign w_mon_data = sram_a_rd_data;
    assign cfg_w_ready = sram_a_ready;
    assign w_mon_ready = sram_a_ready;

    weight_sram #(
        .DEPTH     (4096),
        .WIDTH     (DW),
        .ADDR_BITS (W_ADDR_W)
    ) u_weight_sram (
        .clk       (clk),
        .rst_n     (rst_n),
        .a_wr_en   (sram_a_wr_en),
        .a_rd_en   (sram_a_rd_en),
        .a_addr    (sram_a_addr),
        .a_wr_data (sram_a_wr_data),
        .a_rd_data (sram_a_rd_data),
        .a_ready   (sram_a_ready),
        .b_wr_en   (stdp_w_wr_en),
        .b_rd_en   (stdp_w_rd_en),
        .b_addr    (stdp_w_wr_en ? stdp_w_wr_addr : stdp_w_rd_addr),
        .b_wr_data (stdp_w_wr_data),
        .b_rd_data (stdp_w_rd_data),
        .b_ready   (sram_b_ready),
        .r_rd_en   (aer_weight_rd_req),
        .r_addr    (aer_weight_rd_addr),
        .r_rd_data (sram_r_rd_data),
        .r_ready   (sram_r_ready)
`ifdef USE_POWER_PINS
        , .VPWR    (VPWR),
        .VGND      (VGND)
`endif
    );

    reg              stdp_req;
    wire             stdp_ack;
    reg              stdp_is_post;
    reg [N_BITS-1:0] stdp_pre_id;
    reg [N_BITS-1:0] stdp_post_id;

    stdp_engine_sync #(
        .NUM_NEURONS (NUM_NEURONS),
        .N_BITS      (N_BITS),
        .DW          (DW),
        .TW          (TW),
        .W_ADDR_W    (W_ADDR_W),
        .T_WINDOW    (T_WINDOW),
        .A_POS       (A_POS),
        .A_NEG       (A_NEG),
        .W_MIN       (W_MIN),
        .W_MAX       (W_MAX),
        .DECAY_SHIFT (DECAY_SHIFT)
    ) u_stdp_sync (
        .clk                (clk),
        .rst_n              (rst_n),
        .spike_req          (stdp_req),
        .spike_ack          (stdp_ack),
        .spike_is_post      (stdp_is_post),
        .spike_pre_id       (stdp_pre_id),
        .spike_post_id      (stdp_post_id),
        .event_time         (scan_event_time),
        .w_rd_en            (stdp_w_rd_en),
        .w_rd_addr          (stdp_w_rd_addr),
        .w_rd_data          (stdp_w_rd_data),
        .w_wr_en            (stdp_w_wr_en),
        .w_wr_addr          (stdp_w_wr_addr),
        .w_wr_data          (stdp_w_wr_data),
        .w_rd_ready         (sram_b_ready),
        .w_wr_ready         (sram_b_ready)
    );

    localparam STDP_SCAN_IDLE     = 2'b00;
    localparam STDP_SCAN_ISSUE    = 2'b01;
    localparam STDP_SCAN_WAIT_ACK = 2'b10;
    localparam STDP_SCAN_ACK_LOW  = 2'b11;

    localparam Q_PTR_W = (STDP_QUEUE_DEPTH > 1) ? $clog2(STDP_QUEUE_DEPTH) : 1;
    localparam Q_COUNT_W = $clog2(STDP_QUEUE_DEPTH + 1);

    reg [1:0]             stdp_scan_state;
    reg [NUM_NEURONS-1:0] prev_spikes;
    wire [NUM_NEURONS-1:0] new_local_spikes = neuron_spikes & ~prev_spikes;
    reg [NUM_NEURONS-1:0] batch_spikes_mem [0:STDP_QUEUE_DEPTH-1];
    reg                    batch_ext_valid_mem [0:STDP_QUEUE_DEPTH-1];
    reg [N_BITS-1:0]       batch_ext_id_mem [0:STDP_QUEUE_DEPTH-1];
    reg [TW-1:0]           batch_time_mem [0:STDP_QUEUE_DEPTH-1];
    reg [Q_PTR_W-1:0]      batch_head, batch_tail;
    reg [Q_COUNT_W-1:0]    batch_count;
    integer                batch_count_next;
    reg [NUM_NEURONS-1:0]  pending_local_spikes;
    reg [NUM_NEURONS-1:0]  pending_local_post_mask;
    reg                    pending_ext_valid;
    reg [N_BITS-1:0]       pending_ext_id;
    reg [TW-1:0]           pending_batch_time;
    integer                batch_write_idx;
    wire                   local_select_found;
    wire [N_BITS-1:0]      local_select_id;
    reg [N_BITS-1:0]      scan_event_id;
    reg                   scan_event_is_post;
    reg [N_BITS-1:0]      scan_partner_id;

    priority_encoder #(
        .WIDTH(NUM_NEURONS),
        .INDEX_WIDTH(N_BITS)
    ) u_local_stdp_encoder (
        .request(pending_local_spikes),
        .valid(local_select_found),
        .index(local_select_id)
    );

    assign stdp_ready = (stdp_scan_state == STDP_SCAN_IDLE) &&
                        (batch_count == 0) && !pending_ext_valid &&
                        (pending_local_spikes == {NUM_NEURONS{1'b0}});

    always @(posedge clk) begin
        if (!rst_n) begin
            stdp_scan_state <= STDP_SCAN_IDLE;
            stdp_req        <= 1'b0;
            stdp_is_post    <= 1'b0;
            stdp_pre_id     <= {N_BITS{1'b0}};
            stdp_post_id    <= {N_BITS{1'b0}};
            prev_spikes     <= {NUM_NEURONS{1'b0}};
            scan_event_id <= {N_BITS{1'b0}};
            scan_event_is_post <= 1'b0;
            scan_partner_id <= {N_BITS{1'b0}};
            scan_event_time <= {TW{1'b0}};
            stdp_event_overflow <= 1'b0;
            batch_head <= {Q_PTR_W{1'b0}};
            batch_tail <= {Q_PTR_W{1'b0}};
            batch_count <= {Q_COUNT_W{1'b0}};
            pending_local_spikes <= {NUM_NEURONS{1'b0}};
            pending_local_post_mask <= {NUM_NEURONS{1'b0}};
            pending_ext_valid <= 1'b0;
            pending_ext_id <= {N_BITS{1'b0}};
            pending_batch_time <= {TW{1'b0}};
        end else begin
            batch_count_next = batch_count;
            batch_write_idx = batch_tail;
            case (stdp_scan_state)
                STDP_SCAN_IDLE: begin
                    if (pending_ext_valid) begin
                        scan_event_id <= pending_ext_id;
                        scan_event_is_post <= 1'b0;
                        scan_event_time <= pending_batch_time;
                        scan_partner_id <= {N_BITS{1'b0}};
                        pending_ext_valid <= 1'b0;
                        stdp_scan_state <= STDP_SCAN_ISSUE;
                    end else if (local_select_found) begin
                        scan_event_id <= local_select_id;
                        scan_event_is_post <= pending_local_post_mask[local_select_id];
                        scan_event_time <= pending_batch_time;
                        scan_partner_id <= {N_BITS{1'b0}};
                        if (pending_local_post_mask[local_select_id]) begin
                            pending_local_spikes[local_select_id] <= 1'b0;
                            pending_local_post_mask[local_select_id] <= 1'b0;
                        end else begin
                            pending_local_post_mask[local_select_id] <= 1'b1;
                        end
                        stdp_scan_state <= STDP_SCAN_ISSUE;
                    end else if (batch_count != 0) begin
                        pending_local_spikes <= batch_spikes_mem[batch_head];
                        pending_local_post_mask <= {NUM_NEURONS{1'b0}};
                        pending_ext_valid <= batch_ext_valid_mem[batch_head];
                        pending_ext_id <= batch_ext_id_mem[batch_head];
                        pending_batch_time <= batch_time_mem[batch_head];
                        if (batch_head == STDP_QUEUE_DEPTH-1)
                            batch_head <= {Q_PTR_W{1'b0}};
                        else
                            batch_head <= batch_head + 1'b1;
                        batch_count_next = batch_count_next - 1;
                    end
                end
                STDP_SCAN_ISSUE: begin
                    stdp_req <= 1'b1;
                    stdp_is_post <= scan_event_is_post;
                    if (scan_event_is_post) begin
                        stdp_pre_id <= scan_partner_id;
                        stdp_post_id <= scan_event_id;
                    end else begin
                        stdp_pre_id <= scan_event_id;
                        stdp_post_id <= scan_partner_id;
                    end
                    stdp_scan_state <= STDP_SCAN_WAIT_ACK;
                end
                STDP_SCAN_WAIT_ACK: begin
                    if (stdp_ack) begin
                        stdp_req <= 1'b0;
                        stdp_scan_state <= STDP_SCAN_ACK_LOW;
                    end
                end
                STDP_SCAN_ACK_LOW: begin
                    if (!stdp_ack) begin
                        if (scan_partner_id == NUM_NEURONS-1)
                            stdp_scan_state <= STDP_SCAN_IDLE;
                        else begin
                            scan_partner_id <= scan_partner_id + 1'b1;
                            stdp_scan_state <= STDP_SCAN_ISSUE;
                        end
                    end
                end
            endcase

            // Store one batch per cycle: all local rising edges share the
            // timestamp, and the optional external source event shares it too.
            // Each FIFO array has exactly one write site and one write port.
            if (aer_pre_event || (|new_local_spikes)) begin
                if (batch_count_next < STDP_QUEUE_DEPTH) begin
                    batch_spikes_mem[batch_write_idx] <= new_local_spikes;
                    batch_ext_valid_mem[batch_write_idx] <= aer_pre_event;
                    batch_ext_id_mem[batch_write_idx] <= aer_pre_event_id;
                    batch_time_mem[batch_write_idx] <= g_time;
                    if (batch_write_idx == STDP_QUEUE_DEPTH-1)
                        batch_write_idx = 0;
                    else
                        batch_write_idx = batch_write_idx + 1;
                    batch_count_next = batch_count_next + 1;
                end else begin
                    stdp_event_overflow <= 1'b1;
                end
            end

            batch_tail <= batch_write_idx[Q_PTR_W-1:0];
            batch_count <= batch_count_next[Q_COUNT_W-1:0];
            prev_spikes <= neuron_spikes;
        end
    end

    wire [NUM_NEURONS-1:0]    arr_syn_valid;
    wire [NUM_NEURONS*DW-1:0] arr_syn_current;
    wire [NUM_NEURONS-1:0]    neuron_syn_ready;
    wire [NUM_NEURONS-1:0]    ext_syn_target_ready;

    assign ext_syn_ready = |ext_syn_target_ready;

    genvar ni;
    generate
        for (ni = 0; ni < NUM_NEURONS; ni = ni + 1) begin : gen_arr_in
            assign ext_syn_target_ready[ni] =
                (ext_syn_neuron_id == ni) && neuron_syn_ready[ni] && !aer_syn_valid[ni];
            wire ext_syn_selected = ext_syn_valid && ext_syn_target_ready[ni];
            assign arr_syn_valid[ni] = ext_syn_selected | aer_syn_valid[ni];
            assign arr_syn_current[ni*DW +: DW] = aer_syn_valid[ni] ?
                aer_syn_weight : (ext_syn_selected ? ext_syn_current : {DW{1'b0}});
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
        .syn_ready   (neuron_syn_ready),
        .spike_out   (neuron_spikes)
    );

endmodule
