`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////

module CmpN_M #(
        parameter N = 32,
        parameter M = 0
    ) (
        input  [N-1:0] Vin_a,
        output reg Vout
    );

    always @(*) begin
        if (Vin_a == M) 
            Vout = 1'b1;
        else
            Vout = 1'b0;
    end

endmodule

