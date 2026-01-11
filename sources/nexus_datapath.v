`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// Datapath Module
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module nexus_datapath(
    input clk,
    input rst,
    input [15:0] instruction_in,   // From Memory (IR_fetch)
    input [15:0] data_in,          // From Memory (Load Data)
    
    output [15:0] pc_out,          // To Memory (Address)
    output [15:0] data_out,        // To Memory (Store Data)
    output mem_write,              // Memory Write Enable
    output mem_read,               // Memory Read Enable
    output [15:0] mem_addr,        // Address for Load/Store
    
    // Memory operation flags (for NOP insertion logic)
    output is_load_out,
    output is_store_out,

    // Debug/Test outputs
    output [15:0] debug_pc,
    output [15:0] debug_ir,
    output [15:0] debug_r0,
    output [15:0] debug_r1,
    output [15:0] debug_r2,
    output [3:0]  debug_flags,
    output        debug_halted
    );

    // =====================================================
    // 2. PIPELINE STAGES & HAZARD CONTROL
    // =====================================================
    
    // Registers and Interconnects
    reg [15:0] pc;
    wire [15:0] pc_next;
    wire [15:0] branch_target;
    
    // Internal registers
    reg [3:0] flags_reg;
    
    // Pipeline control wires
    wire pc_stall;
    wire load_use_hazard;
    wire branch_taken;
    wire if_de_stall; 
    wire if_de_flush; 

    // Wires for inter-stage signals
    wire [2:0] reg_read_addr1;
    wire [2:0] reg_read_addr2;
    wire [2:0] reg_write_addr;
    wire reg_write_en;
    wire [15:0] reg_data1;
    wire [15:0] reg_data2;
    wire [15:0] alu_result;
    wire [3:0] alu_flags;

    // Branch Flush Logic
    reg flush_flop;
    always @(posedge clk or negedge rst) begin
        if (!rst) flush_flop <= 1'b0;
        else flush_flop <= branch_taken;
    end
    
    // Instruction to Decode
    wire [15:0] ir_decode = (flush_flop) ? 16'h0000 : instruction_in;
    
    // PC Decode Latch
    reg [15:0] pc_decode;
    always @(posedge clk or negedge rst) begin
        if (!rst) pc_decode <= 16'h0100;
        else if (!pc_stall) pc_decode <= pc;
    end
    
    // =====================================================
    // 3. DECODE LOGIC
    // =====================================================
    
    wire [3:0] opcode = ir_decode[15:12];
    wire [3:0] rs1_addr = ir_decode[11:8]; 
    wire [3:0] rs2_addr = ir_decode[7:4];
    wire [3:0] rd_addr  = ir_decode[3:0];  
    wire [7:0] imm8     = ir_decode[7:0];
    wire [3:0] imm_rd   = ir_decode[11:8];
    
    // Instruction Types
    wire is_r_type = (opcode <= 4'h7) && (opcode != 4'b0101);
    wire is_ldi    = (opcode == 4'hA);
    wire is_load   = (opcode == 4'hB); 
    wire is_store  = (opcode == 4'hC); 
    wire is_branch = (opcode == 4'hE);
    wire is_addi   = (opcode == 4'h8);
    wire is_halt   = (opcode == 4'hF) && (ir_decode[11:8] == 4'hE); 

    // Halt register
    reg halted;
    always @(posedge clk or negedge rst) begin
        if (!rst) halted <= 1'b0;
        else if (is_halt && !flush_flop) halted <= 1'b1;
    end 
    
    // Register Access
    assign reg_read_addr1 = (is_r_type) ? rs1_addr[2:0] :
                            (is_store)  ? imm_rd[2:0] :
                            (is_branch) ? rs1_addr[2:0] : 
                            3'b000;
                            
    assign reg_read_addr2 = (is_r_type) ? rs2_addr[2:0] : 3'b000;
    
    assign reg_write_addr = (is_r_type) ? rd_addr[2:0] :
                            (is_ldi || is_load || is_addi) ? imm_rd[2:0] :
                            3'b000;
                            
    assign reg_write_en = (is_r_type || is_ldi || is_load || is_addi) && !flush_flop; 
    
    // =====================================================
    // 4. FORWARDING UNIT (Load-Use)
    // =====================================================
    
    reg        last_was_load;
    reg [2:0]  last_load_dst;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            last_was_load <= 1'b0;
            last_load_dst <= 3'b000;
        end else begin
            last_was_load <= is_load && !flush_flop;
            last_load_dst <= reg_write_addr;
        end
    end
    
    wire forward_a = last_was_load && (reg_read_addr1 == last_load_dst); 
    wire forward_b = last_was_load && (reg_read_addr2 == last_load_dst);
    
    wire [15:0] rf_a = forward_a ? data_in : reg_data1;
    wire [15:0] rf_b = forward_b ? data_in : reg_data2;
    
    wire [15:0] op_a = rf_a;
    wire [15:0] op_b = (is_r_type) ? rf_b : 
                       (is_addi || is_ldi || is_load || is_store) ? {{8{imm8[7]}}, imm8} :
                       rf_b;
                       
    // =====================================================
    // 5. EXECUTION & MEMORY INTERFACE
    // =====================================================
    
    nexus_alu alu_unit (
        .operand_a(op_a),
        .operand_b(op_b),
        .alu_op(opcode),
        .carry_in(1'b0), 
        .result(alu_result),
        .flag_n(alu_flags[3]),
        .flag_z(alu_flags[2]),
        .flag_c(alu_flags[1]),
        .flag_v(alu_flags[0])
    );
    
    // Flags
    always @(posedge clk or negedge rst) begin
        if (!rst) flags_reg <= 4'b0000;
        else if ((is_r_type || is_addi) && !flush_flop) flags_reg <= alu_flags;
    end
    
    // Write Back Data Mux (Delayed Write for Load)
    reg        delayed_write_en;
    reg [2:0]  delayed_write_addr;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            delayed_write_en <= 1'b0;
            delayed_write_addr <= 3'b000;
        end else begin
            delayed_write_en <= (is_load && !flush_flop);
            delayed_write_addr <= reg_write_addr;
        end
    end
    
    // Register Write Logic & Structural Hazard
    wire structural_hazard = (is_r_type || is_ldi || is_addi) && delayed_write_en;
    assign load_use_hazard = structural_hazard; 
    
    wire final_write_en = (delayed_write_en) || (reg_write_en && !structural_hazard); 
    wire [2:0] final_write_addr = (delayed_write_en) ? delayed_write_addr : reg_write_addr;
    wire [15:0] final_write_data = (delayed_write_en) ? data_in : 
                                   (is_ldi) ? {{8{imm8[7]}},imm8} : alu_result;

    nexus_regfile reg_file (
        .clk(clk),
        .rst(rst),
        .read_reg1(reg_read_addr1),
        .read_reg2(reg_read_addr2),
        .write_reg(final_write_addr),
        .write_data(final_write_data),
        .write_enable(final_write_en),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // Memory Outputs with Access Tracking
    reg mem_access_active;  
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mem_access_active <= 1'b0;
        end else begin
            if ((is_load || is_store) && !flush_flop && !mem_access_active) begin
                mem_access_active <= 1'b1;
            end else begin
                mem_access_active <= 1'b0;
            end
        end
    end
    
    wire mem_access = (is_load || is_store) && !flush_flop && !mem_access_active;
    
    assign mem_read  = is_load && !flush_flop && !mem_access_active; 
    assign mem_write = is_store && !flush_flop && !mem_access_active;
    
    assign data_out = reg_data1; 
    assign mem_addr = {8'b0, imm8}; 
    
    // PC Update
    wire [15:0] branch_offset = {{8{imm8[7]}}, imm8};
    wire [15:0] target = pc_decode + branch_offset;
    
    wire z = flags_reg[2];
    wire n = flags_reg[3];
    wire v = flags_reg[0];
    
    assign branch_taken = (is_branch && !flush_flop) && (
        (ir_decode[11:10] == 2'b00) ? 1'b1 : // JMP
        (ir_decode[11:10] == 2'b01) ? z :    // BEQ
        (ir_decode[11:10] == 2'b10) ? !z :   // BNE
        (ir_decode[11:10] == 2'b11) ? (n!=v) : 0 // BLT
    );
    
    assign branch_target = target;
    
    // PC Register
    assign pc_out = pc;
    assign pc_next = branch_taken ? target : (pc + 2);

    always @(posedge clk or negedge rst) begin
        if (!rst) pc <= 16'h0100;
        else if (!pc_stall && !halted) pc <= pc_next;  
    end

    nexus_control ctrl (
        .load_use_hazard(load_use_hazard),
        .branch_taken(branch_taken),
        .mem_access(mem_access),
        .if_de_stall(if_de_stall),
        .if_de_flush(if_de_flush),
        .pc_stall(pc_stall)
    );
    
    // Debug
    assign debug_pc = pc;
    assign debug_ir = ir_decode;
    assign debug_r0 = reg_file.registers[0];
    assign debug_r1 = reg_file.registers[1];
    assign debug_r2 = reg_file.registers[2];
    assign debug_flags = flags_reg;
    assign debug_halted = halted;
    
    assign is_load_out = is_load && !flush_flop;
    assign is_store_out = is_store && !flush_flop;

endmodule
