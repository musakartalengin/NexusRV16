`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// RAM Module (32K x 16-bit = 64KB)
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module nexus_ram #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 15
)(
    input clk,
    input we,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];
    
    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            memory[i] = {DATA_WIDTH{1'b0}};
        end
    end
    
    always @(posedge clk) begin
        if (we) begin
            memory[addr] <= din;
        end
        dout <= memory[addr];
    end

endmodule
