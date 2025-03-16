`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = number of 2-bit inputs
// Sel starts select the LSB of Vin (e.g. Sel = 0 => Vin[1:0], Sel = 1 => Vin[3:2], ...)
//////////////////////////////////////////////////////////////////////////////////


module Mux2_N1 #(
        parameter N = 4
    )(
        Vin,
        Sel,
        Vout
    );

    input [2*N-1:0] Vin;
    input [$clog2(N)-1:0] Sel;
    output reg [1:0] Vout;

    always @(Vin, Sel) begin
        Vout <= Vin[Sel*2 +:2];
    end

endmodule