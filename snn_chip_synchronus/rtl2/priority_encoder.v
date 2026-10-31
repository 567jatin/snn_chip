`timescale 1ns / 1ps

// Recursive balanced first-set-bit encoder. The lowest asserted bit wins.
module priority_encoder #(
    parameter WIDTH = 64,
    parameter INDEX_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
)(
    input  wire [WIDTH-1:0]       request,
    output wire                   valid,
    output wire [INDEX_WIDTH-1:0] index
);
    generate
        if (WIDTH == 1) begin : gen_one_bit
            assign valid = request[0];
            assign index = {INDEX_WIDTH{1'b0}};
        end else begin : gen_tree
            localparam LOW_WIDTH = (WIDTH + 1) / 2;
            localparam HIGH_WIDTH = WIDTH - LOW_WIDTH;
            localparam LOW_INDEX_WIDTH = (LOW_WIDTH > 1) ? $clog2(LOW_WIDTH) : 1;
            localparam HIGH_INDEX_WIDTH = (HIGH_WIDTH > 1) ? $clog2(HIGH_WIDTH) : 1;

            wire low_valid;
            wire high_valid;
            wire [LOW_INDEX_WIDTH-1:0] low_index;
            wire [HIGH_INDEX_WIDTH-1:0] high_index;

            priority_encoder #(
                .WIDTH(LOW_WIDTH),
                .INDEX_WIDTH(LOW_INDEX_WIDTH)
            ) u_low (
                .request(request[LOW_WIDTH-1:0]),
                .valid(low_valid),
                .index(low_index)
            );

            priority_encoder #(
                .WIDTH(HIGH_WIDTH),
                .INDEX_WIDTH(HIGH_INDEX_WIDTH)
            ) u_high (
                .request(request[WIDTH-1:LOW_WIDTH]),
                .valid(high_valid),
                .index(high_index)
            );

            assign valid = low_valid | high_valid;
            assign index = low_valid ? low_index : (LOW_WIDTH + high_index);
        end
    endgenerate
endmodule
