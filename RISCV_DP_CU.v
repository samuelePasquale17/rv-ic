`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module RISCV_DP_CU #(
        parameter ADDR_DRAM_LEN = 10,
        parameter ADDR_IRAM_LEN = 10
    ) (
        VAL_IRAM,
        VAL_IRAM,
        ADDR_IRAM,
        ADDR_DRAM,
        VOUT_DRAM,
        VIN_DRAM,
        Clk,
        Rst,
        stand_by,
        Pwr_off,
        En,
        Rw,
        SigExt,
        B_H_W,
        
        // back up
        dirty_vals_rv,
        backup_ens_rv,
        backup_acks_rv,
        backup_Vouts_rv,
        restore_ens_rv,
        restore_Vins_rv
    );
    
    input Clk;
    input Rst;
    input stand_by;
    input Pwr_off;
    
    input [31:0] VAL_IRAM;
    input [31:0] VOUT_DRAM;
    output [31:0] VIN_DRAM;
    output [ADDR_IRAM_LEN-1:0] ADDR_IRAM;
    output [ADDR_DRAM_LEN-1:0] ADDR_DRAM;
    
    // back up ({datapath, control unit})
    output [(53*2)-1:0] dirty_vals_rv;
    input [53-1:0] backup_ens_rv;
    input [53-1:0] backup_acks_rv;
    output [(53*32)-1:0] backup_Vouts_rv;
    input [53-1:0] restore_ens_rv;
    input [(53*32)-1:0] restore_Vins_rv;
    
    // to mem DRAM
    output En;
    output Rw;
    output SigExt;
    output [1:0] B_H_W;

    
    wire [63:0] controlWord;
    wire [6:0] opcode;
    wire [6:0] func7;
    wire [2:0] func3; 
    
    wire rst_program_counter, load_program_counter;
    
    assign En = controlWord[6];
    assign Rw = controlWord[3];
    assign SigExt = controlWord[4];
    assign B_H_W = controlWord[2:1];
    
    
    assign rst_program_counter = controlWord[62];
    
    assign load_program_counter = controlWord[63];
    
    
    Datapath datapath_rv (
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off),
        .Rst_Drty_Ctrl              (Rst),
    
        // IRAM
        .VAL_IRAM                   (VAL_IRAM),
        .ADDR_IRAM                  (ADDR_IRAM),
    
        // DRAM 
        .VOUT_DRAM                  (VOUT_DRAM),
        .ADDR_DRAM                  (ADDR_DRAM),
        .VIN_DRAM                   (VIN_DRAM),
    
        // fetch 
        .ld_pc                      (load_program_counter), 
        .rst_pc                     (rst_program_counter), 
        .ld_nextPc                  (controlWord[61]), 
        .rst_nextPc                 (controlWord[60]), 
        .ld_ir                      (controlWord[59]), 
        .rst_ir                     (controlWord[58]),
    
        // decode
        .sel_nextPc                 (controlWord[55]),
        .cmp_type                   (controlWord[54:52]),
        .branch_en                  (controlWord[51:50]),
        .Rd1En_rf                   (controlWord[49]),
        .Rd2En_rf                   (controlWord[48]), 
        .rst_rf                     (controlWord[47]), 
        .sel_rs1                    (controlWord[46]), 
        .sel_imm                    (controlWord[45:44]), 
        .rst_rs1                    (controlWord[43]), 
        .ld_rs1                     (controlWord[42]), 
        .ld_rs2                     (controlWord[41]), 
        .rst_rs2                    (controlWord[40]), 
        .ld_imm                     (controlWord[39]), 
        .rst_imm                    (controlWord[38]),
        .ld_rd1                     (controlWord[37]), 
        .rst_rd1                    (controlWord[36]), 
        .ld_source_b1               (controlWord[35]), 
        .rst_source_b1              (controlWord[34]), 
        .ld_source_a1               (controlWord[33]), 
        .rst_source_a1              (controlWord[32]),
        .pc_upper                   (controlWord[57:56]),
    
        // execute
        .ld_source_a2               (controlWord[31]), 
        .rst_source_a2              (controlWord[30]), 
        .ld_source_b2               (controlWord[29]), 
        .rst_source_b2              (controlWord[28]),
        .ctrl_alu                   (controlWord[27:24]), 
        .sel_rs2_alu                (controlWord[23]), 
        .sel_out_alu                (controlWord[22:21]), 
        .ld_rd2                     (controlWord[20]), 
        .rst_rd2                    (controlWord[19]),
        .ld_me                      (controlWord[18]),
        .rst_me                     (controlWord[17]),
        .rst_out_alu                (controlWord[16]), 
        .ld_out_alu                 (controlWord[15]),
    
        // memory
        .ld_out_me                  (controlWord[14]), 
        .rst_out_me                 (controlWord[13]),
        .ld_rd3                     (controlWord[12]),
        .rst_rd3                    (controlWord[11]),
        .ld_source_a3               (controlWord[10]),
        .rst_source_a3              (controlWord[9]),
        .ld_source_b3               (controlWord[8]),
        .rst_source_b3              (controlWord[7]),
        .en_mem                     (controlWord[6]),
        .sel_out_me                 (controlWord[5]),
        .sig_ext_mem                (controlWord[4]),
        .rw_mem                     (controlWord[3]),
        .b_h_w_mem                  (controlWord[2:1]),
        
        // Write back
        .WEn_rf                     (controlWord[0]),
        
        // back up
        .dirty_vals_dp              (dirty_vals_rv[105:6]),
        .backup_ens_dp              (backup_ens_rv[52:3]),
        .backup_acks_dp             (backup_acks_rv[52:3]),
        .backup_Vouts_dp            (backup_Vouts_rv[(53*32)-1:(3*32)]),
        .restore_ens_dp             (restore_ens_rv[52:3]),
        .restore_Vins_dp            (restore_Vins_rv[(53*32)-1:(3*32)]),
        
        // control unit
        .opcode                     (opcode),
        .func3                      (func3),
        .func7                      (func7)
    );
    
    
    
    
    
    
    
    CU cu_rv (
        .opcode                     (opcode), 
        .func7                      (func7),
        .func3                      (func3),
        .controlWord                (controlWord),
        .Clk                        (Clk),
        .Rst                        (Rst),
        .stand_by                   (stand_by),
        .Pwr_off                    (Pwr_off),
        
        // back up
        .dirty_vals_cu              (dirty_vals_rv[5:0]),
        .backup_ens_cu              (backup_ens_rv[2:0]),
        .backup_acks_cu             (backup_acks_rv[2:0]),
        .backup_Vouts_cu            (backup_Vouts_rv[(3*32)-1:0]),
        .restore_ens_cu             (restore_ens_rv[2:0]),
        .restore_Vins_cu            (restore_Vins_rv[(3*32)-1:0])
        
        // control word
        // controlWord[63] = ld_pc
        // controlWord[62] = rst_pc
        // controlWord[61] = ld_nextPc
        // controlWord[60] = rst_nextPc
        // controlWord[59] = ld_ir
        // controlWord[58] = rst_ir
        // controlWord[57:56] = pc_upper [2]
        // controlWord[55] = sel_nextPc
        // controlWord[54:52] = cmp_type [3]
        // controlWord[51:50] = branch_en[2]
        // controlWord[49] = Rd1En_rf
        // controlWord[48] = Rd2En_rf
        // controlWord[47] = rst_rf
        // controlWord[46] = sel_rs1
        // controlWord[45:44] = sel_imm [2]
        // controlWord[43] = rst_rs1
        // controlWord[42] = ld_rs1
        // controlWord[41] = ld_rs2
        // controlWord[40] = rst_rs2
        // controlWord[39] = ld_imm
        // controlWord[38] = rst_imm
        // controlWord[37] = ld_rd1
        // controlWord[36] = rst_rd1
        // controlWord[35] = ld_source_b1
        // controlWord[34] = rst_source_b1
        // controlWord[33] = ld_source_a1
        // controlWord[32] = rst_source_a1
        // controlWord[31] = ld_source_a2
        // controlWord[30] = rst_source_a2
        // controlWord[29] = ld_source_b2
        // controlWord[28] = rst_source_b2
        // controlWord[27:24] = ctrl_alu [4]
        // controlWord[23] = sel_rs2_alu
        // controlWord[22:21] = sel_out_alu [2]
        // controlWord[20] = ld_rd2
        // controlWord[19] = rst_rd2
        // controlWord[18] = ld_me
        // controlWord[17] = rst_me
        // controlWord[16] = rst_out_alu
        // controlWord[15] = ld_out_alu
        // controlWord[14] = ld_out_me
        // controlWord[13] = rst_out_me
        // controlWord[12] = ld_rd3
        // controlWord[11] = rst_rd3
        // controlWord[10] = ld_source_a3
        // controlWord[9] = rst_source_a3
        // controlWord[8] = ld_source_b3
        // controlWord[7] = rst_source_b3
        // controlWord[6] = en_mem
        // controlWord[5] = sel_out_me
        // controlWord[4] = sig_ext_mem
        // controlWord[3] = rw_mem
        // controlWord[2:1] = b_h_w_mem [2]
        // controlWord[0] = WEn_rf
    );
    
    
    
endmodule
