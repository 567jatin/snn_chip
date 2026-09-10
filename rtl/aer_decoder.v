`timescale 1ns / 1ps

module aer_decoder #(
    parameter NUM_NEURONS = 64,
    parameter N_BITS      = 6,
    parameter DW          = 16
)(
    input  wire                              clk,
    input  wire                              rst_n,

    input  wire                              aer_req,
    input  wire [N_BITS-1:0]                 aer_pre_id,
    input  wire [N_BITS-1:0]                 aer_post_id,
    input  wire [DW-1:0]                     syn_weight_in,
    output reg                               aer_ack,

    output reg  [NUM_NEURONS-1:0]            syn_valid,
    output reg  [NUM_NEURONS*DW-1:0]         syn_current
);

    localparam IDLE    = 2'b00;
    localparam DELIVER = 2'b01;
    localparam ACK     = 2'b10;

    reg [1:0] state;

    always @(posedge clk) begin
        if (!rst_n) begin
            state       <= IDLE;
            aer_ack     <= 1'b0;
            syn_valid   <= {NUM_NEURONS{1'b0}};
            syn_current <= {NUM_NEURONS*DW{1'b0}};
        end else begin
            case (state)
                IDLE: begin
                    aer_ack     <= 1'b0;
                    syn_valid   <= {NUM_NEURONS{1'b0}};
                    if (aer_req) begin
                        if (aer_post_id < NUM_NEURONS) begin
                            syn_valid[aer_post_id]             <= 1'b1;
                            syn_current[aer_post_id*DW +: DW] <= syn_weight_in;
                        end
                        state <= DELIVER;
                    end
                end

                DELIVER: begin
                    aer_ack <= 1'b1;
                    state   <= ACK;
                end

                ACK: begin
                    syn_valid <= {NUM_NEURONS{1'b0}};
                    if (!aer_req) begin
                        aer_ack <= 1'b0;
                        state   <= IDLE;
                    end
                end

                default: begin
                    state   <= IDLE;
                    aer_ack <= 1'b0;
                end
            endcase
        end
    end

endmodule
