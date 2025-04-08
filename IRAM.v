`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module IRAM #(
        parameter N = 32,  // Width
        parameter K = 512  // Number of memory locations
    ) (
        Addr,
        Data,
        Clk,
        Rst
    );
    
    input [$clog2(K)-1:0] Addr;
    output reg [N-1:0] Data;
    input Clk;
    input Rst;

    // Memory array
    reg [N-1:0] mem [0:K-1];
    
    // Load memory content from file and initialize remaining memory to 0
    integer i;
    initial begin
        for (i = 0; i < K; i = i + 1) begin
            mem[i] = 0;
        end
        $readmemh("code.mem", mem);
    end
    
    // Read operation
    always @(posedge Clk or posedge Rst) begin
        if (Rst)
            Data <= 0;
        else
            Data <= mem[Addr];
    end

endmodule
