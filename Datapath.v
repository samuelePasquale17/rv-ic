`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module Datapath(
        Clk,
        Pwr_off,
        Rst_Drty_Ctrl,
    
        // IRAM
        VAL_IRAM,
        ADDR_IRAM,
    
        // DRAM 
        VOUT_DRAM,
        ADDR_DRAM,
    
        // fetch 
        ld_pc, 
        rst_pc, 
        ld_nextPc, 
        rst_nextPc, 
        ld_ir, 
        rst_ir,
    
        // decode
        sel_nextPc,
        cmp_type,
        branch_en,
        Rd1En_rf,
        Rd2En_rf, 
        rst_rf, 
        sel_rs1, 
        sel_imm, 
        rst_rs1, 
        ld_rs1, 
        ld_rs2, 
        rst_rs2, 
        ld_imm, 
        rst_imm,
        ld_rd1, 
        rst_rd1, 
        ld_source_b1, 
        rst_source_b1, 
        ld_source_a1, 
        rst_source_a1,
        pc_upper,
    
        // execute
        ld_source_a2, 
        rst_source_a2, 
        ld_source_b2, 
        rst_source_b2,
        ctrl_alu, 
        sel_rs2_alu, 
        sel_out_alu, 
        ld_rd2, 
        rst_rd2,
        ld_me, rst_me,
        rst_out_alu, 
        ld_out_alu,
    
        // memory
        ld_out_me, 
        rst_out_me,
        sel_out_me,
        ld_rd3,
        rst_rd3,
        ld_source_a3,
        rst_source_a3,
        ld_source_b3,
        rst_source_b3,
        en_mem,
        sel_out_me,
        sig_ext_mem,
        rw_mem,
        b_h_w_mem,
        
        // Write back
        WEn_rf,
        
        // back up
        dirty_vals_dp,
        backup_ens_dp,
        backup_acks_dp,
        backup_Vouts_dp,
        restore_ens_dp,
        restore_Vins_dp
    );
    
    input Clk;
    input Pwr_off;
    input Rst_Drty_Ctrl;
    
    // back up => number of IC reg wrappers = 18 + 32 = 50
    output [(50*2)-1:0] dirty_vals_dp;
    input [50-1:0] backup_ens_dp;
    input [50-1:0] backup_acks_dp;
    output [(50*32)-1:0] backup_Vouts_dp;
    input [50-1:0] restore_ens_dp;
    input [(50*32)-1:0] restore_Vins_dp;
    
    // IRAM
    input [31:0] VAL_IRAM;
    output [31:0] ADDR_IRAM;
    
    // DRAM 
    input [31:0] VOUT_DRAM;
    output [31:0] ADDR_DRAM;
    
    // fetch 
    input ld_pc, rst_pc, ld_nextPc, rst_nextPc, ld_ir, rst_ir;
    
    // decode
    input sel_nextPc;
    input [2:0] cmp_type;
    input [1:0] branch_en;
    input Rd1En_rf, Rd2En_rf, rst_rf, sel_rs1, sel_imm, rst_rs1, ld_rs1, ld_rs2, rst_rs2, ld_imm, rst_imm;
    input ld_rd1, rst_rd1, ld_source_b1, rst_source_b1, ld_source_a1, rst_source_a1;
    input [1:0] pc_upper;
    
    // execute
    input ld_source_a2, rst_source_a2, ld_source_b2, rst_source_b2;
    input ctrl_alu, sel_rs2_alu, ld_rd2, rst_rd2;
    input [1:0] sel_out_alu;
    input ld_me, rst_me;
    input rst_out_alu, ld_out_alu;
    
    // memory
    input ld_out_me, rst_out_me;
    input ld_rd3, rst_rd3;
    input ld_source_a3, rst_source_a3;
    input ld_source_b3, rst_source_b3;
    input en_mem, sel_out_me, sig_ext_mem, rw_mem;
    input [1:0] b_h_w_mem;
    
    
    // Write back
    input WEn_rf;
    
    
    
    wire [31:0] pc_Vout_wire;
    wire [31:0] pc_Vin_wire;
    wire [31:0] ir_Vout_wire;
    wire [31:0] ir_Vin_wire;
    wire [31:0] next_pc_Vin_wire;
    wire [31:0] next_pc_Vout_wire;
    wire [31:0] next_pc_j_branch;
    wire [31:0] next_pc_jump;
    wire [31:0] imm_Vout_ext_jal_wire;
    wire sel_pc_ctrl_wire;
    wire [31:0] rf_rs1_out;
    wire [31:0] rf_rs2_out;
    wire [31:0] val_Rs1;
    wire [31:0] imm1;
    wire [31:0] imm2;
    wire [31:0] imm3;
    wire [31:0] imm_Vout;
    wire [4:0] rf_addrWrite_wire;
    wire [31:0] rf_write_val_wire;
    wire [31:0] Vin_rs1_wire;
    wire [31:0] Vin_rs2_wire;
    wire [31:0] Vout_rs1_wire;
    wire [31:0] Vout_rs2_wire;
    wire [31:0] Vin_imm_wire;
    wire [31:0] Vout_imm_wire;
    wire [31:0] rd1_Vout_wire;
    wire [31:0] Vout_source_a1_wire;
    wire [31:0] Vout_source_b1_wire;
    wire [31:0] Vout_source_a2_wire;
    wire [31:0] Vout_source_b2_wire;
    wire [31:0] alu_a_wire;
    wire [31:0] alu_b_wire;
    wire [31:0] alu_out_wire;
    wire [31:0] val_rs2;
    wire [31:0] Vout_out_alu_wire;
    wire [31:0] Vout_me_wire;
    wire [31:0] Vin_me_wire;
    wire [31:0] rd2_Vout_wire;
    wire [31:0] Vin_out_me;
    wire [19:0] imm4;
    wire [31:0] add_to_pc;
    
    
    assign VAL_IRAM = ir_Vin_wire;
    assign ADDR_IRAM = pc_Vout_wire;
    
    //// Fetch ////
    
    // PC
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_pc (
        .Ld                         (ld_pc),
        .Vin                        (pc_Vin_wire),
        .Vout                       (pc_Vout_wire),
        .Dirty_val                  (dirty_vals_dp[99:98]),
        .Backup_en                  (backup_ens_dp[49]),
        .Backup_ack                 (backup_acks_dp[49]),
        .Backup_Vout                (backup_Vouts_dp[1599:1568]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[49]),
        .Restore_Vin                (restore_Vins_dp[1599:1568]),
        .Rst                        (rst_pc),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    
    // IR
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_ir (
        .Ld                         (ld_ir),
        .Vin                        (ir_Vin_wire),
        .Vout                       (ir_Vout_wire),
        .Dirty_val                  (dirty_vals_dp[95:94]),
        .Backup_en                  (backup_ens_dp[47]),
        .Backup_ack                 (backup_acks_dp[47]),
        .Backup_Vout                (backup_Vouts_dp[1535:1504]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[47]),
        .Restore_Vin                (restore_Vins_dp[1535:1504]),
        .Rst                        (rst_ir),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // NextPC
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_nextPC (
        .Ld                         (ld_nextPc),
        .Vin                        (next_pc_Vin_wire),
        .Vout                       (next_pc_Vout_wire),
        .Dirty_val                  (dirty_vals_dp[97:96]),
        .Backup_en                  (backup_ens_dp[48]),
        .Backup_ack                 (backup_acks_dp[48]),
        .Backup_Vout                (backup_Vouts_dp[1567:1536]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[48]),
        .Restore_Vin                (restore_Vins_dp[1567:1536]),
        .Rst                        (rst_nextPc),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // Adder incr PC
    Adder #(
        .N                          (32)
    ) incr_pc (
        .A                          (pc_Vout_wire),
        .B                          (32'h00000000),
        .Cin                        (1'b1),
        .Cout                       (),
        .S                          (next_pc_Vin_wire)
    );

    
    // Decode 
    
    // Decr by 1 to get PC
    Sub1 #(
        .N                          (32)
    ) sub_nextPC (
        .Vin                        (next_pc_Vout_wire),
        .Vout                       (pc_Vout_wire)
    );
    
    // Mux sel next PC or Rs1
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_sel_nextPC_or_Rs1 (
        .Vin                        ({pc_Vout_wire, rf_rs1_out}),
        .Sel                        (sel_nextPc),
        .Vout                       (next_pc_j_branch)
    );
    
    // Adder jal_branch
    Adder #(
        .N                          (32)
    ) adder_jal_branch (
        .A                          (next_pc_j_branch),
        .B                          (add_to_pc),
        .Cin                        (1'b0),
        .Cout                       (),
        .S                          (next_pc_jump)
    );
    

    // Mux sel next PC or Rs1
    MuxM_N1 #(
        .N                          (3),
        .M                          (32)
    ) mux_sel_pc_upper (
        .Vin                        ({imm_Vout_ext_jal_wire, {ir_Vout_wire[31:20], 12'b000000000000}, imm2}),
        .Sel                        (pc_upper),
        .Vout                       (add_to_pc)
    );
    
    // sig ext imm jal_branch
    Ext32 #(
        .K                          (20)  // input width
    ) sig_extImm (
        .Vin                        (ir_Vout_wire[31:12]),
        .Vout                       (imm_Vout_ext_jal_wire)
    );
    
    // Mux sel next PC
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_sel_nextPC (
        .Vin                        ({next_pc_Vout_wire, next_pc_jump}),
        .Sel                        (sel_pc_ctrl_wire),
        .Vout                       (pc_Vin_wire)
    );
    
    // branch unit
    BranchUnit #(
        .N                          (32)
    ) branch_unit (
        .CmpType                    (cmp_type), 
        .CmpEn_J_Off                (branch_en), 
        .Rs1                        (rf_rs1_out), 
        .Rs2                        (rf_rs2_out),
        .Taken                      (sel_pc_ctrl_wire)
    );
    
    // Register file
    RegFile_IC_Wrapper #(
        .N                          (32),
        .M                          (32)
    ) regFile (
        .Write                      (rf_write_val_wire),
        .AddrWrite                  (rf_addrWrite_wire),
        .WEn                        (WEn_rf),
        .Rd1En                      (Rd1En_rf),
        .Rd2En                      (Rd2En_rf),
        .Addr1                      (ir_Vout_wire[19:15]),
        .Addr2                      (ir_Vout_wire[24:20]),
        .Rst                        (rst_rf),
        .Clk                        (~Clk),
        .Pwr_off                    (Pwr_off),
        .Rs1                        (rf_rs1_out),
        .Rs2                        (rf_rs2_out),
        .Dirty_vals                 (dirty_vals_dp[63:0]),  // backup
        .Backup_ens                 (backup_ens_dp[31:0]),
        .Backup_acks                (backup_ens_dp[31:0]),
        .Backup_Vouts               (backup_Vouts_dp[1023:0]),
        .Restore_ens                (restore_ens_dp[31:0]),
        .Restore_Vins               (restore_Vins_dp[1023:0])
    );
   
    // mux sel Rs1
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_sel_Rs1 (
        .Vin                        ({next_pc_Vout_wire, rf_rs1_out}),
        .Sel                        (sel_rs1),
        .Vout                       (val_Rs1)
    );
    
    // mux sel imm
    MuxM_N1 #(
        .N                          (4),
        .M                          (32)
    ) mux_sel_imm (
        .Vin                        ({imm1, imm2, imm3, imm4}),
        .Sel                        (sel_imm),
        .Vout                       (imm_Vout)
    );

    // sign ext imm 1
    Ext32 #(
        .K                          (12)  // input width
    ) sig_extImm1 (
        .Vin                        (ir_Vout_wire[31:20]),
        .Vout                       (imm1)
    );
    
    // sign ext imm 2
    Ext32 #(
        .K                          (12)  // input width
    ) sig_extImm2 (
        .Vin                        ({ir_Vout_wire[31:25], ir_Vout_wire[11:7]}),
        .Vout                       (imm2)
    );
    
    // sign ext imm 3
    Ext32 #(
        .K                          (5)  // input width
    ) sig_extImm3 (
        .Vin                        (ir_Vout_wire[24:20]),
        .Vout                       (imm3)
    );
    
    // sign ext imm 4
    Ext32 #(
        .K                          (20)  // input width
    ) sig_extImm4 (
        .Vin                        (ir_Vout_wire[31:12]),
        .Vout                       (imm4)
    );

    // Rs1
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_rs1 (
        .Ld                         (ld_rs1),
        .Vin                        (Vin_rs1_wire),
        .Vout                       (Vout_rs1_wire),
        .Dirty_val                  (dirty_vals_dp[93:92]),
        .Backup_en                  (backup_ens_dp[46]),
        .Backup_ack                 (backup_acks_dp[46]),
        .Backup_Vout                (backup_Vouts_dp[1503:1472]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[46]),
        .Restore_Vin                (restore_Vins_dp[1503:1472]),
        .Rst                        (rst_rs1),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // Rs2
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_rs2 (
        .Ld                         (ld_rs2),
        .Vin                        (Vin_rs2_wire),
        .Vout                       (Vout_rs2_wire),
        .Dirty_val                  (dirty_vals_dp[91:90]),
        .Backup_en                  (backup_ens_dp[45]),
        .Backup_ack                 (backup_acks_dp[45]),
        .Backup_Vout                (backup_Vouts_dp[1471:1440]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[45]),
        .Restore_Vin                (restore_Vins_dp[1471:1440]),
        .Rst                        (rst_rs2),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // imm
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_imm (
        .Ld                         (ld_imm),
        .Vin                        (Vin_imm_wire),
        .Vout                       (Vout_imm_wire),
        .Dirty_val                  (dirty_vals_dp[89:88]),
        .Backup_en                  (backup_ens_dp[44]),
        .Backup_ack                 (backup_acks_dp[44]),
        .Backup_Vout                (backup_Vouts_dp[1439:1408]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[44]),
        .Restore_Vin                (restore_Vins_dp[1439:1408]),
        .Rst                        (rst_imm),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // rd1
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_rd1 (
        .Ld                         (ld_rd1),
        .Vin                        (ir_Vout_wire[11:7]),
        .Vout                       (rd1_Vout_wire),
        .Dirty_val                  (dirty_vals_dp[87:86]),
        .Backup_en                  (backup_ens_dp[43]),
        .Backup_ack                 (backup_acks_dp[43]),
        .Backup_Vout                (backup_Vouts_dp[1407:1376]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[43]),
        .Restore_Vin                (restore_Vins_dp[1407:1376]),
        .Rst                        (rst_rd1),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // source A1
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_sourceA1 (
        .Ld                         (ld_source_a1),
        .Vin                        (ir_Vout_wire[19:15]),
        .Vout                       (Vout_source_a1_wire),
        .Dirty_val                  (dirty_vals_dp[85:84]),
        .Backup_en                  (backup_ens_dp[42]),
        .Backup_ack                 (backup_acks_dp[42]),
        .Backup_Vout                (backup_Vouts_dp[1375:1344]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[42]),
        .Restore_Vin                (restore_Vins_dp[1375:1344]),
        .Rst                        (rst_source_a1),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // source B1
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_sourceB1 (
        .Ld                         (ld_source_b1),
        .Vin                        (ir_Vout_wire[24:20]),
        .Vout                       (Vout_source_b1_wire),
        .Dirty_val                  (dirty_vals_dp[83:82]),
        .Backup_en                  (backup_ens_dp[41]),
        .Backup_ack                 (backup_acks_dp[41]),
        .Backup_Vout                (backup_Vouts_dp[1343:1312]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[41]),
        .Restore_Vin                (restore_Vins_dp[1343:1312]),
        .Rst                        (rst_source_b1),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // mux forwarding Rs1
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_forw_rs1 (
        .Vin                        ({rf_write_val_wire, val_Rs1}),
        .Sel                        (1'b1),
        .Vout                       (Vin_rs1_wire)
    );
    
    // mux forwarding Rs2
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_forw_rs2 (
        .Vin                        ({rf_write_val_wire, rf_rs2_wire}),
        .Sel                        (1'b1),
        .Vout                       (Vin_rs2_wire)
    );
    
    // mux forwarding Imm
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_forw_imm (
        .Vin                        ({rf_write_val_wire, imm_Vout}),
        .Sel                        (1'b1),
        .Vout                       (Vin_imm_wire)
    );
    
    // Execute

    // Alu
    ALU #(
        .N                          (32)
    ) alu (
        .A                          (alu_a_wire),
        .B                          (alu_b_wire),
        .Cin                        (1'b0),
        .Cout                       (),
        .Ctrl                       (ctrl_alu),
        .Res                        (alu_out_wire),
        .Cmp                        ()
    );
    
    // mux rs2 input alu
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_rs2_inp_alu (
        .Vin                        ({Vout_imm_wire, Vout_rs2_wire}),
        .Sel                        (sel_rs2_alu),
        .Vout                       (val_rs2)
    );
    
    // mux out_alu
    MuxM_N1 #(
        .N                          (3),
        .M                          (32)
    ) mux_out_alu (
        .Vin                        ({alu_out_wire, Vout_rs2_wire, Vout_rs1_wire}),
        .Sel                        (sel_out_alu),
        .Vout                       (val_res_alu)
    );
    
    // adder ME
    Adder #(
        .N                          (32)
    ) adder_ME (
        .A                          (val_me_forw),
        .B                          (Vout_imm_wire),
        .Cin                        (1'b0),
        .Cout                       (),
        .S                          (Vin_me_wire)
    );
    
    // out alu
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_OUT_ALU (
        .Ld                         (ld_out_alu),
        .Vin                        (val_res_alu),
        .Vout                       (Vout_out_alu_wire),
        .Dirty_val                  (dirty_vals_dp[81:80]),
        .Backup_en                  (backup_ens_dp[40]),
        .Backup_ack                 (backup_acks_dp[40]),
        .Backup_Vout                (backup_Vouts_dp[1311:1280]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[40]),
        .Restore_Vin                (restore_Vins_dp[1311:1280]),
        .Rst                        (rst_out_alu),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // ME
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_ME (
        .Ld                         (ld_me),
        .Vin                        (Vin_me_wire),
        .Vout                       (Vout_me_wire),
        .Dirty_val                  (dirty_vals_dp[79:78]),
        .Backup_en                  (backup_ens_dp[39]),
        .Backup_ack                 (backup_acks_dp[39]),
        .Backup_Vout                (backup_Vouts_dp[1279:1248]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[39]),
        .Restore_Vin                (restore_Vins_dp[1279:1248]),
        .Rst                        (rst_me),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );

    // RD2
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_RD2 (
        .Ld                         (ld_rd2),
        .Vin                        (rd1_Vout_wire),
        .Vout                       (rd2_Vout_wire),
        .Dirty_val                  (dirty_vals_dp[77:76]),
        .Backup_en                  (backup_ens_dp[38]),
        .Backup_ack                 (backup_acks_dp[38]),
        .Backup_Vout                (backup_Vouts_dp[1247:1216]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[38]),
        .Restore_Vin                (restore_Vins_dp[1247:1216]),
        .Rst                        (rst_rd2),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // source A2
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_sourceA2 (
        .Ld                         (ld_source_a2),
        .Vin                        (Vout_source_a1_wire),
        .Vout                       (Vout_source_a2_wire),
        .Dirty_val                  (dirty_vals_dp[75:74]),
        .Backup_en                  (backup_ens_dp[37]),
        .Backup_ack                 (backup_acks_dp[37]),
        .Backup_Vout                (backup_Vouts_dp[1215:1184]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[37]),
        .Restore_Vin                (restore_Vins_dp[1215:1184]),
        .Rst                        (rst_source_a2),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // source B2
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_sourceB2 (
        .Ld                         (ld_source_b2),
        .Vin                        (Vout_source_b1_wire),
        .Vout                       (Vout_source_b2_wire),
        .Dirty_val                  (dirty_vals_dp[73:72]),
        .Backup_en                  (backup_ens_dp[36]),
        .Backup_ack                 (backup_acks_dp[36]),
        .Backup_Vout                (backup_Vouts_dp[1183:1152]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[36]),
        .Restore_Vin                (restore_Vins_dp[1183:1152]),
        .Rst                        (rst_source_b2),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // mux forw rs1 alu
    MuxM_N1 #(
        .N                          (3),
        .M                          (32)
    ) mux_forw_rs1_alu (
        .Vin                        ({Vout_out_alu_wire, rf_write_val_wire, Vout_rs1_wire}),
        .Sel                        (2'b10),
        .Vout                       (alu_a_wire)
    );
    
    // mux forw rs2 alu
    MuxM_N1 #(
        .N                          (4),
        .M                          (32)
    ) mux_forw_rs2_alu (
        .Vin                        ({Vout_out_alu_wire, rf_write_val_wire, rf_write_val_wire, val_rs2}),
        .Sel                        (2'b11),
        .Vout                       (alu_b_wire)
    );
    
    // mux forw ME
    MuxM_N1 #(
        .N                          (3),
        .M                          (32)
    ) mux_forw_ME (
        .Vin                        ({Vout_out_alu_wire, rf_write_val_wire, Vout_rs1_wire}),
        .Sel                        (2'b10),
        .Vout                       (val_me_forw)
    );
    
    // Memory
    
    // mux out ME
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_out_ME (
        .Vin                        ({out_me_forw, VOUT_DRAM}),
        .Sel                        (sel_out_me),
        .Vout                       (Vin_out_me)
    );
    
    // out ME
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_out_ME (
        .Ld                         (ld_out_me),
        .Vin                        (Vin_out_me),
        .Vout                       (rf_write_val_wire),
        .Dirty_val                  (dirty_vals_dp[71:70]),
        .Backup_en                  (backup_ens_dp[35]),
        .Backup_ack                 (backup_acks_dp[35]),
        .Backup_Vout                (backup_Vouts_dp[1151:1120]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[35]),
        .Restore_Vin                (restore_Vins_dp[1151:1120]),
        .Rst                        (rst_out_me),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // RD3
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_RD3 (
        .Ld                         (ld_rd3),
        .Vin                        (rd2_Vout_wire),
        .Vout                       (rf_addrWrite_wire),
        .Dirty_val                  (dirty_vals_dp[69:68]),
        .Backup_en                  (backup_ens_dp[34]),
        .Backup_ack                 (backup_acks_dp[34]),
        .Backup_Vout                (backup_Vouts_dp[1119:1088]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[34]),
        .Restore_Vin                (restore_Vins_dp[1119:1088]),
        .Rst                        (rst_rd3),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // source A3
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_sourceA3 (
        .Ld                         (ld_source_a3),
        .Vin                        (Vout_source_a2_wire),
        .Vout                       (),
        .Dirty_val                  (dirty_vals_dp[67:66]),
        .Backup_en                  (backup_ens_dp[33]),
        .Backup_ack                 (backup_acks_dp[33]),
        .Backup_Vout                (backup_Vouts_dp[1087:1056]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[33]),
        .Restore_Vin                (restore_Vins_dp[1087:1056]),
        .Rst                        (rst_source_a3),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // source B3
    RegN_IC_Wrapper #(
        .N                          (32)
    ) reg_sourceB3 (
        .Ld                         (ld_source_b3),
        .Vin                        (Vout_source_b2_wire),
        .Vout                       (),
        .Dirty_val                  (dirty_vals_dp[65:64]),
        .Backup_en                  (backup_ens_dp[32]),
        .Backup_ack                 (backup_acks_dp[32]),
        .Backup_Vout                (backup_Vouts_dp[1055:1024]),
        .Rst_DrtyCtrl               (Rst_Drty_Ctrl),
        .Restore_en                 (restore_ens_dp[32]),
        .Restore_Vin                (restore_Vins_dp[1055:1024]),
        .Rst                        (rst_source_b3),
        .Clk                        (Clk),
        .Pwr_off                    (Pwr_off)
    );
    
    // tri state buff Vin DRAM
    TriBuff #(
        .N                          (32)
    ) tri_st_buff_Vin_DRAM (
        .Vin                        (Vout_out_alu_wire),
        .En                         (en_mem),
        .Vout                       (VIN_DRAM)
    );
     
    // tri state buff Addr DRAM
    TriBuff #(
        .N                          (32)
    ) tri_st_buff_Addr_DRAM (
        .Vin                        (Vout_me_wire),
        .En                         (en_mem),
        .Vout                       (ADDR_DRAM)
    );

    // mux forw OUT ME
    MuxM_N1 #(
        .N                          (2),
        .M                          (32)
    ) mux_forw_OUT_ME (
        .Vin                        ({rf_write_val_wire, Vout_out_alu_wire}),
        .Sel                        (1'b1),
        .Vout                       (out_me_forw)
    );
    
    // Write Back
endmodule
