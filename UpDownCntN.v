`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = number of bits of the counter => MIN = 0, MAX = 2^N - 1
//////////////////////////////////////////////////////////////////////////////////

module UpDownCntN #(
    parameter N = 32
    )(
        Up,
        Down,
        Vout,
        Rst,
        Clk,
        Pwr_off
    );
    
    input Up;
    input Down;
    input Rst;
    input Clk;
    input Pwr_off;
    output reg [N-1:0] Vout;
    
    always @(posedge Clk or posedge Pwr_off) begin        
        if (Rst | Pwr_off)
            Vout <= {N{1'b0}};
        else if (Up)
            Vout <= Vout + 1'b1;
        else if (Down) 
            Vout <= Vout - 1'b1;  
    end
    
endmodule