`ifndef __ALUINPUT_SV
`define __ALUINPUT_SV

`ifdef VERILATOR
`include "include/common.sv"
`else

`endif

module aluinput
    import common::*;(
    input u64 imm,
    input u64 rd1,
    input u64 rd2,
    input u64 pc,
    input op_t op,
    output u64 alu_in1,
    output u64 alu_in2

);
    always_comb begin
        unique case(op)
            OP_JAL: begin
                alu_in1 = pc;                
            end
            OP_JALR: begin
                alu_in1 = pc;
            end
            OP_AUIPC: begin
                alu_in1 = pc;
            end
            default: begin
                alu_in1 = rd1;
            end
        endcase
    end
    always_comb begin
        unique case(op)
            OP_ADDI: begin
                alu_in2 = imm;
            end
            OP_XORI: begin
                alu_in2 = imm;
            end
            OP_ORI: begin
                alu_in2 = imm;
            end
            OP_ANDI: begin
                alu_in2 = imm;
            end
            OP_JAL: begin
                alu_in2 = imm;
            end
            OP_JALR: begin
                alu_in2 = imm;
            end
            OP_AUIPC: begin
                alu_in2 = imm;
            end
            OP_SD: begin
                alu_in2 = imm;
            end
            OP_LD: begin
                alu_in2 = imm;
            end
            default: begin
                alu_in2 = rd2;
            end
        endcase
    end


    
endmodule


`endif
