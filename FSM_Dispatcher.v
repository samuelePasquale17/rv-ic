`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module FSM_Dispatcher (
        Start,
        IsEmpty,
        WriteOp,
        DirtyVal,
        PullEn,
        RstVal,
        RstAddr,
        LdVal,
        LdAddr,
        SelVal,
        EnAck,
        EnBuff,
        Pwr_off,
        Rst,
        Clk
    );
    
    input Start;
    input IsEmpty;
    input WriteOp;
    input [1:0] DirtyVal;
    
    input Pwr_off;
    input Rst;
    input Clk;
    
    output reg PullEn;
    output reg RstVal;
    output reg RstAddr;
    output reg LdVal;
    output reg LdAddr;
    output reg SelVal;
    output reg EnAck;
    output reg EnBuff;
    
    parameter   IDLE = 0,
                WAIT = 1,
                READ = 2,
                UPDATE = 3,
                SEND1 = 4,
                SEND2 = 5;
                
    parameter READ_STATE_DIRTY_CTRL = 2;
    parameter DIRTY_WR_STATE_DIRTY_CTRL = 3;
                
    reg [2:0] State, NextState;
    
    // comb logic
    always @(State, Start, IsEmpty, WriteOp, DirtyVal) begin
        PullEn <= 1'b0;
        RstVal <= 1'b0;
        RstAddr <= 1'b0;
        LdVal <= 1'b0;
        LdAddr <= 1'b0;
        SelVal <= 1'b0;
        EnAck <= 1'b0;
        EnBuff <= 1'b0;
        
        case (State) 
            IDLE: begin
                if (Start)
                    NextState <= WAIT;
            end
            
            WAIT: begin
                RstVal <= 1'b1;
                RstAddr <= 1'b1;
                if (~WriteOp && ~IsEmpty)
                    NextState <= READ;  
            end
            
            READ: begin
                PullEn <= 1'b1;
                LdAddr <= 1'b1;
                LdVal <= 1'b1;
                
                if (DirtyVal == READ_STATE_DIRTY_CTRL)
                    NextState <= SEND1;
                else
                    NextState <= UPDATE;
            end
            
            UPDATE: begin
                SelVal <= 1'b1;
                LdVal <= 1'b1;
                
                if (~WriteOp)
                    NextState <= SEND2;
            end
            
            SEND1: begin
                if (~WriteOp && DirtyVal != DIRTY_WR_STATE_DIRTY_CTRL)
                    NextState <= SEND2;
                else if (~WriteOp && DirtyVal == DIRTY_WR_STATE_DIRTY_CTRL)
                    NextState <= UPDATE;
            end
            
            SEND2: begin
                EnBuff <= 1'b1;
                EnAck <= 1'b1;
                NextState <= WAIT;
            end
        
        endcase
    
    end
    
    // state reg
    always @(posedge Clk or posedge Pwr_off) begin
        if (Rst || Pwr_off)
            State <= IDLE;
        else 
            State <= NextState;
    end
endmodule
