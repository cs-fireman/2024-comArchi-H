`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`else

`endif

module alu
    import common::*;(
    input u64 a, b,
    input alufunc_t alufunc,
    output u64 result
);
    always_comb begin
        unique case(alufunc)
            ALU_ADD: begin
                result = a + b;
            end
            ALU_XOR: begin
                result = a ^ b;
            end
            ALU_OR: begin
                result = a | b;
            end
            ALU_AND: begin
                result = a & b;
            end
            ALU_SUB: begin
                result = a - b;
            end
            ALU_NONE: begin
                result = '0;
            end
            default: begin
                result = '0;
            end
        endcase
    end
endmodule
`endif
