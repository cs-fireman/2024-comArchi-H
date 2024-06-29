`ifndef __WDATAGEN_SV
`define __WDATAGEN_SV

`ifdef VERILATOR
`include "include/common.sv"
`else

`endif

module wdatagen
    import common::*;(
    input op_t op,
    input u64 imm, mem_rdata, rd1, rd2, alu_out,
    output u64 wdata
);
    always_comb begin
        unique case(op)
            OP_LUI: begin
                wdata = imm;
            end
			OP_LD: begin
				wdata = mem_rdata;
			end
			OP_SLTI: begin
				wdata = {63'b0,($signed(rd1) < $signed(imm))};
			end
			OP_SLTIU: begin
				wdata = {63'b0,($unsigned(rd1) < $unsigned(imm))};
			end
			OP_SLT: begin
				wdata = {63'b0,($signed(rd1) < $signed(rd2))};
			end
			OP_SLTU: begin
				wdata = {63'b0,($unsigned(rd1) < $unsigned(rd2))};
			end
            default: begin
                wdata = alu_out;
            end
        endcase
    end

endmodule
`endif
