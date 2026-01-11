`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// Top-Level System Module (CPU + RAM)
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module NexusRV16(
    input clk,
    input rst,
    input sel_in,
    input [15:0] ext_addr,
    input [15:0] ext_data_in,
    output [15:0] ext_data_out,
    input ext_write_en,
    
    output [15:0] test_pc,
    output [15:0] test_sp,
    output [15:0] test_ar,
    output [15:0] test_dr,
    output [15:0] test_ir,
    output [3:0]  test_flags
);

    wire [15:0] cpu_address;
    wire [15:0] cpu_to_memory;
    wire [15:0] memory_to_cpu;
    wire cpu_write_en;
    
    wire [15:0] final_address;
    wire [15:0] final_data_in;
    wire final_write_en;
    
    assign final_address = (sel_in) ? ext_addr : cpu_address;
    assign final_data_in = (sel_in) ? ext_data_in : cpu_to_memory;
    assign final_write_en = (sel_in) ? ext_write_en : cpu_write_en;
    assign ext_data_out = memory_to_cpu;

    nexus_cpu_pipeline cpu (
        .clk(clk),
        .rst(rst),
        .sel_in(sel_in),
        .from_memory(memory_to_cpu),
        .to_memory(cpu_to_memory),
        .address(cpu_address),
        .write_en(cpu_write_en),
        .test_pc(test_pc),
        .test_sp(test_sp),
        .test_ar(test_ar),
        .test_dr(test_dr),
        .test_ir(test_ir),
        .test_flags(test_flags)
    );
    
    nexus_ram ram (
        .clk(clk),
        .we(final_write_en),
        .addr(final_address[14:0]),
        .din(final_data_in),
        .dout(memory_to_cpu)
    );

endmodule
