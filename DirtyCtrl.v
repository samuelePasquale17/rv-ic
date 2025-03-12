`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////


module DirtyCtrl(
        Ld_reg,
        Rst_reg,
        Backup_en,
        Backup_ack,
        Clk,
        Rst,
        Dirty_val,
        Pwr_off
    );
    
    input Ld_reg, Rst_reg, Backup_en, Backup_ack;
    output [1:0] Dirty_val;
    input Clk, Rst;
    input Pwr_off;
    
    reg [1:0] Dirty_val;
    
    reg [1:0] State, NextState;
    
    parameter   CLEAN = 0, 
                DIRTY = 1, 
                READ = 2, 
                DIRTY_WR = 3;
    
    // comb logic
    always @(State, Ld_reg, Rst_reg, Backup_en, Backup_ack) begin
        case (State) 
            CLEAN: begin
                Dirty_val <= 2'b00;
                if (Ld_reg || Rst_reg)
                    NextState <= DIRTY;
                else
                    NextState <= State;
            end
            
            DIRTY: begin
                Dirty_val <= 2'b01;
                if (Backup_en)
                    NextState <= READ;
                else
                    NextState <= State;
            end
            
            READ: begin
                Dirty_val <= 2'b10;
                if (Ld_reg || Rst_reg)
                    NextState <= DIRTY_WR;
                else if (Backup_ack)
                    NextState <= CLEAN;
                else
                    NextState <= State;
            end
            
            DIRTY_WR: begin
                Dirty_val <= 2'b11;
                if (Backup_ack)
                    NextState <= CLEAN;
                else
                    NextState <= State;
            end
        endcase
    end
    
    
    // state reg
    always @(posedge Clk or posedge Pwr_off) begin
        if (Rst)
            State <= CLEAN;
        else if (Pwr_off)
            State <= CLEAN;
        else
            State <= NextState;
    end
endmodule
