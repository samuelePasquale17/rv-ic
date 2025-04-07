`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU #(
        parameter N = 4
    ) (
        A,
        B,
        Cin,
        Cout,
        Ctrl,
        // Ctrl = 0000 => Add
        // Ctrl = 0001 => Sub
        // Ctrl = 0010 => OR
        // Ctrl = 0011 => XOR
        // Ctrl = 0100 => AND
        // Ctrl = 0101 => SRL
        // Ctrl = 0110 => SRA
        // Ctrl = 0111 => SLL
        // Ctrl = 1000 => SLTU
        // Ctrl = 1001 => SLT
        // Ctrl = 1010 => LUI B
        // Ctrl = 1011 => Shift Left B by 12
        // Ctrl = 1100 => (B << 12) + A
        Res,
        Cmp
    );
    
    input [N-1:0] A;
    input [N-1:0] B;
    input [3:0] Ctrl;
    input Cin;
    
    output reg [N-1:0] Res;
    output reg Cout;
    output reg Cmp;

    always @(A, B, Ctrl, Cin) begin
        Res <= {N{1'b0}};
        Cout <= 1'b0;
        Cmp <= 1'b0;
        
                if (Ctrl === 4'b0000) {Cout, Res} <= A + B + Cin;   // Add
        else    if (Ctrl === 4'b0001) Res <= A - B;                 // Sub
        else    if (Ctrl === 4'b0010) Res <= A | B;                 // OR
        else    if (Ctrl === 4'b0011) Res <= A ^ B;                 // XOR
        else    if (Ctrl === 4'b0100) Res <= A & B;                 // AND
        else    if (Ctrl === 4'b0101) Res <= A >> B;                // SRL
        else    if (Ctrl === 4'b0110) Res <= $signed(A) >>> B;      // SRA
        else    if (Ctrl === 4'b0111) Res <= A << B;                // SLL
        else    if (Ctrl === 4'b1000) Cmp <= (A < B) ? 1'b1 : 1'b0; // SLTU
        else    if (Ctrl === 4'b1001) Cmp <= ($signed(A) < $signed(B)) ? 1'b1 : 1'b0; // SLT
        else    if (Ctrl === 4'b1011) Res <= B << 12;               // Shift Left B by 12
        else    if (Ctrl === 4'b1100) Res <= (B << 12) + A;         // (B << 12) + A
    end
endmodule
