`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module RISCV(
        Clk,
        Rst,
        Rst_DRAM,
        Rst_IRAM,
        stand_by,
        Pwr_off
    );
    
    input Clk;
    input Rst, Rst_DRAM, Rst_IRAM;
    input stand_by;
    input Pwr_off;
    
    wire [31:0] val_iram;
    wire [31:0] addr_iram;
    wire [31:0] vin_dram;
    wire [31:0] vout_dram;
    wire [31:0] addr_dram;
    
    wire ack_dram;  // to Power CU 
    
    
    
    // to remove 
    wire [(53*32)-1:0] dummy1;
    wire [(53*2)-1:0] dummy2;
    wire [53-1:0] dummy3;
    
    
    RISCV_DP_CU #(
        .ADDR_DRAM_LEN      (10),
        .ADDR_IRAM_LEN      (10)
    ) riscv_core (
        .VAL_IRAM            (val_iram),
        .ADDR_IRAM           (addr_iram),
        .ADDR_DRAM           (addr_dram),
        .VOUT_DRAM           (vout_dram),
        .VIN_DRAM            (vin_dram),
        .Clk                 (Clk),
        .Rst                 (Rst),
        .stand_by            (stand_by),
        .Pwr_off             (Pwr_off),
        .En                  (En),
        .Rw                  (Rw),
        .SigExt              (SigExt),
        .B_H_W               (B_H_W),
        
        // back up
        .dirty_vals_rv       (dummy2),
        .backup_ens_rv       (dummy3),
        .backup_acks_rv      (dummy3),
        .backup_Vouts_rv     (dummy1),
        .restore_ens_rv      (dummy3),
        .restore_Vins_rv     (dummy1)
    );
    
    
    DRAM #(
        .N                  (32),  // Width (32 bits)
        .K                  (1024)  // Number of memory locations
    ) dram_rv (
        .Addr                (addr_dram[9:0]),
        .Vin                 (vin_dram),
        .Rst                 (Rst_DRAM),
        .En                  (En),
        .Rw                  (Rw),
        .SigExt              (SigExt),  // 0 unsigned, 1 signed
        .B_H_W               (B_H_W),  // 00 byte, 01 half, 10 word
        .Vout                (vout_dram),
        .Ack                 (ack_dram)
    );
    
    
    IRAM #(
        .N                  (32),  // width
        .K                  (1024)  // number of memory locations
    ) iram_rv (
        .Addr               (addr_iram[9:0]),
        .Data               (val_iram),
        .Clk                (Clk),
        .Rst                (Rst_IRAM)
    );
    
endmodule