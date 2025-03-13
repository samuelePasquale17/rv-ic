`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////

module CntModK #(parameter K = 32) (
        Tc,                          
        Vout,      
        Cnt,                             
        Clk,
        Rst,
        Pwr_off                         
    );

    output reg Tc;                          
    output reg [($clog2(K)-1):0] Vout;      
    input Cnt;                        
    input Clk;
    input Rst;   
    input Pwr_off;
    reg [($clog2(K)-1):0] cnt_val = 0;  

    always @(posedge Clk or posedge Rst or posedge Pwr_off) begin
        if (Rst || Pwr_off) begin
            cnt_val <= 0;  
            Tc <= 0;
        end else if (Cnt) begin
            if (cnt_val == K-1) begin
                cnt_val <= 0; 
                Tc <= 1'b1;  
            end else begin
                cnt_val <= cnt_val + 1;
                Tc <= 1'b0;
            end
        end
    end

    always @(posedge Clk or posedge Pwr_off) begin
        if (Pwr_off)
            Vout <= 0;
        else 
            Vout <= cnt_val;
    end

endmodule