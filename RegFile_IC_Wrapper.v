`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module RegFile_IC_Wrapper # (
        parameter N = 32,  // reg width
        parameter M = 32  // num regs
    )
    (
        Write,
        AddrWrite,
        WEn,
        Rd1En,
        Rd2En,
        Addr1,
        Addr2,
        Rst,
        Clk,
        Pwr_off,
        Rs1,
        Rs2,
        Dirty_vals,  // backup
        Backup_ens,
        Backup_acks,
        Backup_Vouts,
        Restore_ens,
        Restore_Vins
    );
    
    input [$clog2(M)-1:0] AddrWrite;
    input [$clog2(M)-1:0] Addr1;
    input [$clog2(M)-1:0] Addr2;
    
    input [N-1:0] Write;
    
    input WEn;
    input Rd1En;
    input Rd2En;
    
    input Rst;
    input Clk;
    input Pwr_off;
    
    output [N-1:0] Rs1;
    output [N-1:0] Rs2;
    
    output [(M*2)-1:0] Dirty_vals;
    input [M-1:0] Backup_ens;
    input [M-1:0] Backup_acks;
    
    output [(M*N)-1:0] Backup_Vouts;
    
    input [M-1:0] Restore_ens; 
    input [(M*N)-1:0] Restore_Vins;
    
    
    wire [M-1:0] out_dec;
    wire [M-1:0] WEn_regs_wire;
    
    wire [N-1:0] Rs1_wire;
    wire [N-1:0] Rs2_wire;
    
    wire [(N*M)-1:0] reg_Vouts;
    
    
    // Decoder address wire
    DecN #(
        .N                  ($clog2(M))
    ) addr_write_dec (
        .Vin                (AddrWrite),
        .Vout               (out_dec)
    ); 
    
    // Load enable regs
    assign WEn_regs_wire = out_dec & {M{WEn}};
    
   // Mux address 1
   MuxM_N1 #(
        .N                  (M),
        .M                  (N) 
   ) mux_addr1 (
        .Vin                (reg_Vouts),
        .Sel                (Addr1),
        .Vout               (Rs1_wire)
   );
    
   // Mux address 2
   MuxM_N1 #(
        .N                  (M),
        .M                  (N) 
   ) mux_addr2 (
        .Vin                (reg_Vouts),
        .Sel                (Addr2),
        .Vout               (Rs2_wire)
   );
   
   // buffer tri-state outputs
   TriBuff #(
        .N(N)
   ) out1 (
        .Vin(Rs1_wire),
        .En(Rd1En),
        .Vout(Rs1)
   );
   
   TriBuff #(
        .N(N)
   ) out2 (
        .Vin(Rs2_wire),
        .En(Rd2En),
        .Vout(Rs2)
   );
   
    // registers
    genvar i;
  
    generate
        for (i = 0; i < M; i = i + 1) begin : regs_IC
            RegN_IC_Wrapper #(
                .N                  (N)
            ) reg_IC_inst (
                .Ld                 (WEn_regs_wire[i]),
                .Vin                (Write),
                .Vout               (reg_Vouts[(i+1)*N-1 : i*N]),
                .Dirty_val          (Dirty_vals[(i+1)*2-1 : i*2]),
                .Backup_en          (Backup_ens[(i+1)*1-1 : i*1]),
                .Backup_ack         (Backup_acks[(i+1)*1-1 : i*1]),
                .Backup_Vout        (Backup_Vouts[(i+1)*N-1 : i*N]),
                .Rst_DrtyCtrl       (Rst),
                .Restore_en         (Restore_ens[(i+1)*1-1 : i*1]),
                .Restore_Vin        (Restore_Vins[(i+1)*N-1 : i*N]),
                .Rst                (Rst),
                .Clk                (Clk),
                .Pwr_off            (Pwr_off)
            );
        end
    endgenerate
    
endmodule
