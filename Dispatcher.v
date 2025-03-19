`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module Dispatcher #(
        parameter K = 10,   // number of IC_REG_WRAPPERS
        parameter N = 32,   // width IC_REG_WRAPPER
        parameter M = 32    // width base address
    ) (
        Start, 
        IsEmpty,
        WriteOp,
        DirtyBits,
        BackupVals,
        ValBuffer,
        AddrBuffer,
        BaseAddr,
        Rst,
        Clk,
        Pwr_off,
        Val,
        Addr,
        WriteEn,
        AckBackups,
        PullEn
    );
    
    localparam LOG2_K = $clog2(K);
    
    input Start;
    input IsEmpty;
    input WriteOp;
    input [(K*2)-1:0] DirtyBits;
    input [(K*N)-1:0] BackupVals;
    input [N-1:0] ValBuffer;
    input [LOG2_K-1:0] AddrBuffer;
    input [M-1:0] BaseAddr;
    input Rst;
    input Clk;
    input Pwr_off;
    
    // outputs
    output [N-1:0] Val;
    output [M-1:0] Addr;
    output WriteEn;
    output [K-1:0] AckBackups;
    output PullEn;
    
    
    wire [1:0] DirtyVal_wire;
    wire RstVal_wire;
    wire RstAddr_wire;
    wire LdVal_wire;
    wire LdAddr_wire;
    wire SelVal_wire;
    wire EnAck_wire;
    wire EnBuff_wire;
    wire [N-1:0] backupVal_wire;
    wire [(N*2)-1:0] choose_val_vin;
    wire [N-1:0] val_sel_wire;
    wire [N-1:0] vout_val_wire;
    wire [LOG2_K-1:0] vout_addr_wire;
    wire [M-1:0] vout_actual_addr_wire;
    wire [K-1:0] ack_sigs_wire;
    
    // FSM
    FSM_Dispatcher FSM_dispatcher (
        .Start              (Start),
        .IsEmpty            (IsEmpty),
        .WriteOp            (WriteOp),
        .DirtyVal           (DirtyVal_wire),
        .PullEn             (PullEn),
        .RstVal             (RstVal_wire),
        .RstAddr            (RstAddr_wire),
        .LdVal              (LdVal_wire),
        .LdAddr             (LdAddr_wire),
        .SelVal             (SelVal_wire),
        .EnAck              (EnAck_wire),
        .EnBuff             (EnBuff_wire),
        .Pwr_off            (Pwr_off),
        .Rst                (Rst),
        .Clk                (Clk)
    );
    
    // mux dirty bits
    MuxM_N1 #(
        .N                  (K),
        .M                  (2)
    ) mux_dirty_bits (
        .Vin                (DirtyBits),
        .Sel                (AddrBuffer),
        .Vout               (DirtyVal_wire)
    );
    
    // mux backup vals
    MuxM_N1 #(
        .N                  (K),
        .M                  (N)
    ) mux_backup_vals (
        .Vin                (BackupVals),
        .Sel                (vout_addr_wire),
        .Vout               (backupVal_wire)
    );
    
    
    assign choose_val_vin = {backupVal_wire, ValBuffer};
    // mux sel val buffer
    MuxM_N1 #(
        .N                  (2),
        .M                  (N)
    ) mux_val_buffer (
        .Vin                (choose_val_vin),
        .Sel                (SelVal_wire),
        .Vout               (val_sel_wire)
    );
    
    // reg val
    RegN #(
        .N                  (N)
    ) reg_val (
        .Vin                (val_sel_wire),
        .Vout               (vout_val_wire),
        .Ld                 (LdVal_wire),
        .Rst                (RstVal_wire),
        .Clk                (Clk),
        .Pwr_off            (Pwr_off)
    );
    
    // reg addr
    RegN #(
        .N                  (LOG2_K)
    ) reg_addr_buf (
        .Vin                (AddrBuffer),
        .Vout               (vout_addr_wire),
        .Ld                 (LdAddr_wire),
        .Rst                (RstAddr_wire),
        .Clk                (Clk),
        .Pwr_off            (Pwr_off)
    );
    
    // adder base addr + buff addr
    Adder #(
        .N                  (M)
    ) adder_addr (
        .A                  ({{(M-LOG2_K){1'b0}}, vout_addr_wire}),
        .B                  (BaseAddr),
        .Cin                (1'b0),
        .Cout               (),
        .S                  (vout_actual_addr_wire)
    );
    
    // buffer 3 states output 
    TriBuff #(
        .N                  (N)
    ) buff_3s_mem_interface_val (
        .Vin                (vout_val_wire),
        .En                 (EnBuff_wire),
        .Vout               (Val)
    );
    
    TriBuff #(
        .N                  (M)
    ) buff_3s_mem_interface_addr (
        .Vin                (vout_actual_addr_wire),
        .En                 (EnBuff_wire),
        .Vout               (Addr)
    );
    
    TriBuff #(
        .N                  (1)
    ) buff_3s_mem_interface_write_en (
        .Vin                (EnBuff_wire),
        .En                 (EnBuff_wire),
        .Vout               (WriteEn)
    );
    
    // decoder ack backup
    DecN #(
        .N                  (LOG2_K)
    ) decoder_ack_backup (
        .Vin                (vout_addr_wire),
        .Vout               (ack_sigs_wire)
    );
    
    // en ack backup
    assign AckBackups = ({K{EnAck_wire}} & ack_sigs_wire);


    
endmodule
