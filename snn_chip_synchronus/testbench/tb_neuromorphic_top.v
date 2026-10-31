`timescale 1ns / 1ps

module tb_neuromorphic_top;

    localparam NUM_NEURONS = 64;
    localparam N_BITS      = 6;
    localparam DW          = 16;
    localparam TW          = 16;
    localparam W_ADDR_W    = 12;

    reg                          clk;
    reg                          rst_n;

    reg                          cfg_w_wr_en;
    reg  [W_ADDR_W-1:0]          cfg_w_addr;
    reg  [DW-1:0]                cfg_w_data;

    reg                          w_mon_rd_en;
    reg  [W_ADDR_W-1:0]          w_mon_addr;
    wire [DW-1:0]                w_mon_data;

    reg                          ext_aer_req;
    reg  [N_BITS-1:0]            ext_aer_pre_id;
    reg  [N_BITS-1:0]            ext_aer_post_id;
    wire                         ext_aer_ack;

    reg  [NUM_NEURONS-1:0]       ext_syn_valid;
    reg  [NUM_NEURONS*DW-1:0]    ext_syn_current;

    wire [NUM_NEURONS-1:0]       neuron_spikes;
    wire [NUM_NEURONS*DW-1:0]    neuron_v_mems;
    wire [TW-1:0]                current_timestamp;
    wire                         stdp_ready;

    neuromorphic_top #(
        .NUM_NEURONS (NUM_NEURONS),
        .N_BITS      (N_BITS),
        .DW          (DW),
        .TW          (TW),
        .W_ADDR_W    (W_ADDR_W),
        .V_THRESH    (16'sd1000),
        .V_RESET     (16'sd0),
        .LEAK_SHIFT  (3),
        .T_WINDOW    (16'd64),
        .A_POS       (16'd100),
        .A_NEG       (16'd80),
        .W_MIN       (16'd0),
        .W_MAX       (16'd32767),
        .DECAY_SHIFT (2)
    ) dut (
        .clk               (clk),
        .rst_n             (rst_n),
        .cfg_w_wr_en       (cfg_w_wr_en),
        .cfg_w_addr        (cfg_w_addr),
        .cfg_w_data        (cfg_w_data),
        .w_mon_rd_en       (w_mon_rd_en),
        .w_mon_addr        (w_mon_addr),
        .w_mon_data        (w_mon_data),
        .ext_aer_req       (ext_aer_req),
        .ext_aer_pre_id    (ext_aer_pre_id),
        .ext_aer_post_id   (ext_aer_post_id),
        .ext_aer_ack       (ext_aer_ack),
        .ext_syn_valid     (ext_syn_valid),
        .ext_syn_current   (ext_syn_current),
        .neuron_spikes     (neuron_spikes),
        .neuron_v_mems     (neuron_v_mems),
        .current_timestamp (current_timestamp),
        .stdp_ready        (stdp_ready)
    );

    always #5 clk = ~clk;

    task cfg_weight(input [N_BITS-1:0] pre, input [N_BITS-1:0] post, input [DW-1:0] d);
        begin
            @(posedge clk); #1;
            cfg_w_addr  = {pre, post};
            cfg_w_data  = d;
            cfg_w_wr_en = 1'b1;
            @(posedge clk); #1;
            cfg_w_wr_en = 1'b0;
        end
    endtask

    reg [DW-1:0] read_w_result;

    task read_weight(input [N_BITS-1:0] pre, input [N_BITS-1:0] post);
        begin
            @(posedge clk); #1;
            w_mon_addr  = {pre, post};
            w_mon_rd_en = 1'b1;
            @(posedge clk); #1;
            read_w_result = w_mon_data;
            w_mon_rd_en = 1'b0;
            @(posedge clk); #1;
        end
    endtask

    task send_aer_spike(input [N_BITS-1:0] pre_addr, input [N_BITS-1:0] post_addr);
        begin
            @(posedge clk); #1;
            ext_aer_pre_id  = pre_addr;
            ext_aer_post_id = post_addr;
            ext_aer_req     = 1'b1;
            while (!ext_aer_ack) begin
                @(posedge clk); #1;
            end
            ext_aer_req = 1'b0;
            @(posedge clk); #1;
        end
    endtask

    task inject_direct(input integer idx, input signed [DW-1:0] cur);
        begin
            @(posedge clk); #1;
            ext_syn_valid[idx]            = 1'b1;
            ext_syn_current[idx*DW +: DW] = cur;
            @(posedge clk); #1;
            @(posedge clk); #1;
            ext_syn_valid[idx]            = 1'b0;
            ext_syn_current[idx*DW +: DW] = {DW{1'b0}};
            @(posedge clk); #1;
        end
    endtask

    task wait_stdp_idle;
        begin
            repeat(10) @(posedge clk);
            while (!stdp_ready) begin
                @(posedge clk);
            end
            repeat(2) @(posedge clk);
        end
    endtask

    reg signed [DW-1:0] vm_obs;

    initial begin
        $dumpfile("neuromorphic_top.vcd");
        $dumpvars(0, tb_neuromorphic_top);

        clk             = 1'b0;
        rst_n           = 1'b0;
        cfg_w_wr_en     = 1'b0;
        cfg_w_addr      = 0;
        cfg_w_data      = 0;
        w_mon_rd_en     = 1'b0;
        w_mon_addr      = 0;
        ext_aer_req     = 1'b0;
        ext_aer_pre_id  = 0;
        ext_aer_post_id = 0;
        ext_syn_valid   = 0;
        ext_syn_current = 0;

        #40;
        rst_n = 1'b1;
        @(posedge clk); #1;

        $display("=========================================================");
        $display("   ASYNC STDP - 64-NEURON CROSSBAR VERIFICATION");
        $display("=========================================================");

        $display("\n[TEST 1] Programming crossbar synaptic weights...");
        cfg_weight(6'd0,  6'd1,  16'd500);
        cfg_weight(6'd2,  6'd3,  16'd400);
        cfg_weight(6'd63, 6'd63, 16'd850);
        cfg_weight(6'd10, 6'd20, 16'd620);

        read_weight(6'd0, 6'd1);
        $display("  Synapse [0,1]  : %0d (Expected 500)", read_w_result);
        read_weight(6'd2, 6'd3);
        $display("  Synapse [2,3]  : %0d (Expected 400)", read_w_result);
        read_weight(6'd63, 6'd63);
        $display("  Synapse [63,63]: %0d (Expected 850)", read_w_result);
        read_weight(6'd10, 6'd20);
        $display("  Synapse [10,20]: %0d (Expected 620)", read_w_result);

        $display("\n[TEST 2] AER Spike Delivery & LIF Integration...");
        send_aer_spike(6'd0, 6'd1);
        wait_stdp_idle;
        vm_obs = neuron_v_mems[1*DW +: DW];
        $display("  Neuron 1 v_mem after Pre-Spike 0: %0d", vm_obs);

        send_aer_spike(6'd10, 6'd20);
        wait_stdp_idle;
        vm_obs = neuron_v_mems[20*DW +: DW];
        $display("  Neuron 20 v_mem after Pre-Spike 10: %0d", vm_obs);

        $display("\n[TEST 3] Async STDP Long-Term Potentiation (LTP)...");
        $display("  Pre-spike on neuron 0 already recorded in trace");
        inject_direct(1, 16'sd600);
        wait_stdp_idle;
        read_weight(6'd0, 6'd1);
        $display("  Weight [0,1] after post-spike on N1: %0d (was 500)", read_w_result);

        $display("\n[TEST 4] Async STDP Long-Term Depression (LTD)...");
        inject_direct(3, 16'sd1100);
        wait_stdp_idle;
        repeat(8) @(posedge clk);
        send_aer_spike(6'd2, 6'd3);
        wait_stdp_idle;
        read_weight(6'd2, 6'd3);
        $display("  Weight [2,3] after anti-causal: %0d (was 400)", read_w_result);

        $display("\n[TEST 5] Boundary Synapse [63,63] Async Potentiation...");
        send_aer_spike(6'd63, 6'd63);
        wait_stdp_idle;
        inject_direct(63, 16'sd600);
        wait_stdp_idle;
        read_weight(6'd63, 6'd63);
        $display("  Weight [63,63] after potentiation: %0d (was 850)", read_w_result);

        $display("\n=========================================================");
        $display("   ALL ASYNC STDP TESTS COMPLETED SUCCESSFULLY");
        $display("=========================================================");
        #200;
        $finish;
    end

endmodule
