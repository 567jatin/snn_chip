`timescale 1ns / 1ps

module aer_encoder #(
    parameter N_BITS = 6
)(
    input  wire                 spike_in,
    input  wire [N_BITS-1:0]    neuron_id,
    output reg                  aer_req,
    output reg  [N_BITS-1:0]    aer_addr,
    input  wire                 aer_ack
);

    localparam IDLE    = 2'b00;
    localparam REQ_HI  = 2'b01;
    localparam WAIT_LO = 2'b10;

    reg [1:0] state;

    always @(posedge spike_in or posedge aer_ack) begin
        case (state)
            IDLE: begin
                aer_addr <= neuron_id;
                aer_req  <= 1'b1;
                state    <= REQ_HI;
            end
            REQ_HI: begin
                aer_req <= 1'b0;
                state   <= WAIT_LO;
            end
            WAIT_LO: begin
                state <= IDLE;
            end
            default: begin
                state   <= IDLE;
                aer_req <= 1'b0;
            end
        endcase
    end

endmodule
