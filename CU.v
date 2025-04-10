`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module CU(
        opcode, 
        func7,
        func3,
        controlWord,
        Clk,
        Rst,
        stand_by,
        Pwr_off,
        dirty_vals_cu,
        backup_ens_cu,
        backup_acks_cu,
        backup_Vouts_cu,
        restore_ens_cu,
        restore_Vins_cu
        
        // control word
        // controlWord[63] = ld_pc
        // controlWord[62] = rst_pc
        // controlWord[61] = ld_nextPc
        // controlWord[60] = rst_nextPc
        // controlWord[59] = ld_ir
        // controlWord[58] = rst_ir
        // controlWord[57:56] = pc_upper [2]
        // controlWord[55] = sel_nextPc
        // controlWord[54:52] = cmp_type [3]
        // controlWord[51:50] = branch_en[2]
        // controlWord[49] = Rd1En_rf
        // controlWord[48] = Rd2En_rf
        // controlWord[47] = rst_rf
        // controlWord[46] = sel_rs1
        // controlWord[45:44] = sel_imm [2]
        // controlWord[43] = rst_rs1
        // controlWord[42] = ld_rs1
        // controlWord[41] = ld_rs2
        // controlWord[40] = rst_rs2
        // controlWord[39] = ld_imm
        // controlWord[38] = rst_imm
        // controlWord[37] = ld_rd1
        // controlWord[36] = rst_rd1
        // controlWord[35] = ld_source_b1
        // controlWord[34] = rst_source_b1
        // controlWord[33] = ld_source_a1
        // controlWord[32] = rst_source_a1
        // controlWord[31] = ld_source_a2
        // controlWord[30] = rst_source_a2
        // controlWord[29] = ld_source_b2
        // controlWord[28] = rst_source_b2
        // controlWord[27:24] = ctrl_alu [4]
        // controlWord[23] = sel_rs2_alu
        // controlWord[22:21] = sel_out_alu [2]
        // controlWord[20] = ld_rd2
        // controlWord[19] = rst_rd2
        // controlWord[18] = ld_me
        // controlWord[17] = rst_me
        // controlWord[16] = rst_out_alu
        // controlWord[15] = ld_out_alu
        // controlWord[14] = ld_out_me
        // controlWord[13] = rst_out_me
        // controlWord[12] = ld_rd3
        // controlWord[11] = rst_rd3
        // controlWord[10] = ld_source_a3
        // controlWord[9] = rst_source_a3
        // controlWord[8] = ld_source_b3
        // controlWord[7] = rst_source_b3
        // controlWord[6] = en_mem
        // controlWord[5] = sel_out_me
        // controlWord[4] = sig_ext_mem
        // controlWord[3] = rw_mem
        // controlWord[2:1] = b_h_w_mem [2]
        // controlWord[0] = WEn_rf
    );
    
    input [6:0] opcode;
    input [6:0] func7;
    input [2:0] func3;
    output [63:0] controlWord;
        
    input Clk;
    input Rst;
    input stand_by;  // freeze execution
    input Pwr_off;
    
    
    
    output [(3*2)-1:0] dirty_vals_cu;
    input [3-1:0] backup_ens_cu;
    input [3-1:0] backup_acks_cu;
    output [(3*32)-1:0] backup_Vouts_cu;
    input [3-1:0] restore_ens_cu;
    input [(3*32)-1:0] restore_Vins_cu;
    
    
    wire [5:0] ctrl_fetch;
    wire en_lut;
    wire ld_regs;
    wire [57:0] lut_out;
    wire [31:0] reg1_Vout;
    wire [14:0] reg2_Vout;
    wire reg3_Vout;
    wire [1:0] sel_muxes;
    
    
    assign sel_muxes = Rst ? 2'b01 : (stand_by ? 2'b10 : 2'b00);
    
    
    assign ld_regs = (~stand_by) & 1'b1;
    
    
    // fetch controller
    FetchCtrl fetch_ctrl (
        .En                 (~Rst),
        .CtrlWrd            (ctrl_fetch)
    );
    
    // LUT
    LUT_CU lut_cu(
        .opcode             (opcode),
        .func3              (func3),
        .func7              (func7),
        .En                 (en_lut),
        .CtrlWrd            (lut_out)
    );
    
    
    // reg enable
    RegN #(
        .N                  (1)
    ) reg_enable (
        .Vin                 (~Rst),
        .Vout                (en_lut),
        .Ld                  (1'b1),
        .Rst                 (Rst),
        .Clk                 (Clk),
        .Pwr_off             (Pwr_off)
    );
    
    
    // reg FET/EXE
    RegN_IC_Wrapper #(
        .N                  (32)
    ) reg_fetch_exe (
        .Ld                 (ld_regs),
        .Vin                (lut_out[31:0]),
        .Vout               (reg1_Vout),
        .Dirty_val          (dirty_vals_cu[5:4]),
        .Backup_en          (backup_ens_cu[2]),
        .Backup_ack         (backup_acks_cu[2]),
        .Backup_Vout        (backup_Vouts_cu[95:64]),
        .Rst_DrtyCtrl       (Rst),
        .Restore_en         (restore_ens_cu[2]),
        .Restore_Vin        (restore_Vins_cu[95:64]), 
        .Rst                (Rst),
        .Clk                (Clk),
        .Pwr_off            (Pwr_off)
    );
    
    assign backup_Vouts_cu[63:47] = 17'b00000000000000000;
    
    // reg EXE/MEM
    RegN_IC_Wrapper #(
        .N                  (15)
    ) reg_exe_mem (
        .Ld                 (ld_regs),
        .Vin                (reg1_Vout[14:0]),
        .Vout               (reg2_Vout),
        .Dirty_val          (dirty_vals_cu[3:2]),
        .Backup_en          (backup_ens_cu[1]),
        .Backup_ack         (backup_acks_cu[1]),
        .Backup_Vout        (backup_Vouts_cu[46:32]),  
        .Rst_DrtyCtrl       (Rst),
        .Restore_en         (restore_ens_cu[1]),
        .Restore_Vin        (restore_Vins_cu[46:32]),
        .Rst                (Rst),
        .Clk                (Clk),
        .Pwr_off            (Pwr_off)
    );
    
    assign backup_Vouts_cu[31:1] = 31'b0000000000000000000000000000000;
    
    // reg MEM/WB
    RegN_IC_Wrapper #(
        .N                  (1)
    ) reg_mem_wb (
        .Ld                 (ld_regs),
        .Vin                (reg2_Vout[0]),
        .Vout               (reg3_Vout),
        .Dirty_val          (dirty_vals_cu[1:0]),
        .Backup_en          (backup_ens_cu[0]),
        .Backup_ack         (backup_acks_cu[0]),
        .Backup_Vout        (backup_Vouts_cu[0]),  
        .Rst_DrtyCtrl       (Rst),
        .Restore_en         (restore_ens_cu[0]),
        .Restore_Vin        (restore_Vins_cu[0]),  
        .Rst                (Rst),
        .Clk                (Clk),
        .Pwr_off            (Pwr_off)
    );
    
    
    // mux fetch
    MuxM_N1 #(
        .N                  (3),
        .M                  (6)
    ) mux_fetch (
        .Vin                ({6'b000000, 6'b010101, ctrl_fetch}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[63:58])
    );
    
    // mux decode
    MuxM_N1 #(
        .N                  (3),
        .M                  (26)
    ) mux_dec (
        .Vin                ({26'b00000000000000000000000000, 26'b00000000001000100101010101, lut_out[57:32]}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[57:32])
    );
    
    // mux execute 
    MuxM_N1 #(
        .N                  (3),
        .M                  (17)
    ) mux_exe (
        .Vin                ({17'b00000000000000000, 17'b01010000000010110, reg1_Vout[31:15]}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[31:15])
    );
    
    // mux mem
    MuxM_N1 #(
        .N                  (3),
        .M                  (14)
    ) mux_mem (
        .Vin                ({14'b00000000000000, 14'b01010101000000, reg2_Vout[14:1]}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[14:1])
    );
    
    // mux write back
    MuxM_N1 #(
        .N                  (3),
        .M                  (1)
    ) mux_wb (
        .Vin                ({1'b0, 1'b0, reg3_Vout}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[0])
    );

endmodule
