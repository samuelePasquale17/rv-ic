`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = width of the input
//////////////////////////////////////////////////////////////////////////////////


module Sub1 #(
        parameter N = 4
    ) (
        Vin,
        Vout
    );

    input [N-1:0] Vin;
    output [N-1:0] Vout;

    assign Vout = (Vin == 0) ? 0 : (Vin - 1);

endmodule