`timescale 1ns / 1ps

module neuron_array #(
    parameter NUM_NEURONS = 16,
    parameter DW          = 16,
    parameter TW          = 16,
    parameter signed [DW-1:0] V_THRESH = 16'sd1000,
    parameter signed [DW-1:0] V_RESET  = 16'sd0,
    parameter integer LEAK_SHIFT       = 3
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire [NUM_NEURONS-1:0]        syn_valid,
    input  wire [NUM_NEURONS*DW-1:0]     syn_current,
    output wire [NUM_NEURONS-1:0]        syn_ready,
    output wire [NUM_NEURONS-1:0]        spike_out
);

    genvar i;
    generate
        for (i = 0; i < NUM_NEURONS; i = i + 1) begin : n
            lif_neuron_event #(
                .DATA_WIDTH  (DW),
                .TIMER_WIDTH (TW),
                .V_THRESH    (V_THRESH),
                .V_RESET     (V_RESET),
                .LEAK_SHIFT  (LEAK_SHIFT)
            ) neuron (
                .clk         (clk),
                .rst_n       (rst_n),
                .syn_valid   (syn_valid[i]),
                .syn_current (syn_current[i*DW +: DW]),
                .syn_ready   (syn_ready[i]),
                .spike_out   (spike_out[i]),
                .v_mem       ()
            );
        end
    endgenerate

endmodule
