`timescale 1ns / 1ps

module lif_neuron_event #(
    parameter DATA_WIDTH  = 16,
    parameter TIMER_WIDTH = 16,

    parameter signed [DATA_WIDTH-1:0] V_THRESH = 16'sd1000,
    parameter signed [DATA_WIDTH-1:0] V_RESET  = 16'sd0,

    parameter integer LEAK_SHIFT = 3
)(
    input  wire                         clk,
    input  wire                         rst_n,

    input  wire                         syn_valid,
    input  wire signed [DATA_WIDTH-1:0] syn_current,

    output reg                          spike_out,
    output reg signed [DATA_WIDTH-1:0]  v_mem
);

    localparam IDLE  = 1'b0;
    localparam EVENT = 1'b1;

    reg state;

    reg [TIMER_WIDTH-1:0] timer;
    reg [TIMER_WIDTH-1:0] last_event_time;
    reg [TIMER_WIDTH-1:0] elapsed_time;

    reg signed [DATA_WIDTH-1:0] v_leaked;
    reg signed [DATA_WIDTH-1:0] v_next;

    always @(posedge clk) begin
        if (!rst_n) begin
            state           <= IDLE;
            timer           <= {TIMER_WIDTH{1'b0}};
            last_event_time <= {TIMER_WIDTH{1'b0}};
            elapsed_time    <= {TIMER_WIDTH{1'b0}};
            v_mem           <= V_RESET;
            spike_out       <= 1'b0;
            v_leaked        <= V_RESET;
            v_next          <= V_RESET;
        end
        else begin
            timer     <= timer + 1'b1;
            spike_out <= 1'b0;

            if (state == IDLE) begin
                if (syn_valid)
                    state <= EVENT;
            end
            else begin
                elapsed_time    <= timer - last_event_time;
                last_event_time <= timer;

                v_leaked <= v_mem - (v_mem >>> LEAK_SHIFT);
                v_next   <= v_mem - (v_mem >>> LEAK_SHIFT) + syn_current;

                if (v_mem - (v_mem >>> LEAK_SHIFT) + syn_current >= V_THRESH) begin
                    spike_out <= 1'b1;
                    v_mem     <= V_RESET;
                end
                else begin
                    v_mem <= v_mem - (v_mem >>> LEAK_SHIFT) + syn_current;
                end

                state <= IDLE;
            end
        end
    end

endmodule
