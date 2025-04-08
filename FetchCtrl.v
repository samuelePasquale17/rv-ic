`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module FetchCtrl(
        En,
        CtrlWrd
    );
    
    
    input En;
    output reg [5:0] CtrlWrd;

    always @(*) begin
        if (En)
            CtrlWrd = 6'b101010;
        else
            CtrlWrd = 6'b000000;
    end

endmodule