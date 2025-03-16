`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = number of bits of the counter
//////////////////////////////////////////////////////////////////////////////////

module CntN #(parameter N = 32) (
        Clk,
        Rst,
        Pwr_off,
        Vout                      
    );
    
    input Clk;
    input Rst;
    input Pwr_off;
    
    output reg [N-1:0] Vout;
    
    always @(posedge Clk or posedge Pwr_off) begin
        if (Rst | Pwr_off)
            Vout <= 0;
        else 
            Vout <= Vout + 1'b1;
    end

endmodule
