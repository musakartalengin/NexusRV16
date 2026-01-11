`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// Pipeline Control Module
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module nexus_control(
    input load_use_hazard,      // 1 if load-use data dependency
    input branch_taken,         // 1 if branch taken
    input mem_access,           // 1 if memory access active (unused here now)
    
    // Control outputs
    output reg if_de_stall,
    output reg if_de_flush,
    output reg pc_stall
    );
    
    always @(*) begin
        // Default values
        if_de_stall = 1'b0;
        if_de_flush = 1'b0;
        pc_stall    = 1'b0;
        
        // Memory Stall Logic
        // DISABLED: Handled by NOP insertion in nexus_cpu_pipeline
        // if (mem_access) begin
        //    pc_stall    = 1'b1;
        //    if_de_flush = 1'b1;
        // end
        
        // Data Hazard (Load-Use) Logic
        if (load_use_hazard) begin
            if_de_stall = 1'b1;
            pc_stall    = 1'b1;
        end 
        
        // Control Hazard (Branch) Logic
        else if (branch_taken) begin
            if_de_flush = 1'b1;
        end
    end
endmodule
