`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module Adder #(
        parameter N = 32
    ) (
        A,
        B,
        Cin,
        Cout,
        S
    );
    
    input [N-1:0] A;
    input [N-1:0] B;
    input Cin;
    
    output reg Cout;
    output reg [N-1:0] S;
    
    always @(A, B, Cin) begin
        {Cout, S} = A + B + Cin;
    end
endmodule
