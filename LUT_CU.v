`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////


module LUT_CU(
        opcode,
        func3,
        func7,
        En,
        CtrlWrd
    );
    
    
    input [6:0] opcode;
    input [2:0] func3;
    input [6:0] func7;
    input En;
    output reg [57:0] CtrlWrd;


    always @(*) begin
        if (!En)
            CtrlWrd = 56'b0;
        else begin
            casex ({func7, func3, opcode})
                // opcode func3 func7
                17'bXXXXXXXXXX0110111: CtrlWrd = 58'b0000000000001100001010101010101011000100001101010100000001;  // LUI
                17'bXXXXXXXXXX0010111: CtrlWrd = 58'b0000000000001101001010101010101100000100001101010100000001;  // AUIPC
                17'bXXXXXXXXXX1101111: CtrlWrd = 58'b0000000100000001000010101010100000010100001101010100000001;  // JAL
                17'bXXXXXXX0001100111: CtrlWrd = 58'b0010000110000001000010101010100000010100001101010100000001;  // JALR
                17'bXXXXXXX0001100011: CtrlWrd = 58'b1000001011000000000001010101010000000010000000101010000000;  // BEQ
                17'bXXXXXXX0011100011: CtrlWrd = 58'b1000011011000000000001010101010000000010000000101010000000;  // BNE
                17'bXXXXXXX1001100011: CtrlWrd = 58'b1000101011000000000001010101010000000010000000101010000000;  // BLT
                17'bXXXXXXX1011100011: CtrlWrd = 58'b1001011011000000000001010101010000000010000000101010000000;  // BGE
                17'bXXXXXXX1101100011: CtrlWrd = 58'b1001101011000000000001010101010000000010000000101010000000;  // BLTU
                17'bXXXXXXX1111100011: CtrlWrd = 58'b1001111011000000000001010101010000000010000000101010000000;  // BGEU
                17'bXXXXXXX0000000011: CtrlWrd = 58'b0000000010010001001010101010100000000101000101010101110001;  // LB
                17'bXXXXXXX0010000011: CtrlWrd = 58'b0000000010010001001010101010100000000101000101010101110011;  // LH
                17'bXXXXXXX0100000011: CtrlWrd = 58'b0000000010010001001010101010100000000101000101010101110101;  // LW
                17'bXXXXXXX1000000011: CtrlWrd = 58'b0000000010010001001010101010100000000101000101010101100001;  // LBU
                17'bXXXXXXX1010000011: CtrlWrd = 58'b0000000010010001001010101010100000000101000101010101100011;  // LHU
                17'bXXXXXXX0000100011: CtrlWrd = 58'b0000000011010101101010100101100000001101001101001101001001;  // SB
                17'bXXXXXXX0010100011: CtrlWrd = 58'b0000000011010101101010100101100000001101001101001101001011;  // SH
                17'bXXXXXXX0100100011: CtrlWrd = 58'b0000000011010101101010100101100000001101001101001101001101;  // SW
                17'bXXXXXXX0000010011: CtrlWrd = 58'b0000000010010001001010011010010000000100001101010010000001;  // ADDI
                17'bXXXXXXX0100010011: CtrlWrd = 58'b0000000010010001001010011010011001000100001101010010000001;  // SLTI
                17'bXXXXXXX0110010011: CtrlWrd = 58'b0000000010010001001010011010011000000100001101010010000001;  // SLTIU
                17'bXXXXXXX1000010011: CtrlWrd = 58'b0000000010010001001010011010010011000100001101010010000001;  // XORI
                17'bXXXXXXX1100010011: CtrlWrd = 58'b0000000010010001001010011010010010000100001101010010000001;  // ORI
                17'bXXXXXXX1110010011: CtrlWrd = 58'b0000000010010001001010011010010100000100001101010010000001;  // ANDI
                17'b00000000010010011: CtrlWrd = 58'b0000000010011001001010011010010111000100001101010010000001;  // SLLI
                17'b00000001010010011: CtrlWrd = 58'b0000000010011001001010011010010101000100001101010010000001;  // SRLI
                17'b01000001010010011: CtrlWrd = 58'b0000000010011001001010011010010110000100001101010010000001;  // SRAI
                17'b00000000000010011: CtrlWrd = 58'b0000000011010001100010101010100000100100001101010100000001;  // ADD
                17'b01000000000010011: CtrlWrd = 58'b0000000011010001100010101010100001100100001101010100000001;  // SUB
                17'b00000000010010011: CtrlWrd = 58'b0000000011010001100010101010100111100100001101010100000001;  // SLL
                17'b00000000100010011: CtrlWrd = 58'b0000000011010001100010101010101001100100001101010100000001;  // SLT
                17'b00000000110010011: CtrlWrd = 58'b0000000011010001100010101010101000100100001101010100000001;  // SLTU
                17'b00000001000010011: CtrlWrd = 58'b0000000011010001100010101010100011100100001101010100000001;  // XOR
                17'b00000001010010011: CtrlWrd = 58'b0000000011010001100010101010100101100100001101010100000001;  // SRL
                17'b01000001010010011: CtrlWrd = 58'b0000000011010001100010101010100110100100001101010100000001;  // SRA
                17'b00000001100010011: CtrlWrd = 58'b0000000011010001100010101010100010100100001101010100000001;  // OR
                17'b00000001110010011: CtrlWrd = 58'b0000000011010001100010101010100100100100001101010100000001;  // AND
                default: CtrlWrd = 58'b0;
            endcase
        end
    end

endmodule

