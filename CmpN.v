`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////


module CmpN #(parameter N = 32) (
        Vin_a,
        Vin_b,
        Vout
    );
    
    input [N-1:0] Vin_a, Vin_b;
    output Vout;
    
    reg Vout;
    
    always @(Vin_a, Vin_b) begin
        if (Vin_a == Vin_b) 
            Vout <= 1'b1;
        else
            Vout <= 1'b0;
    end
endmodule
