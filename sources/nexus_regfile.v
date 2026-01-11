`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// 8x16-bit Register File (R0-R7)
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module nexus_regfile(
    input clk,
    input rst,
    input [2:0] read_reg1,
    input [2:0] read_reg2,
    input [2:0] write_reg,
    input [15:0] write_data,
    input write_enable,
    output [15:0] read_data1,
    output [15:0] read_data2
);

    reg [15:0] registers [0:7];
    
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            registers[0] <= 16'h0000;
            registers[1] <= 16'h0000;
            registers[2] <= 16'h0000;
            registers[3] <= 16'h0000;
            registers[4] <= 16'h0000;
            registers[5] <= 16'h0000;
            registers[6] <= 16'h0000;
            registers[7] <= 16'h0000;
        end
        else if (write_enable) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule
