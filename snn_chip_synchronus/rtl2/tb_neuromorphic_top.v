`timescale 1ns/1ps
module tb_neuromorphic_top;
  localparam N=2, NB=1, DW=8, TW=8, AW=2;
  reg clk=0, rst_n=0;
  always #5 clk=~clk;
  reg cfg_w_wr_en=0;
  reg [AW-1:0] cfg_w_addr=0;
  reg [DW-1:0] cfg_w_data=0;
  reg w_mon_rd_en=0;
  reg [AW-1:0] w_mon_addr=0;
  wire [DW-1:0] w_mon_data;
  reg ext_aer_req=0;
  reg [NB-1:0] ext_aer_neuron_id=0;
  wire ext_aer_ack;
  wire ext_syn_ready;
  wire out_aer_req;
  wire [NB-1:0] out_aer_addr;
  reg out_aer_ack=1;
  wire out_aer_overflow;
  wire [N-1:0] neuron_spikes;
  wire [TW-1:0] current_timestamp;
  wire stdp_ready;
  wire stdp_event_overflow;
  integer timeout;
  reg [DW-1:0] initial_weight;

  neuromorphic_top #(
    .NUM_NEURONS(N), .N_BITS(NB), .DW(DW), .TW(TW), .W_ADDR_W(AW),
    .V_THRESH(8'sd10), .V_RESET(8'sd0), .LEAK_SHIFT(1),
    .T_WINDOW(8'd32), .A_POS(8'd16), .A_NEG(8'd4),
    .W_MIN(8'd0), .W_MAX(8'd100), .DECAY_SHIFT(1),
    .STDP_QUEUE_DEPTH(16)
  ) dut (
    .clk(clk), .rst_n(rst_n),
    .cfg_w_wr_en(cfg_w_wr_en), .cfg_w_addr(cfg_w_addr), .cfg_w_data(cfg_w_data),
    .w_mon_rd_en(w_mon_rd_en), .w_mon_addr(w_mon_addr), .w_mon_data(w_mon_data),
    .ext_aer_req(ext_aer_req), .ext_aer_neuron_id(ext_aer_neuron_id),
    .ext_aer_ack(ext_aer_ack),
    .ext_syn_valid(1'b0), .ext_syn_neuron_id({NB{1'b0}}), .ext_syn_current({DW{1'b0}}),
    .ext_syn_ready(ext_syn_ready),
    .out_aer_req(out_aer_req), .out_aer_addr(out_aer_addr),
    .out_aer_ack(out_aer_ack), .out_aer_overflow(out_aer_overflow),
    .neuron_spikes(neuron_spikes),
    .current_timestamp(current_timestamp), .stdp_ready(stdp_ready),
    .stdp_event_overflow(stdp_event_overflow)
  );

  task tick; begin @(posedge clk); #1; end endtask
  task check(input condition, input [8*100-1:0] msg); begin
    if (!condition) begin $display("FAIL: %0s at %0t", msg, $time); $fatal(1); end
    else $display("PASS: %0s at %0t", msg, $time);
  end endtask

  always @(posedge dut.stdp_req)
    $display("STDP req t=%0t post=%b pre_id=%0d post_id=%0d time=%0d", $time,
      dut.stdp_is_post, dut.stdp_pre_id, dut.stdp_post_id, dut.scan_event_time);
  always @(posedge dut.stdp_w_wr_en)
    $display("STDP write t=%0t addr=%0d data=%0d", $time,
      dut.stdp_w_wr_addr, dut.stdp_w_wr_data);

  initial begin
    $dumpfile("/tmp/neuromorphic_top.vcd");
    $dumpvars(0, tb_neuromorphic_top);
    repeat (3) tick();
    rst_n=1; tick();

    // Configuration path initializes the test matrix before event traffic.
    cfg_w_wr_en=1; cfg_w_data=0;
    for (integer a=0; a<4; a=a+1) begin cfg_w_addr=a; tick(); end
    cfg_w_addr=1; cfg_w_data=8'd20; tick();
    cfg_w_wr_en=0; tick();
    w_mon_addr=1; w_mon_rd_en=1; tick();
    w_mon_rd_en=0; tick(); #1;
    initial_weight=w_mon_data;
    check(initial_weight==8'd20, "configuration interface initializes W[0,1] to 20");

    // External source 0 is routed to neuron 1 using the initialized weight.
    ext_aer_neuron_id=0; ext_aer_req=1;
    timeout=0;
    while (!ext_aer_ack && timeout<100) begin tick(); timeout=timeout+1; end
    check(ext_aer_ack, "external AER event completes internal fanout");
    ext_aer_req=0; tick();

    // The driven neuron spikes; queued pre/post events run through STDP.
    timeout=0;
    while (!(neuron_spikes[1]) && timeout<100) begin tick(); timeout=timeout+1; end
    check(neuron_spikes[1], "weighted routed event makes neuron 1 spike");
    timeout=0;
    while (!stdp_ready && timeout<1000) begin tick(); timeout=timeout+1; end
    check(stdp_ready, "STDP pair scans finish without queue overflow");
    check(!stdp_event_overflow, "STDP event queue does not overflow");

    w_mon_addr=1; w_mon_rd_en=1; tick();
    w_mon_rd_en=0; tick(); #1;
    check(w_mon_data > initial_weight, "post spike potentiates W[0,1] through STDP");
    $display("RESULT: PASS initial_weight=%0d trained_weight=%0d", initial_weight, w_mon_data);
    #10 $finish;
  end
endmodule
