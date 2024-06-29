`ifndef __IMMCHOSER_SV
`define __IMMCHOSER_SV

`ifdef VERILATOR
`include "include/common.sv"
`else

`endif 

module immchoser 
    import common::*;(
    output u64 imm,
    input op_t op,
    input u32 raw_instr
);
    u64 imm_I_t;
    assign imm_I_t = {
        {52{raw_instr[31]}},
        raw_instr[31:20]
    }; 
    u64 imm_lui;
    assign imm_lui = {
        {32{raw_instr[31]}},
        raw_instr[31:12],
        12'b0
    }; 
    u64 imm_U_t;
    assign imm_U_t = {
        {32{raw_instr[31]}},
        raw_instr[31:12],
        12'b0
    }; 
    u64 imm_jal;
    assign imm_jal = 4;
    u64 imm_jalr;
    assign imm_jalr = 4;
    u64 imm_sd;
    assign imm_sd = {
        {52{raw_instr[31]}},
        {raw_instr[31:25], raw_instr[11:7]}
    };
    always_comb begin
        imm = '0;
        unique case(op)
            OP_ADDI: begin
                imm = imm_I_t;
            end
            OP_XORI: begin
                imm = imm_I_t;
            end
            OP_ORI: begin
                imm = imm_I_t; 
            end
            OP_ANDI: begin
                imm = imm_I_t;
            end
            OP_LUI: begin
                imm = imm_U_t;
            end
            OP_AUIPC: begin
                imm = imm_U_t;
            end
            OP_SD: begin
                imm = imm_sd;
            end
            OP_LD: begin
                imm = imm_I_t;
            end
            OP_JAL: begin
                imm = imm_jal;
            end
            OP_JALR: begin
                imm = imm_jalr;
            end
            default: begin
                imm = '0;
            end
        endcase
 
    end

endmodule



`endif


