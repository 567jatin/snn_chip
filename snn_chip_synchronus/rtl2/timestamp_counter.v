`timescale 1ns / 1ps

module timestamp_counter #(
    parameter WIDTH = 16
)(
    input  wire              clk,
    input  wire              rst_n,
    output reg  [WIDTH-1:0]  timestamp
);

    always @(posedge clk) begin
        if (!rst_n)
            timestamp <= {WIDTH{1'b0}};
        else
            timestamp <= timestamp + 1'b1;
    end

endmodule
