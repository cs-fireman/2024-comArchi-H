`ifndef __REGFILE_SV
`define __REGFILE_SV

`ifdef VERILATOR
`include "include/common.sv"
`else

`endif

module regfile
    import common::*;(
    input logic clk, reset,
    
    /* Two Read Ports */
    input creg_addr_t ra1, ra2,
    output u64 rd1, rd2,
    // output u64 regs_nxt[31:0],
    /* One Write Port */
    input u1 wvalid,
    input creg_addr_t wa,
    input u64 wd,
    input dbus_req_t dreq,
    input dbus_resp_t dresp
    );
    /* Storage */
    u64 regs[31:0];
    u64 regs_nxt[31:0];
    always_ff @(posedge clk) begin
        if(reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 64'd0;
                regs_nxt[i] <= 64'd0;
            end
        end
    end
    
    /* Read Logic */
    assign rd1 = regs[ra1];
    assign rd2 = regs[ra2];
    always_comb begin
        for (int i = 0; i < 32; i++) begin
            regs_nxt[i] = regs[i]; // default
        end
        if(wvalid && wa != '0) begin
            regs_nxt[wa] = wd;
        end
    end

    /* Write Logic */
    always_ff @(posedge clk) begin
        if(wvalid
           && wa != '0 /* register 0 is read-only as 0 */ && (dreq.valid ? dresp.data_ok : 1)) begin
            regs[wa] <= wd;
        end
    end
    
endmodule


`endif
