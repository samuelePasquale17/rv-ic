`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module RegN_IC_Wrapper #(parameter N = 32) (
        Ld,
        Vin,
        Vout,
        Dirty_val,
        Backup_en,
        Backup_ack,
        Backup_Vout,
        Rst_DrtyCtrl,
        Restore_en,
        Restore_Vin,
        Rst,
        Clk,
        Pwr_off
    );
    
    // register
    input Ld, Rst, Clk;
    input [N-1:0] Vin;
    output [N-1:0] Vout;
    
    // Dirty bit FSM
    input Backup_en, Backup_ack;   
    output [1:0] Dirty_val;
    output [N-1:0] Backup_Vout;
    input Rst_DrtyCtrl;
    
    // restore signals
    input [N-1:0] Restore_Vin;
    input Restore_en;
    
    // intermittent computing simulation
    input Pwr_off;
    
    wire [N-1:0] Vin_wire, Vin_wire_reg;
    wire [N-1:0] Vout_wire;
    
    wire Ld_reg_wire;
    wire Rst_reg_wire;
    
    wire cmp_res;
    
    wire Rst_DrtyCtrl_wire;
    
    wire Ld_wire;
    
    
    RegN #(
            .N          (N)
    ) register_n (
            .Vin        (Vin_wire_reg),
            .Vout       (Vout_wire),
            .Ld         (Ld_wire),
            .Rst        (Rst),
            .Clk        (Clk),
            .Pwr_off    (Pwr_off)
    );
    
    DirtyCtrl dirty_controller (
            .Ld_reg     (Ld_reg_wire),
            .Rst_reg    (Rst_reg_wire),
            .Backup_en  (Backup_en),
            .Backup_ack (Backup_ack),
            .Clk        (Clk),
            .Rst        (Rst_DrtyCtrl_wire),
            .Dirty_val  (Dirty_val),
            .Pwr_off    (Pwr_off)
    );
    
    CmpN #(
            .N          (N)
    ) comparator (
            .Vin_a      (Vin_wire),
            .Vin_b      (Vout_wire),
            .Vout       (cmp_res)
    );
    
    MuxN_21 #(
            .N          (N)
    ) multiplexer_restore (
            .Vin_a      (Vin_wire),  // sel = 0
            .Vin_b      (Restore_Vin),  // sel = 1
            .sel        (Restore_en),
            .Vout        (Vin_wire_reg)
    );
    
    
    
    assign Backup_Vout = Vout_wire;
    assign Vout = Vout_wire;
    assign Vin_wire = Vin;
    
    assign Ld_reg_wire  = Ld  & ~cmp_res;
    assign Rst_reg_wire = Rst & ~cmp_res;
    
    assign Rst_DrtyCtrl_wire = Rst_DrtyCtrl | Restore_en;
    assign Ld_wire = Ld | Restore_en;
    
    
    
endmodule
