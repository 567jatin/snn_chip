`timescale 1ns / 1ps

module trace_mem_async #(
    parameter DEPTH     = 64,
    parameter WIDTH     = 16,
    parameter ADDR_BITS = 6
)(
    input  wire              rst_n,
    input  wire              wr_en,
    input  wire [ADDR_BITS-1:0] wr_addr,
    input  wire [WIDTH-1:0]     wr_data,
    input  wire [ADDR_BITS-1:0] rd_addr,
    output wire [WIDTH-1:0]     rd_data
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = {WIDTH{1'b0}};
    end

    assign rd_data = mem[rd_addr];

    always @(posedge wr_en or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= {WIDTH{1'b0}};
        end else begin
            mem[wr_addr] <= wr_data;
        end
    end

endmodule
