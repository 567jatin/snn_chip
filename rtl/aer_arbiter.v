`timescale 1ns / 1ps

module aer_arbiter #(
    parameter NUM_INPUTS = 64,
    parameter N_BITS     = 6
)(
    input  wire [NUM_INPUTS-1:0]            req_in,
    input  wire [NUM_INPUTS*N_BITS-1:0]     addr_in,
    output reg  [NUM_INPUTS-1:0]            ack_out,

    output reg                              aer_req,
    output reg  [N_BITS-1:0]                aer_addr,
    input  wire                             aer_ack
);

    localparam IDLE   = 2'b00;
    localparam GRANT  = 2'b01;
    localparam WAIT   = 2'b10;

    reg [1:0] state;
    reg [$clog2(NUM_INPUTS)-1:0] ptr;
    reg [$clog2(NUM_INPUTS)-1:0] winner;

    integer k;
    reg found;

    always @(*) begin
        found  = 1'b0;
        winner = ptr;
        for (k = 0; k < NUM_INPUTS; k = k + 1) begin
            if (!found && req_in[(ptr + k) % NUM_INPUTS]) begin
                winner = (ptr + k) % NUM_INPUTS;
                found  = 1'b1;
            end
        end
    end

    always @(posedge found or posedge aer_ack) begin
        case (state)
            IDLE: begin
                if (found) begin
                    aer_addr        <= addr_in[winner*N_BITS +: N_BITS];
                    aer_req         <= 1'b1;
                    ack_out[winner] <= 1'b1;
                    state           <= GRANT;
                end
            end
            GRANT: begin
                ack_out <= {NUM_INPUTS{1'b0}};
                state   <= WAIT;
            end
            WAIT: begin
                aer_req <= 1'b0;
                ptr     <= (winner + 1) % NUM_INPUTS;
                state   <= IDLE;
            end
            default: begin
                state   <= IDLE;
                aer_req <= 1'b0;
                ack_out <= {NUM_INPUTS{1'b0}};
            end
        endcase
    end

endmodule
