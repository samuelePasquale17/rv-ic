`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////


module MuxN_21 #(parameter N = 32) (
        Vin_a,  // sel = 0
        Vin_b,  // sel = 1
        sel,
        Vout
    );
    
    input [N-1:0] Vin_a, Vin_b;
    input sel;
    output [N-1:0] Vout;
    reg [N-1:0] Vout;
    
    always @(Vin_a, Vin_b, sel) begin
        if (sel) 
            Vout <= Vin_b;
        else
            Vout <= Vin_a;
    end
    
endmodule
