`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////
module RegN #(parameter N = 32)(
        Vin,
        Vout,
        Ld,
        Rst,
        Clk,
        Pwr_off
    );
    
    input [N-1:0] Vin;
    output [N-1:0] Vout;
    input Ld, Rst, Clk;
    input Pwr_off;
    
    reg [N-1:0] Vout;
    
    always @(posedge Clk or posedge Rst or posedge Pwr_off) begin
        if (Rst || Pwr_off) 
            Vout <= {N{1'b0}};
        else if (Ld)
            Vout <= Vin;
    end
    
endmodule
