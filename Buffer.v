`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = Width values
// M = Buffer size, must be a power of 2 !!!
// K = log2(M)
//////////////////////////////////////////////////////////////////////////////////


module Buffer #(
        parameter N = 32, // Width values
        parameter M = 5, // Buffer size, pow of 2!
        parameter K = 3  // Number of bits for the addresses
    )(
        PushEn,
        PullEn,
        PushVal,
        PullVal,
        IsFull,
        IsEmpty,
        Clk,
        Rst,
        Pwr_off
    );
    
    input [N-1:0] PushVal;
    output [N-1:0] PullVal;
    input PushEn;
    input PullEn;
    output IsFull;
    output IsEmpty;
    
    input Clk, Rst, Pwr_off;
    
    wire ff_cnt_write;
    wire ff_cnt_read;
    wire [($clog2(M)-1):0] addr_read;
    wire [($clog2(M)-1):0] addr_write;
    wire en_cnt_write;
    wire en_cnt_read;
    wire en_cnt_up_down_cnt;
    wire [K:0] vout_num_full_reg;

    
    // register file
    RegFile #(
        .N          (N),     // width of each register
        .M          (M)      // number of registers
    ) buffer (
        .ReadAddr   (addr_read),
        .WriteAddr  (addr_write),
        .Vin        (PushVal),
        .Vout       (PullVal),
        .REn        (PullEn),
        .WEn        (PushEn),
        .Clk        (Clk),
        .Rst        (Rst),
        .Pwr_off    (Pwr_off)
    );
    
    
    
    // CntN write
    CntN #(
        .N          (K)
    ) addr_cnt_write (
        .Clk        (en_cnt_write),
        .Rst        (Rst),
        .Pwr_off    (Pwr_off),
        .Vout       (addr_write)
    );
    
    // CntN read
    CntN #(
        .N          (K)
    ) addr_cnt_read (
        .Clk        (en_cnt_read),
        .Rst        (Rst),
        .Pwr_off    (Pwr_off),
        .Vout       (addr_read)
    );
    
    // UpDownCntN empty-full check
    UpDownCntN #(
        .N          (K+1)
    ) cnt_full_regs (
        .Up         (PushEn),
        .Down       (PullEn),
        .Vout       (vout_num_full_reg),
        .Rst        (Rst),
        .Clk        (en_cnt_up_down_cnt),
        .Pwr_off    (Pwr_off)
    );


    assign en_cnt_write = (Clk & PushEn) | (Clk & Rst);
    assign en_cnt_read = (Clk & PullEn) | (Clk & Rst);
    assign en_cnt_up_down_cnt = (Clk & PushEn) | (Clk & PullEn) | (Clk & Rst);
    
    assign IsFull = vout_num_full_reg[K];
    assign IsEmpty = ~(|vout_num_full_reg);
 
endmodule
