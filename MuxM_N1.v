`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = number of M-bit inputs
// Sel starts select the LSB of Vin (e.g. Sel = 0 => Vin[1:0], Sel = 1 => Vin[3:2], ...)
// M = width of single input
//////////////////////////////////////////////////////////////////////////////////


module MuxM_N1 #(
        parameter N = 4,
        parameter M = 16
    )(
        Vin,
        Sel,
        Vout
    );

    input [(M*N)-1:0] Vin;
    input [$clog2(N)-1:0] Sel;
    output reg [M-1:0] Vout;

    always @(Vin, Sel) begin
        Vout <= Vin[Sel*M +:M];
    end

endmodule