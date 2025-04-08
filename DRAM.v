`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module DRAM #(
        parameter N = 32,  // Width (32 bits)
        parameter K = 512  // Number of memory locations
    ) (
        Addr,
        Vin,
        Rst,
        En,
        Rw,
        SigExt,  // 0 unsigned, 1 signed
        B_H_W,  // 00 byte, 01 half, 10 word
        Vout,
        Ack
    );
    
    input [$clog2(K)-1:0] Addr;
    input [N-1:0] Vin;
    input Rst;
    input En;
    input Rw;
    input SigExt;
    input [1:0] B_H_W;
    
    
    output reg [N-1:0] Vout;
    output reg Ack;
    
    reg [N-1:0] mem [0:K-1];
    reg [N-1:0] tmp_val;
    
    integer i;
    
    initial begin
        for (i = 0; i < K; i = i + 1) begin
            mem[i] = 0;
        end
        $readmemh("DRAM.mem", mem);
    end
    
    always @(*) begin
        Ack <= 1'bZ;
        Vout <= {N{1'bZ}};
        
        if (Rst) begin
            for (i = 0; i < K; i = i + 1) begin
                mem[i] = 0;
            end 
        end
        else if (En) begin
            if (Rw) begin
                // Write
                if (B_H_W == 2'b00) begin
                    // byte
                    mem[Addr] <= {{N-8{1'b0}}, 8'hFF} & Vin;
                    Ack <= 1'b1;
                end 
                else if (B_H_W == 2'b01) begin
                    // half
                    mem[Addr] <= {{N-16{1'b0}}, 16'hFFFF} & Vin;
                    Ack <= 1'b1;
                end 
                else begin
                    // word
                    mem[Addr] <= {{N-32{1'b0}}, 32'hFFFFFFFF} & Vin;
                    Ack <= 1'b1;
                end    
            end
            else begin
                // Read
                if (B_H_W == 2'b00) begin
                    // byte
                    if (SigExt) begin
                        // sig ext
                        Vout <= {{N-8{mem[Addr][7]}}, mem[Addr][7:0]};
                        Ack <= 1'b1;
                    end
                    else begin
                        // unsigned
                        Vout <= {{N-8{1'b0}}, mem[Addr][7:0]};
                        Ack <= 1'b1;
                    end
                    
                end 
                else if (B_H_W == 2'b01) begin
                    // half
                    if (SigExt) begin
                        // sig ext
                        Vout <= {{N-16{mem[Addr][15]}}, mem[Addr][15:0]};
                        Ack <= 1'b1;
                    end
                    else begin
                        // unsigned
                        Vout <= {{N-16{1'b0}}, mem[Addr][15:0]};
                        Ack <= 1'b1;
                    end
                end 
                else begin
                    // word
                    Vout <= mem[Addr];
                    Ack <= 1'b1;
                end
            end
        end
    end

    
endmodule
