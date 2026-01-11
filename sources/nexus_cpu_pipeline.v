`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// CPU Core Module
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module nexus_cpu_pipeline(
    input clk,
    input rst,
    input sel_in,                    // Program loading mode
    input [15:0] from_memory,        // Data from memory
    output [15:0] to_memory,         // Data to memory
    output [15:0] address,           // Memory address
    output write_en,                 // Memory write enable
    // Test outputs
    output [15:0] test_pc,
    output [15:0] test_sp,
    output [15:0] test_ar,
    output [15:0] test_dr,
    output [15:0] test_ir,
    output [3:0] test_flags,
    // Debug registers
    output [15:0] test_r0,
    output [15:0] test_r1,
    output [15:0] test_r2
);

    // Internal connections
    wire [15:0] dp_pc;
    wire [15:0] dp_data_out;
    wire dp_mem_write;
    wire dp_mem_read;
    wire [15:0] dp_mem_addr;
    wire [3:0] dp_flags;
    wire dp_halted;
    
    // Memory operation flags from Datapath
    wire dp_is_load;
    wire dp_is_store;
    
    // NOP Logic
    reg mem_nop_cycle;
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mem_nop_cycle <= 1'b0;
        end else begin
            mem_nop_cycle <= dp_is_load || dp_is_store;
        end
    end
    
    wire insert_nop = sel_in || dp_halted || mem_nop_cycle;
    
    nexus_datapath pipeline_dp (
        .clk(clk),
        .rst(rst),
        .instruction_in( insert_nop ? 16'hFFFF : from_memory ),
        .data_in(from_memory),
        
        .pc_out(dp_pc),
        .data_out(dp_data_out),
        .mem_write(dp_mem_write),
        .mem_read(dp_mem_read),
        .mem_addr(dp_mem_addr),
        
        .is_load_out(dp_is_load),
        .is_store_out(dp_is_store),
        
        .debug_pc(test_pc),
        .debug_ir(test_ir),
        .debug_r0(test_r0),
        .debug_r1(test_r1),
        .debug_r2(test_r2),
        .debug_flags(dp_flags),
        .debug_halted(dp_halted)
    );
    
    assign test_flags = dp_flags;
    assign test_sp = 16'hFFFE; 
    
    assign address = (dp_mem_read || dp_mem_write) ? dp_mem_addr : dp_pc;
    assign to_memory = dp_data_out;
    assign write_en = dp_mem_write;
    
    assign test_ar = address;
    assign test_dr = to_memory;

endmodule
