`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module Ext32 #(
        parameter K = 32  // input width
    ) (
        Vin,
        Vout
    );
    
    input signed [K-1:0] Vin;
    output signed [31:0] Vout;
    
    assign Vout = {{(32-K){Vin[K-1]}}, Vin};
    
endmodule
