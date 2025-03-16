`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// N = width of the input
//////////////////////////////////////////////////////////////////////////////////


module DecN #(
        parameter N = 4 
    )(
        Vin,
        Vout
    );
    
    input [N-1:0] Vin;
    output reg [2**N-1:0] Vout;
    
    always @(Vin) begin
        Vout <= {N{1'b0}};
        Vout[Vin] <= 1'b1;
    end 
endmodule

