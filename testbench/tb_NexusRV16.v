`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// Comprehensive Verification Testbench
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module tb_NexusRV16;

    reg clk;
    reg rst;
    reg sel_in;
    reg [15:0] ext_addr;
    reg [15:0] ext_data_in;
    reg ext_write_en;
    
    wire [15:0] ext_data_out;
    wire [15:0] test_pc;
    wire [15:0] test_sp;
    wire [15:0] test_ar;
    wire [15:0] test_dr;
    wire [15:0] test_ir;
    wire [3:0] test_flags;
    
    integer pass_count;
    integer fail_count;

    NexusRV16 dut (
        .clk(clk),
        .rst(rst),
        .sel_in(sel_in),
        .ext_addr(ext_addr),
        .ext_data_in(ext_data_in),
        .ext_data_out(ext_data_out),
        .ext_write_en(ext_write_en),
        .test_pc(test_pc),
        .test_sp(test_sp),
        .test_ar(test_ar),
        .test_dr(test_dr),
        .test_ir(test_ir),
        .test_flags(test_flags)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        sel_in = 1;
        ext_addr = 0;
        ext_data_in = 0;
        ext_write_en = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("");
        $display("================================================================");
        $display("  NexusRV16 - 16-bit Pipelined RISC Processor");
        $display("  Comprehensive Verification Testbench");
        $display("================================================================");
        $display("");
        
        #100;
        rst = 1;
        
        //=================================================================
        // TEST 1: ALU ARITHMETIC
        //=================================================================
        $display("--- TEST 1: ALU Arithmetic (LDI, ADD, SUB) ---");
        
        @(negedge clk); sel_in = 1; ext_write_en = 1;
        ext_addr = 16'h0100; ext_data_in = 16'hA00A; @(negedge clk);
        ext_addr = 16'h0102; ext_data_in = 16'hA105; @(negedge clk);
        ext_addr = 16'h0104; ext_data_in = 16'h0012; @(negedge clk);
        ext_addr = 16'h0106; ext_data_in = 16'h1013; @(negedge clk);
        ext_addr = 16'h0108; ext_data_in = 16'hFE00; @(negedge clk);
        
        ext_write_en = 0; sel_in = 0;
        rst = 0; @(negedge clk); @(negedge clk); rst = 1;
        #300;
        
        if (dut.cpu.pipeline_dp.reg_file.registers[0] == 16'h000A) begin
            $display("  [PASS] LDI R0=#10"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] LDI R0"); fail_count = fail_count + 1;
        end
        
        if (dut.cpu.pipeline_dp.reg_file.registers[2] == 16'h000F) begin
            $display("  [PASS] ADD R0+R1=15"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] ADD"); fail_count = fail_count + 1;
        end
        
        if (dut.cpu.pipeline_dp.reg_file.registers[3] == 16'h0005) begin
            $display("  [PASS] SUB R0-R1=5"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] SUB"); fail_count = fail_count + 1;
        end
        
        $display("");
        
        //=================================================================
        // TEST 2: LOGICAL OPERATIONS
        //=================================================================
        $display("--- TEST 2: Logical Operations (AND, OR, XOR) ---");
        
        @(negedge clk); sel_in = 1; ext_write_en = 1;
        ext_addr = 16'h0100; ext_data_in = 16'hA0FF; @(negedge clk);
        ext_addr = 16'h0102; ext_data_in = 16'hA10F; @(negedge clk);
        ext_addr = 16'h0104; ext_data_in = 16'h2012; @(negedge clk);
        ext_addr = 16'h0106; ext_data_in = 16'h3013; @(negedge clk);
        ext_addr = 16'h0108; ext_data_in = 16'h4014; @(negedge clk);
        ext_addr = 16'h010A; ext_data_in = 16'hFE00; @(negedge clk);
        
        ext_write_en = 0; sel_in = 0;
        rst = 0; @(negedge clk); @(negedge clk); rst = 1;
        #300;
        
        if (dut.cpu.pipeline_dp.reg_file.registers[2] == 16'h000F) begin
            $display("  [PASS] AND"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] AND"); fail_count = fail_count + 1;
        end
        
        if (dut.cpu.pipeline_dp.reg_file.registers[3] == 16'hFFFF) begin
            $display("  [PASS] OR"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] OR"); fail_count = fail_count + 1;
        end
        
        if (dut.cpu.pipeline_dp.reg_file.registers[4] == 16'hFFF0) begin
            $display("  [PASS] XOR"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] XOR"); fail_count = fail_count + 1;
        end
        
        $display("");
        
        //=================================================================
        // TEST 3: SHIFT OPERATIONS
        //=================================================================
        $display("--- TEST 3: Shift Operations (SHL, SHR) ---");
        
        @(negedge clk); sel_in = 1; ext_write_en = 1;
        ext_addr = 16'h0100; ext_data_in = 16'hA001; @(negedge clk);
        ext_addr = 16'h0102; ext_data_in = 16'hA104; @(negedge clk);
        ext_addr = 16'h0104; ext_data_in = 16'h6012; @(negedge clk);
        ext_addr = 16'h0106; ext_data_in = 16'hA380; @(negedge clk);
        ext_addr = 16'h0108; ext_data_in = 16'h7314; @(negedge clk);
        ext_addr = 16'h010A; ext_data_in = 16'hFE00; @(negedge clk);
        
        ext_write_en = 0; sel_in = 0;
        rst = 0; @(negedge clk); @(negedge clk); rst = 1;
        #300;
        
        if (dut.cpu.pipeline_dp.reg_file.registers[2] == 16'h0010) begin
            $display("  [PASS] SHL 1<<4=16"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] SHL"); fail_count = fail_count + 1;
        end
        
        if (dut.cpu.pipeline_dp.reg_file.registers[4] == 16'h0FF8) begin
            $display("  [PASS] SHR"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] SHR"); fail_count = fail_count + 1;
        end
        
        $display("");
        
        //=================================================================
        // TEST 4: MEMORY OPERATIONS (STR/LDR)
        //=================================================================
        $display("--- TEST 4: Memory Operations (STR/LDR) ---");
        
        @(negedge clk); sel_in = 1; ext_write_en = 1;
        ext_addr = 16'h0100; ext_data_in = 16'hA0AB; @(negedge clk);
        ext_addr = 16'h0102; ext_data_in = 16'hC050; @(negedge clk);
        ext_addr = 16'h0104; ext_data_in = 16'hFFFF; @(negedge clk);
        ext_addr = 16'h0106; ext_data_in = 16'hFFFF; @(negedge clk); // Wait for bus
        ext_addr = 16'h0108; ext_data_in = 16'hB150; @(negedge clk);
        ext_addr = 16'h010A; ext_data_in = 16'hFFFF; @(negedge clk);
        ext_addr = 16'h010C; ext_data_in = 16'hFFFF; @(negedge clk);
        ext_addr = 16'h010E; ext_data_in = 16'hFE00; @(negedge clk);
        
        ext_write_en = 0; sel_in = 0;
        rst = 0; @(negedge clk); @(negedge clk); rst = 1;
        #500;
        
        if (dut.cpu.pipeline_dp.reg_file.registers[0] == 16'hFFAB) begin
            $display("  [PASS] LDI R0=0xFFAB"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] LDI R0"); fail_count = fail_count + 1;
        end
        
        if (dut.cpu.pipeline_dp.reg_file.registers[1] == 16'hFFAB) begin
            $display("  [PASS] STR/LDR M[50]->R1"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] STR/LDR"); fail_count = fail_count + 1;
        end
        
        $display("");
        
        //=================================================================
        // TEST 5: BRANCH - BEQ
        //=================================================================
        $display("--- TEST 5: Branch BEQ ---");
        
        @(negedge clk); sel_in = 1; ext_write_en = 1;
        ext_addr = 16'h0100; ext_data_in = 16'hA000; @(negedge clk);
        ext_addr = 16'h0102; ext_data_in = 16'hA100; @(negedge clk);
        ext_addr = 16'h0104; ext_data_in = 16'h1012; @(negedge clk); // ADD -> Z Flag
        ext_addr = 16'h0106; ext_data_in = 16'hE404; @(negedge clk); // BEQ +4
        ext_addr = 16'h0108; ext_data_in = 16'hA399; @(negedge clk);
        ext_addr = 16'h010A; ext_data_in = 16'hA444; @(negedge clk);
        ext_addr = 16'h010C; ext_data_in = 16'hFE00; @(negedge clk);
        
        ext_write_en = 0; sel_in = 0;
        rst = 0; @(negedge clk); @(negedge clk); rst = 1;
        #400;
        
        if (dut.cpu.pipeline_dp.reg_file.registers[3] != 16'h0099 &&
            dut.cpu.pipeline_dp.reg_file.registers[4] == 16'h0044) begin
            $display("  [PASS] BEQ taken"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] BEQ"); fail_count = fail_count + 1;
        end
        
        $display("");
        
        //=================================================================
        // TEST 6: BRANCH - JMP
        //=================================================================
        $display("--- TEST 6: Branch JMP ---");
        
        @(negedge clk); sel_in = 1; ext_write_en = 1;
        ext_addr = 16'h0100; ext_data_in = 16'hA555; @(negedge clk);
        ext_addr = 16'h0102; ext_data_in = 16'hE004; @(negedge clk); // JMP +4
        ext_addr = 16'h0104; ext_data_in = 16'hA6EE; @(negedge clk);
        ext_addr = 16'h0106; ext_data_in = 16'hA777; @(negedge clk);
        ext_addr = 16'h0108; ext_data_in = 16'hFE00; @(negedge clk);
        
        ext_write_en = 0; sel_in = 0;
        rst = 0; @(negedge clk); @(negedge clk); rst = 1;
        #300;
        
        if (dut.cpu.pipeline_dp.reg_file.registers[6] != 16'h00EE &&
            dut.cpu.pipeline_dp.reg_file.registers[7] == 16'h0077) begin
            $display("  [PASS] JMP taken"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] JMP"); fail_count = fail_count + 1;
        end
        
        $display("");
        
        //=================================================================
        // TEST 7: BRANCH - BNE
        //=================================================================
        $display("--- TEST 7: Branch BNE ---");
        
        @(negedge clk); sel_in = 1; ext_write_en = 1;
        ext_addr = 16'h0100; ext_data_in = 16'hA005; @(negedge clk);
        ext_addr = 16'h0102; ext_data_in = 16'hA103; @(negedge clk);
        ext_addr = 16'h0104; ext_data_in = 16'h1012; @(negedge clk); // ADD = 8 (Not Zero)
        ext_addr = 16'h0106; ext_data_in = 16'hE804; @(negedge clk); // BNE +4
        ext_addr = 16'h0108; ext_data_in = 16'hA333; @(negedge clk);
        ext_addr = 16'h010A; ext_data_in = 16'hA411; @(negedge clk);
        ext_addr = 16'h010C; ext_data_in = 16'hFE00; @(negedge clk);
        
        ext_write_en = 0; sel_in = 0;
        rst = 0; @(negedge clk); @(negedge clk); rst = 1;
        #400;
        
        if (dut.cpu.pipeline_dp.reg_file.registers[3] != 16'h0033 &&
            dut.cpu.pipeline_dp.reg_file.registers[4] == 16'h0011) begin
            $display("  [PASS] BNE taken"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] BNE"); fail_count = fail_count + 1;
        end
        
        $display("");
        
        //=================================================================
        // TEST 8: HLT
        //=================================================================
        $display("--- TEST 8: HLT Instruction ---");
        
        if (dut.cpu.pipeline_dp.halted == 1) begin
            $display("  [PASS] HLT executed"); pass_count = pass_count + 1;
        end else begin
            $display("  [FAIL] HLT"); fail_count = fail_count + 1;
        end
        
        $display("");
        $display("================================================================");
        $display("  TEST SUMMARY");
        $display("================================================================");
        $display("  Passed : %0d", pass_count);
        $display("  Failed : %0d", fail_count);
        $display("  Total  : %0d", pass_count + fail_count);
        $display("================================================================");
        
        if (fail_count == 0) begin
            $display("");
            $display("  *** ALL TESTS PASSED! ***");
            $display("  NexusRV16 Pipeline Processor fully operational.");
        end else begin
            $display("");
            $display("  !!! SOME TESTS FAILED !!!");
        end
        
        $display("");
        $finish;
    end

endmodule
