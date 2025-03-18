`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module FSM_PCU (
        Start,
        IsFull_Buffer,
        Last,
        End_Timer,
        DirtyValSel,
        Rst_Buffer,
        Rst_CntN,
        Rst_Timer,
        En_Timer,
        Clk_CntN,
        PushEn_Buffer,
        Rst,
        Clk,
        Pwr_off
    );
    
    input Start;
    input IsFull_Buffer;
    input Last;
    input End_Timer;
    input [1:0] DirtyValSel;
    output reg Rst_Buffer;
    output reg Rst_CntN;
    output reg Rst_Timer;
    output reg En_Timer;
    output reg Clk_CntN;
    output reg PushEn_Buffer;
    
    input Rst;
    input Clk;
    input Pwr_off;
    
    parameter   IDLE = 0,
                RESET = 1,
                WAIT = 2,
                POOLING = 3,
                BACKUP_REG = 4;
                
    parameter DIRTY = 2'b01; // value of dirty status of the IC_REGN_WRAPPER
                
    reg [2:0] State, NextState;
    
    // CombLogic
    always @(State, Start, IsFull_Buffer, Last, End_Timer, DirtyValSel) begin
        Rst_Buffer <= 0;
        Rst_CntN <= 0;
        En_Timer <= 0;
        Rst_Timer <= 0;
        Clk_CntN <= 0;
        PushEn_Buffer <= 0;
        NextState <= State;
        
        case (State)
            IDLE: begin
                Rst_Buffer <= 1;
                if (Start) 
                    NextState <= RESET;
            end
            
            RESET: begin
                Rst_Timer <= 1;
                Rst_CntN <= 1;
                Clk_CntN <= 1;
                if (IsFull_Buffer == 0) 
                    NextState <= WAIT;
            end
            
            WAIT: begin
                En_Timer <= 1;
                if (End_Timer)
                    NextState <= POOLING;
            
            end
            
            POOLING: begin
                Clk_CntN <= 1;
                if (Last && DirtyValSel != DIRTY) 
                    NextState <= RESET;
                else if (Last == 0 && DirtyValSel != DIRTY)
                    NextState <= State;
                else if (DirtyValSel == DIRTY)
                    NextState <= BACKUP_REG;
            
            end
            
            BACKUP_REG: begin
                PushEn_Buffer <= 1;
                if (IsFull_Buffer || Last)
                    NextState <= RESET;
                else
                    NextState <= POOLING;
            end
        endcase
    end
    
    
    // StateReg
    always @(posedge Clk or posedge Pwr_off) begin
        if (Rst)
            State <= IDLE;
        else if (Pwr_off)
            State <= IDLE;
        else
            State <= NextState;
    end

    
endmodule
