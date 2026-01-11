`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// NexusRV16 - 16-bit Pipelined RISC Processor
// 16-bit Arithmetic Logic Unit (ALU)
// Author: Musa | January 2026
//////////////////////////////////////////////////////////////////////////////////

module nexus_alu(
    input [3:0] alu_op,
    input [15:0] operand_a,
    input [15:0] operand_b,
    input carry_in,
    output reg [15:0] result,
    output reg flag_n,
    output reg flag_z,
    output reg flag_c,
    output reg flag_v
);

    reg [16:0] temp_result;
    
    always @(*) begin
        flag_c = 1'b0;
        flag_v = 1'b0;
        temp_result = 17'b0;
        
        case(alu_op)
            4'b0000: begin // ADD
                temp_result = {1'b0, operand_a} + {1'b0, operand_b};
                result = temp_result[15:0];
                flag_c = temp_result[16];
                flag_v = (operand_a[15] == operand_b[15]) && (operand_a[15] != result[15]);
            end
            
            4'b0001: begin // SUB
                temp_result = {1'b0, operand_a} - {1'b0, operand_b};
                result = temp_result[15:0];
                flag_c = temp_result[16];
                flag_v = (operand_a[15] != operand_b[15]) && (operand_a[15] != result[15]);
            end
            
            4'b0010: begin // AND
                result = operand_a & operand_b;
            end
            
            4'b0011: begin // OR
                result = operand_a | operand_b;
            end
            
            4'b0100: begin // XOR
                result = operand_a ^ operand_b;
            end
            
            4'b0101: begin // NOT
                result = ~operand_a;
            end
            
            4'b0110: begin // SHL
                result = operand_a << operand_b[3:0];
                flag_c = (operand_b[3:0] > 0) ? operand_a[16-operand_b[3:0]] : 1'b0;
            end
            
            4'b0111: begin // SHR
                result = operand_a >> operand_b[3:0];
            end
            
            4'b1000: begin // ADDI (same as ADD)
                temp_result = {1'b0, operand_a} + {1'b0, operand_b};
                result = temp_result[15:0];
                flag_c = temp_result[16];
                flag_v = (operand_a[15] == operand_b[15]) && (operand_a[15] != result[15]);
            end
            
            4'b1001: begin // INC
                temp_result = {1'b0, operand_a} + 17'd1;
                result = temp_result[15:0];
                flag_c = temp_result[16];
            end
            
            4'b1010: begin // PASS_A (for LDI)
                result = operand_a;
            end
            
            4'b1011: begin // PASS_B (for LDR)
                result = operand_b;
            end
            
            4'b1100: begin // DEC
                temp_result = {1'b0, operand_a} - 17'd1;
                result = temp_result[15:0];
                flag_c = temp_result[16];
            end
            
            default: begin
                result = 16'h0000;
            end
        endcase
        
        flag_n = result[15];
        flag_z = (result == 16'h0000);
    end

endmodule
