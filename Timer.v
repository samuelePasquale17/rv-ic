`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = number of bits of the timer
// to count X ticks set Load = X-1
//////////////////////////////////////////////////////////////////////////////////


module Timer #(parameter N = 32) (
        En,
        Load,
        Clk,
        Rst,
        End,
        Pwr_off
    );
    
    input En, Clk, Rst;
    input [N-1:0] Load;
    output End;
    input Pwr_off;
    
    wire [N-1:0] wire_a;
    wire [N-1:0] wire_b;
    wire end_wire;
    wire Rst_cnt;
    
    wire cnt_en;
    
    RegN #(
        .N          (N)
    ) register_ticks (
        .Vin        (Load),
        .Vout       (wire_b),
        .Ld         (Rst),
        .Rst        (1'b0),
        .Clk        (Clk),
        .Pwr_off    (Pwr_off)
    );
    
    CntN #(
        .N          (N)
    ) counter_ticks (
        .Clk        (cnt_en),
        .Rst        (Rst),
        .Pwr_off    (Pwr_off),
        .Vout       (wire_a) 
    );
    
    CmpN #(
        .N          (N)
    ) end_check (
        .Vin_a      (wire_a),
        .Vin_b      (wire_b),
        .Vout       (end_wire)
    );
    
    assign End = end_wire & En;
    assign Rst_cnt = end_wire | Rst;
    assign cnt_en = Clk & (En | Rst);
    
endmodule