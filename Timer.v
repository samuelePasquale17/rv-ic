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
    
    wire [N-1:0] wire_a, wire_b;
    wire end_wire;
    wire Rst_cnt;
    
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
    
    CntModK #(
        .K          (32'hFFFFFFFF)
    ) counter_ticks (
        .Tc         (),                          
        .Vout       (wire_a),      
        .Cnt        (En),                             
        .Clk        (Clk),
        .Rst        (Rst_cnt),
        .Pwr_off    (Pwr_off)
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
    
    
endmodule
