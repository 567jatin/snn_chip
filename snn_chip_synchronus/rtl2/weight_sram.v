`timescale 1ns / 1ps

// Weight-memory wrapper. Simulation uses a behavioral model; synthesis with
// SYNTHESIS defined uses eight SKY130 1RW1R 1024x8 macros (4096x16 total).
module weight_sram #(
    parameter DEPTH     = 4096,
    parameter WIDTH     = 16,
    parameter ADDR_BITS = 12
)(
    input  wire                 clk,
    input  wire                 rst_n,

    input  wire                 a_wr_en,
    input  wire                 a_rd_en,
    input  wire [ADDR_BITS-1:0] a_addr,
    input  wire [WIDTH-1:0]     a_wr_data,
    output reg  [WIDTH-1:0]     a_rd_data,
    output wire                 a_ready,

    input  wire                 b_wr_en,
    input  wire                 b_rd_en,
    input  wire [ADDR_BITS-1:0] b_addr,
    input  wire [WIDTH-1:0]     b_wr_data,
    output reg  [WIDTH-1:0]     b_rd_data,
    output wire                 b_ready,
    input  wire                 r_rd_en,
    input  wire [ADDR_BITS-1:0] r_addr,
    output reg  [WIDTH-1:0]     r_rd_data,
    output wire                 r_ready
`ifdef USE_POWER_PINS
    , inout wire                VPWR,
    inout wire                VGND
`endif
);

    // The macro has one RW port. Configuration wins collisions; STDP holds
    // its request until b_ready. STDP reads take priority over monitor reads.
    wire a_wr_grant = a_wr_en;
    wire b_wr_grant = b_wr_en && !a_wr_en;
    wire b_rd_grant = b_rd_en && !a_wr_en && !b_wr_en;
    wire a_rd_grant = a_rd_en && !a_wr_en && !b_wr_en && !b_rd_en;
    wire [ADDR_BITS-1:0] rw_selected_addr = a_wr_grant ? a_addr : b_addr;
    wire rw_write_grant = a_wr_grant || b_wr_grant;
    wire r_grant = r_rd_en && !(rw_write_grant && (rw_selected_addr == r_addr));
    assign a_ready = !a_rd_en || a_rd_grant;
    assign b_ready = b_wr_en ? b_wr_grant :
                     b_rd_en ? b_rd_grant : 1'b1;
    assign r_ready = !r_rd_en || r_grant;

`ifdef SYNTHESIS
    // Production configuration is 4096x16. Four 1024-word banks are built
    // from pairs of 8-bit macros. Macro liberty files provide synthesis/STA
    // timing; do not read the behavioral macro model into Yosys.
    wire [7:0] rw_lo [0:3], rw_hi [0:3], r_lo [0:3], r_hi [0:3];
    reg [1:0] rw_bank_q, r_bank_q;
    wire [WIDTH-1:0] rw_data_mux = {rw_hi[rw_bank_q], rw_lo[rw_bank_q]};
    wire [WIDTH-1:0] r_data_mux = {r_hi[r_bank_q], r_lo[r_bank_q]};
    wire rw_en = a_wr_grant || b_wr_grant || b_rd_grant || a_rd_grant;
    wire rw_we = a_wr_grant || b_wr_grant;
    reg rw_read_pending, r_read_pending;
    wire [ADDR_BITS-1:0] rw_addr = a_wr_grant ? a_addr :
                                      b_wr_grant ? b_addr :
                                      b_rd_grant ? b_addr : a_addr;
    wire [WIDTH-1:0] rw_wdata = a_wr_grant ? a_wr_data : b_wr_data;

    always @(posedge clk) begin
        if (!rst_n) begin
            rw_bank_q <= 0;
            r_bank_q <= 0;
            rw_read_pending <= 1'b0;
            r_read_pending <= 1'b0;
            a_rd_data <= {WIDTH{1'b0}};
            b_rd_data <= {WIDTH{1'b0}};
            r_rd_data <= {WIDTH{1'b0}};
        end else begin
            if (rw_en) rw_bank_q <= rw_addr[11:10];
            if (r_grant) r_bank_q <= r_addr[11:10];
            // Macro read outputs launch on the falling edge in the SKY130
            // Liberty view. Capture them at the next rising edge so the
            // consumers see a registered, full-cycle return path.
            if (rw_read_pending) begin
                a_rd_data <= rw_data_mux;
                b_rd_data <= rw_data_mux;
            end
            if (r_read_pending)
                r_rd_data <= r_data_mux;
            rw_read_pending <= a_rd_grant || b_rd_grant;
            r_read_pending <= r_grant;
        end
    end

    genvar bank;
    generate for (bank = 0; bank < 4; bank = bank + 1) begin: g_bank
        sky130_sram_1kbyte_1rw1r_8x1024_8 u_lo (
`ifdef USE_POWER_PINS
            .vccd1(VPWR), .vssd1(VGND),
`endif
            .clk0(clk), .csb0(!(rw_en && rw_addr[11:10] == bank)),
            .web0(!rw_we), .\wmask0[0] (1'b1), .addr0(rw_addr[9:0]),
            .din0(rw_wdata[7:0]), .dout0(rw_lo[bank]),
            .clk1(clk), .csb1(!(r_grant && r_addr[11:10] == bank)),
            .addr1(r_addr[9:0]), .dout1(r_lo[bank])
        );
        sky130_sram_1kbyte_1rw1r_8x1024_8 u_hi (
`ifdef USE_POWER_PINS
            .vccd1(VPWR), .vssd1(VGND),
`endif
            .clk0(clk), .csb0(!(rw_en && rw_addr[11:10] == bank)),
            .web0(!rw_we), .\wmask0[0] (1'b1), .addr0(rw_addr[9:0]),
            .din0(rw_wdata[15:8]), .dout0(rw_hi[bank]),
            .clk1(clk), .csb1(!(r_grant && r_addr[11:10] == bank)),
            .addr1(r_addr[9:0]), .dout1(r_hi[bank])
        );
    end endgenerate
`else
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [WIDTH-1:0] rw_read_pipe, r_read_pipe;
    reg rw_read_pending, r_read_pending;
    always @(posedge clk) begin
        if (!rst_n) begin
            a_rd_data <= {WIDTH{1'b0}};
            b_rd_data <= {WIDTH{1'b0}};
            r_rd_data <= {WIDTH{1'b0}};
            rw_read_pipe <= {WIDTH{1'b0}};
            r_read_pipe <= {WIDTH{1'b0}};
            rw_read_pending <= 1'b0;
            r_read_pending <= 1'b0;
        end else begin
            if (rw_read_pending) begin
                a_rd_data <= rw_read_pipe;
                b_rd_data <= rw_read_pipe;
            end
            if (r_read_pending)
                r_rd_data <= r_read_pipe;
            rw_read_pending <= a_rd_grant || b_rd_grant;
            r_read_pending <= r_grant;
            if (a_wr_grant)
                mem[a_addr] <= a_wr_data;
            else if (b_wr_grant)
                mem[b_addr] <= b_wr_data;
            if (b_rd_grant)
                rw_read_pipe <= mem[b_addr];
            else if (a_rd_grant)
                rw_read_pipe <= mem[a_addr];
            if (r_grant)
                r_read_pipe <= mem[r_addr];
        end
    end
`endif
endmodule
