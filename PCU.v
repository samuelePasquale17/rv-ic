`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module PCU #(
        parameter K = 10,  // number of IC_Reg_Wrapeer
        parameter N = 32,  // width of IC_Reg_Wrapper
        parameter M = 32  // width timer value register
    ) (
        Backup_Vout_IC_Reg_Wrapper,
        Start_FSM_PCU,
        PushVal_Buffer,
        Load_Timer,
        PushEn_Buffer,
        Dirty_vals_IC_Reg_Wrapper, // K = number of Wrappers
        Rst_Buffer,
        Backup_Ens_IC_REG_Wrapper, // K = number of Wrappers
        IsFull_Buffer,
        Clk,
        Rst,
        Pwr_off
    );
    
    localparam LOG2_K = $clog2(K);

    
    input [(K*N)-1:0] Backup_Vout_IC_Reg_Wrapper;
    input Start_FSM_PCU;
    input [M-1:0] Load_Timer;
    input [(K*2)-1:0] Dirty_vals_IC_Reg_Wrapper;
    input IsFull_Buffer;
    
    output [N+LOG2_K-1:0] PushVal_Buffer;
    output PushEn_Buffer;
    output Rst_Buffer;
    output [K-1:0] Backup_Ens_IC_REG_Wrapper;
    
    input Pwr_off;
    input Rst;
    input Clk;
    
    wire last_wire;
    wire end_wire;
    wire [1:0] dirty_val_wire;
    wire Rst_CntN_wire;
    wire Rst_Timer_wire;
    wire En_Timer_wire;
    wire Clk_CntN_wire;
    
    wire [LOG2_K-1:0] addr_wrapper;
    wire [LOG2_K-1:0] addr_wrapper_sub;
    wire [N-1:0] push_val_buffer_wire;
    
    wire [K-1:0] Backup_Ens_IC_REG_Wrapper_wire;
    
    // FSM
    FSM_PCU fsm_power_cu (
        .Start              (Start_FSM_PCU),
        .IsFull_Buffer      (IsFull_Buffer),
        .Last               (last_wire),
        .End_Timer          (end_wire),
        .DirtyValSel        (dirty_val_wire),
        .Rst_Buffer         (Rst_Buffer),
        .Rst_CntN           (Rst_CntN_wire),
        .Rst_Timer          (Rst_Timer_wire),
        .En_Timer           (En_Timer_wire),
        .Clk_CntN           (Clk_CntN_wire),
        .PushEn_Buffer      (PushEn_Buffer),
        .Rst                (Rst),
        .Clk                (Clk),
        .Pwr_off            (Pwr_off)
    );
    
    // Timer
    Timer #(
        .N                  (M)
    ) timer_pcu (
        .En                 (En_Timer_wire),
        .Load               (Load_Timer),
        .Clk                (Clk),
        .Rst                (Rst_Timer_wire),
        .End                (end_wire),
        .Pwr_off            (Pwr_off)
    );
    
    // CntN
    CntN #(
        .N                  (LOG2_K)
    ) counter_backup_addr (
        .Clk                (Clk_CntN_wire),
        .Rst                (Rst_CntN_wire),
        .Pwr_off            (Pwr_off),
        .Vout               (addr_wrapper)
    );
    
    // Decoder
    DecN #(
        .N                  (LOG2_K)
    ) dec_backup_en (
        .Vin                (addr_wrapper_sub),
        .Vout               (Backup_Ens_IC_REG_Wrapper_wire)
    );
    
    assign Backup_Ens_IC_REG_Wrapper = Backup_Ens_IC_REG_Wrapper_wire & {N{PushEn_Buffer}};
    
    // Multiplexer
    MuxM_N1 #(
        .N                  (K),
        .M                  (2)
    ) mux_dirty_val (
        .Vin                (Dirty_vals_IC_Reg_Wrapper),
        .Sel                (addr_wrapper_sub),
        .Vout               (dirty_val_wire)
    );
    
    // sub by 1
    Sub1 #(
        .N                  (LOG2_K)
    ) sub1_addr (
        .Vin                (addr_wrapper),
        .Vout               (addr_wrapper_sub)
    );
    
    // and signal Last
    CmpN_M #(
        .N      (LOG2_K),
        .M      (K)
    ) cmp_last_addr_wrapper (
        .Vin_a  (addr_wrapper),
        .Vout   (last_wire)
    );
    
    // mux Backup vals
    MuxM_N1 #(
        .N                  (K),
        .M                  (N)
    ) mux_backup_val (
        .Vin                (Backup_Vout_IC_Reg_Wrapper),
        .Sel                (addr_wrapper_sub),
        .Vout               (push_val_buffer_wire)
    );
    
    assign PushVal_Buffer = {push_val_buffer_wire, addr_wrapper_sub};
    
    
endmodule
