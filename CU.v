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
        .Vin                ({ctrl_fetch, 6'b010101, 6'b000000}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[63:58])
    );
    
    // mux decode
    MuxM_N1 #(
        .N                  (3),
        .M                  (26)
    ) mux_dec (
        .Vin                ({lut_out[57:32], 26'b00000000001000100101010101, 26'b00000000000000000000000000}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[57:32])
    );
    
    // mux execute 
    MuxM_N1 #(
        .N                  (3),
        .M                  (17)
    ) mux_exe (
        .Vin                ({reg1_Vout[31:15], 17'b01010000000010110, 17'b00000000000000000}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[31:15])
    );
    
    // mux mem
    MuxM_N1 #(
        .N                  (3),
        .M                  (14)
    ) mux_mem (
        .Vin                ({reg2_Vout[14:1], 14'b01010101000000, 14'b00000000000000}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[14:1])
    );
    
    // mux write back
    MuxM_N1 #(
        .N                  (3),
        .M                  (1)
    ) mux_wb (
        .Vin                ({reg3_Vout, 1'b0, 1'b0}),
        .Sel                (sel_muxes),
        .Vout               (controlWord[0])
    );

endmodule