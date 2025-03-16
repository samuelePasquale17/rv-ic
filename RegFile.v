`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////


module RegFile #(
        parameter N = 64,       // width of each register
        parameter M = 32        // number of registers
    ) (
        ReadAddr,
        WriteAddr,
        Vin,
        Vout,
        REn,
        WEn,
        Clk,
        Rst,
        Pwr_off
    );
    
    input [$clog2(M)-1:0] ReadAddr;
    input [$clog2(M)-1:0] WriteAddr;
    input [N-1:0] Vin;
    input REn, WEn;
    input Clk, Rst;
    output reg [N-1:0] Vout;
    
    input Pwr_off;
    
    reg [N-1:0] RegFile [0:M-1];
    
    integer i;
    
    // write procedure
    always @(posedge Clk or posedge Pwr_off) begin
        if (Rst | Pwr_off) begin
            // all zeros
            for (i = 0; i < M; i = i + 1) begin
                RegFile[i] <= {N{1'b0}};
            end
        end
        else if (WEn)
            RegFile[WriteAddr] <= Vin;
    end
    
    // read procedure
    always @(posedge Clk or posedge Pwr_off) begin
        if (REn)
            Vout <= RegFile[ReadAddr];
        else if (Pwr_off) 
            Vout <= {N{1'bZ}};
        else
            Vout <= {N{1'bZ}};
    end
endmodule
