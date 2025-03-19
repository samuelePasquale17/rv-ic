`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module TriBuff #(
        parameter N = 32
    )
    (
        Vin,
        En,
        Vout
    );
    
    input [N-1:0] Vin;
    input En;
    output reg [N-1:0] Vout;
    
    always @(Vin, En) begin
        if (En) 
            Vout <= Vin;
        else
            Vout <= {N{1'bZ}};
    end
endmodule
