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
            OP_JAL, OP_JALR, OP_AUIPC: begin
                alu_in1 = pc;                
            end
            default: begin
                alu_in1 = rd1;
            end
        endcase
    end
    always_comb begin
        unique case(op)
            OP_ADDI, OP_XORI, OP_ORI, OP_ANDI, OP_JAL, OP_JALR, OP_AUIPC, OP_SD, OP_LD, OP_SLLI, OP_SRLI, OP_SRAI: begin
                alu_in2 = imm;
            end
            OP_SRL, OP_SRA, OP_SLL: begin
                alu_in2 = {58'b0,rd2[5:0]};
            end
            default: begin
                alu_in2 = rd2;
            end
        endcase
    end


    
endmodule


`endif
