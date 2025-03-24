`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////

module FSM_RCU (
        Start,
        AckMem,
        ReadEn,
        RstCnt,
        EnCnt,
        EnDec,
        End,
        Restore_VinEn,
        Pwr_off,
        Rst,
        Clk
    );
    
    input Start;
    input AckMem;
    input End;
    
    input Pwr_off;
    input Rst;
    input Clk;
    
    
    output reg ReadEn;
    output reg RstCnt;
    output reg EnCnt;
    output reg EnDec;
    output reg Restore_VinEn;

    
    
    parameter   IDLE = 0,
                RESET = 1,
                READ = 2,
                RESTORE = 3;
                
    reg [1:0] State, NextState;
    
    
    // Comb log
    always @(Start, AckMem, End, State) begin
        ReadEn <= 1'b0;
        RstCnt <= 1'b0;
        EnCnt <= 1'b0;
        EnDec <= 1'b0;
        Restore_VinEn <= 1'b0;
        
        case (State)
            IDLE: begin
                if (Start)
                    NextState <= RESET;
            end
            
            RESET: begin
                RstCnt <= 1'b1;
                NextState <= READ;
            end
            
            READ: begin
                ReadEn <= 1'b1;
                if (AckMem)
                    NextState <= RESTORE;
            end
            
            RESTORE: begin
                EnCnt <= 1'b1;
                EnDec <= 1'b1;
                Restore_VinEn <= 1'b1;
                if (End)
                    NextState <= IDLE;
                else 
                    NextState <= READ;
            end
        endcase
    
    end
    
    // State reg
    always @(posedge Clk or posedge Pwr_off) begin
        if (Rst || Pwr_off)
            State <= IDLE;
        else
            State <= NextState;
    end
    



endmodule