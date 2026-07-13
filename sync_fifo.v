`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2026 09:38:13
// Design Name: 
// Module Name: sync_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8
)(
    input  wire                    clk,
    input  wire                    rst_n,

    input  wire                    wr_en,
    input  wire [DATA_WIDTH-1:0]   data_in,

    input  wire                    rd_en,
    output reg  [DATA_WIDTH-1:0]   data_out,

    output wire                    full,
    output wire                    empty,
    output wire                    almost_full,
    output wire                    almost_empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    wire [ADDR_WIDTH-1:0] wr_addr = wr_ptr[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] rd_addr = rd_ptr[ADDR_WIDTH-1:0];

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_addr == rd_addr) &&
                   (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);

    wire [ADDR_WIDTH:0] entries_used = wr_ptr - rd_ptr;
    assign almost_full  = (entries_used == DEPTH - 1);
    assign almost_empty = (entries_used == 1);

    always @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_addr] <= data_in;
            wr_ptr       <= wr_ptr + 1'b1;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            rd_ptr   <= 0;
            data_out <= 0;
        end else if (rd_en && !empty) begin
            data_out <= mem[rd_addr];
            rd_ptr   <= rd_ptr + 1'b1;
        end
    end

endmodule