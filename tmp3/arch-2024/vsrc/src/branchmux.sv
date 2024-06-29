`ifndef __BRANCHMUX_SV
`define __BRANCHMUX_SV

`ifdef VERILATOR
`include "include/common.sv"
`else

`endif

module branchmux
    import common::*;(
    input control_t ctl,
    input u32 raw_instr,
    input u64 pc, rd1, rd2,
    output u1 branch_taken,
    output u64 branch_target
);
	u64 Btype_branch_target;
    always_comb begin
		Btype_branch_target = pc + {
			{51{raw_instr[31]}},
			raw_instr[31],
			raw_instr[7],
			raw_instr[30:25],
			raw_instr[11:8],
			1'b0
		};	
        unique case(ctl.op)
            OP_BEQ: begin
                branch_taken = ctl.branch && rd1 == rd2;
                branch_target = Btype_branch_target;
            end
			OP_BNE: begin
                branch_taken = ctl.branch && rd1 != rd2;
                branch_target = Btype_branch_target;				
			end
			OP_BLT: begin
				branch_taken = ctl.branch && $signed(rd1) < $signed(rd2);
				branch_target = Btype_branch_target;
			end
			OP_BGE: begin
				branch_taken = ctl.branch && $signed(rd1) >= $signed(rd2);
				branch_target = Btype_branch_target;
			end
			OP_BLTU: begin
				branch_taken = ctl.branch && $unsigned(rd1) < $unsigned(rd2);
				branch_target = Btype_branch_target;
			end
			OP_BGEU: begin
				branch_taken = ctl.branch && $unsigned(rd1) >= $unsigned(rd2);
				branch_target = Btype_branch_target;
			end
            OP_JAL: begin
                branch_taken = ctl.branch;
                branch_target = pc + {
                    {43{raw_instr[31]}},
                    raw_instr[31],
                    raw_instr[19:12],
                    raw_instr[20],
                    raw_instr[30:21],
                    1'b0
                };
            end
            OP_JALR: begin
                branch_taken = ctl.branch;
                branch_target = rd1 + {
                    {52{raw_instr[31]}},
                    raw_instr[31:21],
                    1'b0
                };
            end
            default: begin
                branch_taken = '0;
				branch_target = '0;
            end
        endcase
    end
endmodule
`endif
