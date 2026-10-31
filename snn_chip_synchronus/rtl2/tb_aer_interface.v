`timescale 1ns/1ps
module aer_interface_tb;
  localparam N=4, NB=2, DW=8, AW=4;
  reg clk=0, rst_n=0;
  always #5 clk=~clk;

  reg in_req=0;
  reg [NB-1:0] in_neuron_id=0;
  wire in_ack, pre_event;
  wire [NB-1:0] pre_event_id;
  wire weight_rd_req;
  wire [AW-1:0] weight_rd_addr;
  reg [DW-1:0] weight_rd_data=0;
  reg [DW-1:0] weights[0:(1<<AW)-1];
  wire [N-1:0] syn_valid;
  wire [DW-1:0] syn_weight;
  reg [N-1:0] spike_in=0;
  wire out_req;
  wire [NB-1:0] out_addr;
  reg out_ack=0;
  wire out_overflow;
  integer errors=0;
  reg [N-1:0] observed_targets;
  integer timeout;

  always @(posedge clk)
    if (weight_rd_req) weight_rd_data <= weights[weight_rd_addr];

  aer_interface #(.NUM_NEURONS(N), .N_BITS(NB), .DW(DW),
                  .W_ADDR_W(AW), .PENDING_DEPTH(2)) dut (
    .clk(clk), .rst_n(rst_n),
    .in_req(in_req), .in_neuron_id(in_neuron_id), .in_ack(in_ack),
    .pre_event(pre_event), .pre_event_id(pre_event_id),
    .weight_rd_req(weight_rd_req), .weight_rd_addr(weight_rd_addr),
    .weight_rd_ready(1'b1), .weight_rd_data(weight_rd_data),
    .syn_valid(syn_valid), .syn_weight(syn_weight), .spike_in(spike_in),
    .out_req(out_req), .out_addr(out_addr), .out_ack(out_ack),
    .out_overflow(out_overflow)
  );

  task tick; begin @(posedge clk); #1; end endtask
  task check(input condition, input [8*100-1:0] msg); begin
    if (!condition) begin $display("FAIL: %0s at %0t", msg, $time); errors=errors+1; end
    else $display("PASS: %0s at %0t", msg, $time);
  end endtask

  always @(posedge clk) begin
    if (rst_n && |syn_valid) observed_targets <= observed_targets | syn_valid;
  end

  initial begin
    $dumpfile("/tmp/aer_interface.vcd");
    $dumpvars(0, aer_interface_tb);
    observed_targets=0;
    for (integer k=0; k<(1<<AW); k=k+1) weights[k]=0;
    // Source 1 connects to targets 0, 2, 3; target 1 has no connection.
    weights[4]=8'h11; weights[6]=8'hA5; weights[7]=8'h33;
    // Source 2 connects to targets 0 and 2.
    weights[8]=8'h22; weights[10]=8'h44;

    repeat (2) tick();
    rst_n=1; tick();

    // External source spike must fan out through the initialized weight row.
    in_neuron_id=1; in_req=1;
    timeout=0;
    while (!in_ack && timeout<100) begin tick(); timeout=timeout+1; end
    tick();
    check(in_ack, "external AER source receives acknowledge after fanout");
    check(pre_event_id==1, "external source spike is reported to STDP event input");
    check(observed_targets==4'b1101, "source 1 reaches only nonzero-weight targets 0, 2, and 3");
    check(syn_weight==8'h33, "fanout presents each selected synaptic weight");
    in_req=0; tick();
    check(!in_ack, "external acknowledge drops after request drops");

    // An internal neuron spike uses the same router and also exits on AER.
    observed_targets=0;
    spike_in=4'b0100; tick(); spike_in=0;
    timeout=0;
    while (observed_targets != 4'b0101 && timeout<100) begin tick(); timeout=timeout+1; end
    check(observed_targets==4'b0101, "internal neuron 2 is routed to its connected targets 0 and 2");
    check(out_req && out_addr==2, "internal neuron spike is forwarded as outgoing AER ID 2");
    tick();
    check(out_req && out_addr==2, "outgoing request/address hold until acknowledge");
    out_ack=1; tick(); out_ack=0; tick();
    check(!out_req, "outgoing request drops after acknowledge");

    if (errors==0) $display("RESULT: PASS");
    else $display("RESULT: FAIL (%0d errors)", errors);
    #10 $finish;
  end
endmodule
