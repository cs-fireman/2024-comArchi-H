`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`else

`endif

module decoder
    import common::*;(
    input u32 raw_instr,
    output control_t ctl

);

    u7 opcode, f7;
    assign opcode = raw_instr[6:0];
    assign f7 = raw_instr[31:25];
    u3 f3;
    assign f3 = raw_instr[14:12];
    u6 f6;
    assign f6 = raw_instr[31:26];
    always_comb begin
        unique case(opcode)
            OPCODE_ALUI:begin
                ctl.regwrite= 1'b1;
                unique case(f3)
                    F3_ADDI: begin
                        ctl.op = OP_ADDI;
                        ctl.alufunc = ALU_ADD;
                    end
                    F3_XORI: begin
                        ctl.op = OP_XORI;
                        ctl.alufunc = ALU_XOR;  
                    end
                    F3_ORI: begin
                        ctl.op = OP_ORI;
                        ctl.alufunc = ALU_OR;
                    end
                    F3_ANDI: begin
                        ctl.op = OP_ANDI;
                        ctl.alufunc = ALU_AND;
                    end
                    F3_SLTI: begin
                        ctl.op = OP_SLTI;
                        ctl.regwrite = 1'b1;
                    end
                    F3_SLTIU: begin
                        ctl.op = OP_SLTIU;
                        ctl.regwrite = 1'b1;
                    end
                    F3_SLLI: begin
                        if(f6 == F6_DEFAULT) begin
                            ctl.op = OP_SLLI;
                            ctl.alufunc = ALU_SLL;
                            ctl.regwrite = 1'b1;
                        end else begin
                            ctl = '0;
                        end
                    end
                    F3_SRLAI: begin
                        unique case(f6)
                            F6_DEFAULT: begin
                                ctl.op = OP_SRLI;
                                ctl.alufunc = ALU_SRL;
                                ctl.regwrite = 1'b1;
                            end
                            F6_FUNC1:begin
                                ctl.op = OP_SRAI;
                                ctl.alufunc = ALU_SRA;
                                ctl.regwrite = 1'b1;
                            end
                            default:begin
                                ctl = '0;
                            end
                        endcase
                    end
                    default: begin
                        ctl = '0;
                    end                                             
                endcase
            end
            OPCODE_LUI: begin
                ctl.op = OP_LUI;
                ctl.regwrite = 1'b1;
            end
            OPCODE_AUIPC: begin
                ctl.op = OP_AUIPC;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
            end
            OPCODE_ALU:begin
                ctl.regwrite = 1'b1;
                unique case(f3)
                    F3_ADD_SUB:begin
                        unique case(f7)
                            F7_ADD: begin
                                ctl.op = OP_ADD;
                                ctl.alufunc = ALU_ADD;
                            end
                            F7_SUB: begin
                                ctl.op = OP_SUB;
                                ctl.alufunc = ALU_SUB; 
                            end
                            default: begin
                                ctl = '0;
                            end 
                        endcase
                    end
                    F3_AND: begin
                        ctl.op = OP_AND;
                        ctl.alufunc = ALU_AND;
                    end
                    F3_OR: begin
                        ctl.op = OP_OR;
                        ctl.alufunc = ALU_OR;
                    end
                    F3_XOR: begin
                        ctl.op = OP_XOR;
                        ctl.alufunc = ALU_XOR;
                    end
                    F3_SLL: begin
                        if(f7 == F7_DEFAULT) begin
                            ctl.op = OP_SLL;
                            ctl.alufunc = ALU_SLL;
                            ctl.regwrite = 1'b1;
                        end else begin
                            ctl = '0;
                        end
                    end
                    F3_SRLA: begin
                        unique case(f7)
                            F7_DEFAULT: begin
                                ctl.op = OP_SRL;
                                ctl.alufunc = ALU_SRL;
                                ctl.regwrite = 1'b1;
                            end
                            F7_FUNC1: begin
                                ctl.op = OP_SRA;
                                ctl.alufunc = ALU_SRA;
                                ctl.regwrite = 1'b1;
                            end
                            default: begin
                                ctl = '0;
                            end
                        endcase
                    end
                    F3_SLT: begin
                        if (f7 == F7_DEFAULT) begin
                            ctl.op = OP_SLT;
                            ctl.regwrite = 1'b1;
                        end else begin
                            ctl = '0;
                        end
                    end
                    F3_SLTU: begin
                        if (f7 == F7_DEFAULT) begin
                            ctl.op = OP_SLTU;
                            ctl.regwrite = 1'b1;
                        end else begin
                            ctl = '0;
                        end
                    end
                    default: begin
                        ctl = '0;
                    end 
                endcase
            end
            OPCODE_SD:begin
                unique case(f3)
                    F3_SD: begin
                        ctl.op = OP_SD;
                        ctl.memwrite = 1'b1;
                        ctl.alufunc = ALU_ADD;
                    end
                    default: begin
                        ctl = '0;
                    end 
                endcase
            end
            OPCODE_LD:begin
                unique case(f3)
                    F3_LD: begin
                        ctl.op = OP_LD;
                        ctl.regwrite = 1'b1;
                        ctl.memread = 1'b1;
                        ctl.alufunc = ALU_ADD;
                    end
                    default: begin
                        ctl = '0;    
                    end
                endcase
            end
            OPCODE_JAL:begin
                ctl.op = OP_JAL;
                ctl.regwrite = 1'b1;
                ctl.branch = 1'b1;
                ctl.alufunc = ALU_ADD;
            end
            OPCODE_JALR:begin
                unique case(f3)
                    F3_JALR: begin
                        ctl.op = OP_JALR;
                        ctl.regwrite = 1'b1;
                        ctl.branch = 1'b1;
                        ctl.alufunc = ALU_ADD;
                    end
                    default: begin
                        ctl = '0;
                    end 
                endcase
            end
            OPCODE_BREAK:begin
                ctl.branch = 1'b1;
                unique case(f3)
                    F3_BEQ: begin
                        ctl.op = OP_BEQ;
                    end
                    F3_BNE: begin
                        ctl.op = OP_BNE;
                    end
                    F3_BLT: begin
                        ctl.op = OP_BLT;                  
                    end
                    F3_BGE: begin
                        ctl.op = OP_BGE;
                    end
                    F3_BLTU: begin
                        ctl.op = OP_BLTU;
                    end
                    F3_BGEU: begin
                        ctl.op = OP_BGEU;
                    end
                    default: begin
                        ctl = '0;
                    end 
                endcase
            end   
            default: begin
                ctl = '0;
            end         
        endcase
        
    end

    
endmodule


`endif
