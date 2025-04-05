`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////


module BranchUnit #(
        parameter N = 32
    ) (
        input [2:0] CmpType,   // == 000, != 001, < 010, > 011, <= 100, >= 101
        input [1:0] CmpEn_J_Off,  // Cmp == 10, Jump = 01, Off == 00
        input signed [N-1:0] Rs1,  // Signed Source 1
        input signed [N-1:0] Rs2,  // Signed Source 2
        output reg Taken  // Not taken = 0, Taken = 1
    );

    always @(*) begin
        if (CmpEn_J_Off == 2'b00)
            Taken = 1'b0;
        else if (CmpEn_J_Off == 2'b01)
            Taken = 1'b1;
        else begin
            // signed cmp
            case (CmpType)
                3'b000: Taken = (Rs1 == Rs2);  // ==
                3'b001: Taken = (Rs1 != Rs2);  // !=
                3'b010: Taken = (Rs1 < Rs2);   // <
                3'b011: Taken = (Rs1 > Rs2);   // >
                3'b100: Taken = (Rs1 <= Rs2);  // <=
                3'b101: Taken = (Rs1 >= Rs2);  // >=
                default: Taken = 1'b0;         // default
            endcase
        end
    end
endmodule