`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module RCU #(
        parameter N = 10,  // Number of IC wrapper
        parameter K = 32,  // size base address
        parameter M = 32   // width IC wrapper
    ) (
        AckMem,
        Start,
        ReadMem,
        BaseAddr,
        AddrMem,
        ValMem,
        RestoreVal,
        RestoreEn,
        Clk,
        Rst,
        Pwr_off
    );
    
    input AckMem;
    input Start;  
    input [K-1:0] BaseAddr;
    input [M-1:0] ValMem;
    input Clk;
    input Rst;
    input Pwr_off;
    
    output [K-1:0] AddrMem;
    output ReadMem;
    output [M-1:0] RestoreVal;
    output [N-1:0] RestoreEn;
    
    localparam LOG2_N = $clog2(N);
    
    
    wire rst_cnt_wire;
    wire en_cnt_wire;
    wire [LOG2_N-1:0] vout_cnt_wire;
    wire [N-1:0] dec_out_wire;
    wire [LOG2_N-1:0] vout_sub_wire;
    wire end_wire;
    wire clk_cnt;
    wire restore_vin_en_wire;
    wire restore_dec_en_wire;
    wire [K-1:0] input_a_adder;
    
    CmpN_M #(
        .N                  (LOG2_N),
        .M                  (N)
    ) cmp_addr (
        .Vin_a              (vout_sub_wire),
        .Vout               (end_wire)
    );
    

    assign input_a_adder = {{(K-LOG2_N){1'b0}}, vout_cnt_wire};
    
    Adder #(
        .N                  (K)
    ) adder_base_addr (
        .A                  (input_a_adder),
        .B                  (BaseAddr),  // K bits
        .Cin                (1'b0),
        .Cout               (),
        .S                  (AddrMem)
    );
    
    Sub1 #(
        .N                  (LOG2_N)
    ) sub_cnt (
        .Vin                (vout_cnt_wire),
        .Vout               (vout_sub_wire)
    );
    
    assign clk_cnt = en_cnt_wire | rst_cnt_wire;
    
    CntN #(
        .N                  (LOG2_N)
    ) local_addr_cnt (
        .Clk                (clk_cnt),
        .Rst                (rst_cnt_wire),
        .Pwr_off            (Pwr_off),
        .Vout               (vout_cnt_wire)
    );
    
    DecN #(
        .N                  (LOG2_N)
    ) dec_restore_en (
        .Vin                (vout_sub_wire),
        .Vout               (dec_out_wire)
    );
    
    FSM_RCU fsm_rcu (
        .Start              (Start),
        .AckMem             (AckMem),
        .ReadEn             (ReadMem),
        .RstCnt             (rst_cnt_wire),
        .EnCnt              (en_cnt_wire),
        .EnDec              (restore_dec_en_wire),
        .End                (end_wire),
        .Restore_VinEn      (restore_vin_en_wire),
        .Pwr_off            (Pwr_off),
        .Rst                (Rst),
        .Clk                (Clk)
    );
    
    // enable restore_vin
    assign RestoreVal = ValMem & {M{restore_vin_en_wire}};
    
    // enable restore decoder
    assign RestoreEn = dec_out_wire & {N{restore_dec_en_wire}};

endmodule