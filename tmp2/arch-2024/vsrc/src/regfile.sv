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
            regs[0] <= '0;
            regs[1] <= '0;
            regs[2] <= '0;
            regs[3] <= '0;
            regs[4] <= '0;
            regs[5] <= '0;
            regs[6] <= '0;
            regs[7] <= '0;
            regs[8] <= '0;
            regs[9] <= '0;
            regs[10] <= '0;
            regs[11] <= '0;
            regs[12] <= '0;
            regs[13] <= '0;
            regs[14] <= '0;
            regs[15] <= '0;
            regs[16] <= '0;
            regs[17] <= '0;
            regs[18] <= '0;
            regs[19] <= '0;
            regs[20] <= '0;
            regs[21] <= '0;
            regs[22] <= '0;
            regs[23] <= '0;
            regs[24] <= '0;
            regs[25] <= '0;
            regs[26] <= '0;
            regs[27] <= '0;
            regs[28] <= '0;
            regs[29] <= '0;
            regs[30] <= '0;
            regs[31] <= '0;
            regs_nxt[0] <= '0;
            regs_nxt[1] <= '0;
            regs_nxt[2] <= '0;
            regs_nxt[3] <= '0;
            regs_nxt[4] <= '0;
            regs_nxt[5] <= '0;
            regs_nxt[6] <= '0;
            regs_nxt[7] <= '0;
            regs_nxt[8] <= '0;
            regs_nxt[9] <= '0;
            regs_nxt[10] <= '0;
            regs_nxt[11] <= '0;
            regs_nxt[12] <= '0;
            regs_nxt[13] <= '0;
            regs_nxt[14] <= '0;
            regs_nxt[15] <= '0;
            regs_nxt[16] <= '0;
            regs_nxt[17] <= '0;
            regs_nxt[18] <= '0;
            regs_nxt[19] <= '0;
            regs_nxt[20] <= '0;
            regs_nxt[21] <= '0;
            regs_nxt[22] <= '0;
            regs_nxt[23] <= '0;
            regs_nxt[24] <= '0;
            regs_nxt[25] <= '0;
            regs_nxt[26] <= '0;
            regs_nxt[27] <= '0;
            regs_nxt[28] <= '0;
            regs_nxt[29] <= '0;
            regs_nxt[30] <= '0;
            regs_nxt[31] <= '0;
        end
    end
    // initial begin
    //     for(int i = 0; i < 32; i ++) begin
    //         regs[i] = '0;
    //     end
    // end
    
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
