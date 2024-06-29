`ifndef __CORE_SV
`define __CORE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "src/alu.sv"
`include "src/aluinput.sv"
`include "src/decoder.sv"
`include "src/immchoser.sv"
`include "src/regfile.sv"
`endif

module core import common::*;(
	input  logic       clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
	input  logic       trint, swint, exint
);
	/* TODO: Add your CPU-Core here. */
	// memory to be modified
    u1 memread,memwrite;
    u64 addr,mem_wdata, mem_rdata;

	u64 branch_target;
    u1 branch_taken;
    u64 pc, pc_nxt;
    always_comb begin
			pc_nxt = pc + 4;
			if(branch_taken) begin
				pc_nxt = branch_target;
			end
    end
    always_ff @(posedge clk) begin
        if(reset) begin
            pc <= PCINIT;
        end else if (dreq.valid ? dresp.data_ok : iresp.data_ok) begin
            pc <= pc_nxt;
        end
    end
	assign ireq.valid = 1'b1;
	assign ireq.addr = pc;

	u32 raw_instr;
	assign raw_instr = iresp.data;
	u32 ext_time_instr;
	assign ext_time_instr = raw_instr | saved_raw_instr;
	control_t ctl;
	decoder decoder_inst(
        .raw_instr(ext_time_instr),
        .ctl(ctl)
    );
	u64 imm;
	immchoser immchoser_inst (
		.op(ctl.op),
		.imm(imm),
		.raw_instr(ext_time_instr)
	);
	u1 dreq_pending;
	u1 regwrite;
	assign regwrite = ctl.regwrite;
	creg_addr_t rs1, rs2, rd;
    u64 rd1, rd2;
    assign rs1 = ext_time_instr[19:15];
    assign rs2 = ext_time_instr[24:20];
    assign rd = ext_time_instr[11:7];
    u64 alu_in1, alu_in2;
    u64 alu_out;
	aluinput aluinput_inst(
		.imm,
		.rd1,
		.rd2,
		.pc,
		.op(ctl.op),
		.alu_in1,
		.alu_in2
	);
	alu alu_inst (
        .a(alu_in1),
        .b(alu_in2),
        .alufunc(ctl.alufunc),
        .result(alu_out)
    );

	u64 wdata; // write into register
    always_comb begin
        unique case(ctl.op)
            OP_LUI: begin
                wdata = imm;
            end
			OP_LD: begin
				wdata = mem_rdata;
			end
            default: begin
                wdata = alu_out;
            end
        endcase
    end
	regfile regfile_inst (
        .clk(clk),
		.reset(reset),
        .ra1(rs1),
        .ra2(rs2),
        .rd1(rd1),
        .rd2(rd2),
        .wvalid(regwrite),
        .wa(rd),
        .wd(wdata), // TO BE IMPROVED
		.dreq(dreq),
		.dresp(dresp)
    );

    assign memread = ctl.memread;
    assign memwrite = ctl.memwrite;
    assign addr = alu_out;
    assign mem_wdata = rd2;
	assign mem_rdata = dresp.data;
	u32 saved_raw_instr;
	always_ff @(posedge clk) begin
		if (reset) begin
			dreq_pending <= 1'b0;
			saved_raw_instr <= '0;
		end
		else if (dreq.valid && !dreq_pending) begin
			dreq_pending <= 1'b1;
			saved_raw_instr <= raw_instr;
		end
		else if (dresp.data_ok) begin
			dreq_pending <= 1'b0;
			saved_raw_instr <= '0;
		end
	end

	assign dreq.valid = (memwrite | memread) | dreq_pending;
	assign dreq.addr = addr;
	assign dreq.size = MSIZE8;
	assign dreq.strobe = (memwrite ? '1 : '0);
	assign dreq.data = mem_wdata;


    always_comb begin
        unique case(ctl.op)
            OP_BEQ: begin
                branch_taken = ctl.branch &&
                        rd1 == rd2;
                branch_target = pc + {
                    {51{raw_instr[31]}},
                    raw_instr[31],
                    raw_instr[7],
                    raw_instr[30:25],
                    raw_instr[11:8],
                    1'b0
                };
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
            end
        endcase
    end

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (dreq.valid ? dresp.data_ok : iresp.data_ok),
		.pc                 (pc),
		.instr              (raw_instr),
		.skip               (0),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (regwrite),
		.wdest              ({3'b0, rd}),
		.wdata              (wdata)
	);

	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile_inst.regs_nxt[0]),
		.gpr_1              (regfile_inst.regs_nxt[1]),
		.gpr_2              (regfile_inst.regs_nxt[2]),
		.gpr_3              (regfile_inst.regs_nxt[3]),
		.gpr_4              (regfile_inst.regs_nxt[4]),
		.gpr_5              (regfile_inst.regs_nxt[5]),
		.gpr_6              (regfile_inst.regs_nxt[6]),
		.gpr_7              (regfile_inst.regs_nxt[7]),
		.gpr_8              (regfile_inst.regs_nxt[8]),
		.gpr_9              (regfile_inst.regs_nxt[9]),
		.gpr_10             (regfile_inst.regs_nxt[10]),
		.gpr_11             (regfile_inst.regs_nxt[11]),
		.gpr_12             (regfile_inst.regs_nxt[12]),
		.gpr_13             (regfile_inst.regs_nxt[13]),
		.gpr_14             (regfile_inst.regs_nxt[14]),
		.gpr_15             (regfile_inst.regs_nxt[15]),
		.gpr_16             (regfile_inst.regs_nxt[16]),
		.gpr_17             (regfile_inst.regs_nxt[17]),
		.gpr_18             (regfile_inst.regs_nxt[18]),
		.gpr_19             (regfile_inst.regs_nxt[19]),
		.gpr_20             (regfile_inst.regs_nxt[20]),
		.gpr_21             (regfile_inst.regs_nxt[21]),
		.gpr_22             (regfile_inst.regs_nxt[22]),
		.gpr_23             (regfile_inst.regs_nxt[23]),
		.gpr_24             (regfile_inst.regs_nxt[24]),
		.gpr_25             (regfile_inst.regs_nxt[25]),
		.gpr_26             (regfile_inst.regs_nxt[26]),
		.gpr_27             (regfile_inst.regs_nxt[27]),
		.gpr_28             (regfile_inst.regs_nxt[28]),
		.gpr_29             (regfile_inst.regs_nxt[29]),
		.gpr_30             (regfile_inst.regs_nxt[30]),
		.gpr_31             (regfile_inst.regs_nxt[31])
	);

    DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);

	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0 /* mstatus & 64'h800000030001e000 */),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	);
`endif
endmodule
`endif