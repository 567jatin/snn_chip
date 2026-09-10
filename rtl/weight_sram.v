`timescale 1ns / 1ps

module weight_sram #(
    parameter DEPTH     = 4096,
    parameter WIDTH     = 16,
    parameter ADDR_BITS = 12
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [ADDR_BITS-1:0]  addr,
    input  wire [WIDTH-1:0]      wr_data,
    output reg  [WIDTH-1:0]      rd_data,

    input  wire [ADDR_BITS-1:0]  async_rd_addr,
    output wire [WIDTH-1:0]      async_rd_data,
    input  wire                  async_wr_en,
    input  wire [ADDR_BITS-1:0]  async_wr_addr,
    input  wire [WIDTH-1:0]      async_wr_data
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];

    integer i;

    assign async_rd_data = mem[async_rd_addr];

    always @(posedge clk) begin
        if (!rst_n) begin
            rd_data <= {WIDTH{1'b0}};
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= {WIDTH{1'b0}};
        end else begin
            if (wr_en)
                mem[addr] <= wr_data;

            if (rd_en)
                rd_data <= mem[addr];
        end
    end

    always @(posedge async_wr_en) begin
        if (rst_n)
            mem[async_wr_addr] <= async_wr_data;
    end

endmodule
