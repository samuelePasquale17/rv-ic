import sys

# registers x0 - x31

instructionSet = [  "LUI", 
                    "AUIPC", 
                    "JAL", 
                    "JALR", 
                    "BEQ", 
                    "BNE", 
                    "BLT", 
                    "BGE",
                    "BLTU", 
                    "BGEU", 
                    "LB", 
                    "LH", 
                    "LW", 
                    "LBU", 
                    "LHU", 
                    "SB", 
                    "SH", 
                    "SW", 
                    "ADDI", 
                    "SLTI", 
                    "SLTIU", 
                    "XORI", 
                    "ORI", 
                    "ANDI", 
                    "SLLI", 
                    "SRLI", 
                    "SRAI", 
                    "ADD", 
                    "SUB",
                    "SLL", 
                    "SLT", 
                    "SLTU", 
                    "XOR", 
                    "SRL", 
                    "SRA", 
                    "OR", 
                    "AND",]


def get_val_reg(reg_str):
    return format(int(reg_str.strip("x")), '05b')

def get_val_imm(imm_str, num_bits):
    if ("x" in imm_str):
        # hex
        return format(int(imm_str[2:], 16), f"0{num_bits}b")
    elif ("b" in imm_str):
        # bin
        return (imm_str[2:])[0] * (num_bits - len(imm_str.strip("0b"))) + (imm_str.strip("0b"))
    else:
        return format(int(imm_str), f"0{num_bits}b")
    

def get_addr(addr_str, num_bits_imm):
    return get_val_imm(((addr_str[0:len(addr_str)-2]).split("("))[0], num_bits_imm), get_val_reg(addr_str.split("(")[1][0:-1])


def read_and_reverse_file(filename):
    try:
        with open(filename, "r") as file:
            lines = file.readlines()
            final_file = []
            for line in lines: 
                if (not(len(line) <= 1 and line[0] != " ")):  # skip empty lines
                    instr = (line.strip().split(" "))[0]  # read instruction
                    if (instr == "#"):  # comment
                        pass
                    elif (instr in instructionSet):  # instruction
                        if (instr in ["LUI", "AUIPC"]):
                            val_rd = get_val_reg((line.strip().split(" "))[1].strip(","))  # get rd
                            imm = get_val_imm((line.strip().split(" "))[2].strip(","), 20)  # get imm
                            if (instr == "LUI"):
                                code = imm + val_rd + "0110111"
                            else:
                                code = imm + val_rd + "0010111"
                            final_file.append(code)

                        elif (instr in ["JAL"]):
                            val_rd = get_val_reg((line.strip().split(" "))[1].strip(","))  # get rd
                            val_label = get_val_imm((line.strip().split(" "))[2].strip(","), 20)
                            code = val_label + val_rd + "1101111"
                            final_file.append(code)

                        elif (instr in ["JALR"]):
                            val_rd = get_val_reg((line.strip().split(" "))[1].strip(","))
                            val_rs1 = get_val_reg((line.strip().split(" "))[2].strip(","))
                            val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 12)
                            code = val_imm + val_rs1 + "000" + val_rd + "1100111"
                            final_file.append(code)

                        elif (instr in ["BEQ", "BNE", "BLT", "BGE", "BLTU", "BGEU"]):
                            val_rs1 = get_val_reg((line.strip().split(" "))[1].strip(","))
                            val_rs2 = get_val_reg((line.strip().split(" "))[2].strip(","))
                            val_label = get_val_imm((line.strip().split(" "))[3].strip(","), 12)

                            if (instr == "BEQ"):
                                code = val_label[0:7] + val_rs2 + val_rs1 + "000" + val_label[7:12] + "1100011"
                            elif (instr == "BNE"):
                                code = val_label[0:7] + val_rs2 + val_rs1 + "001" + val_label[7:12] + "1100011"
                            elif (instr == "BLT"):
                                code = val_label[0:7] + val_rs2 + val_rs1 + "100" + val_label[7:12] + "1100011"
                            elif (instr == "BGE"):
                                code = val_label[0:7] + val_rs2 + val_rs1 + "101" + val_label[7:12] + "1100011"
                            elif (instr == "BLTU"):
                                code = val_label[0:7] + val_rs2 + val_rs1 + "110" + val_label[7:12] + "1100011"
                            else: # BGEU
                                code = val_label[0:7] + val_rs2 + val_rs1 + "111" + val_label[7:12] + "1100011"
                            
                            final_file.append(code)


                        elif (instr in ["LB", "LH", "LW", "LBU", "LHU"]):
                            val_rd = get_val_reg((line.strip().split(" "))[1].strip(","))
                            offset, val_rs1 = get_addr((line.strip().split(" "))[2].strip(","), 12)

                            if (instr == "LB"):
                                code = offset + val_rs1 + "000" + val_rd + "0000011"
                            elif (instr == "LH"):
                                code = offset + val_rs1 + "001" + val_rd + "0000011"
                            elif (instr == "LW"):
                                code = offset + val_rs1 + "010" + val_rd + "0000011"
                            elif (instr == "LBU"):
                                code = offset + val_rs1 + "100" + val_rd + "0000011"
                            else:  # LHU
                                code = offset + val_rs1 + "101" + val_rd + "0000011"

                            final_file.append(code)
             
                        elif (instr in ["SB", "SH", "SW"]):
                            val_rs2 = get_val_reg((line.strip().split(" "))[1].strip(","))
                            offset, val_rs1 = get_addr((line.strip().split(" "))[2].strip(","), 12)
                            if (instr == "SB"):
                                code = offset[0:7] + val_rs2 + val_rs1 + "000" + offset[7:12] + "0100011"
                            elif (instr == "SH"):
                                code = offset[0:7] + val_rs2 + val_rs1 + "001" + offset[7:12] + "0100011"
                            else:  # SW
                                code = offset[0:7] + val_rs2 + val_rs1 + "010" + offset[7:12] + "0100011"

                            final_file.append(code)

                        elif (instr in ["ADDI", "SLTI", "SLTIU", "XORI", "ORI", "ANDI", "SLLI", "SRLI", "SRAI"]):
                            val_rd = get_val_reg((line.strip().split(" "))[1].strip(","))
                            val_rs1 = get_val_reg((line.strip().split(" "))[2].strip(","))
                            

                            if (instr == "ADDI"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 12)
                                code = val_imm + val_rs1 + "000" + val_rd + "0010011"

                            elif (instr == "SLTI"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 12)
                                code = val_imm + val_rs1 + "010" + val_rd + "0010011"

                            elif (instr == "SLTIU"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 12)
                                code = val_imm + val_rs1 + "011" + val_rd + "0010011"

                            elif (instr == "XORI"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 12)
                                code = val_imm + val_rs1 + "100" + val_rd + "0010011"

                            elif (instr == "ORI"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 12)
                                code = val_imm + val_rs1 + "110" + val_rd + "0010011"

                            elif (instr == "ANDI"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 12)
                                code = val_imm + val_rs1 + "111" + val_rd + "0010011"

                            elif (instr == "SLLI"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 5)
                                code = "0000000" + val_imm + val_rs1 + "001" + val_rd + "0010011"

                            elif (instr == "SRLI"):
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 5)
                                code = "0000000" + val_imm + val_rs1 + "101" + val_rd + "0010011"

                            else:  # SRAI
                                val_imm = get_val_imm((line.strip().split(" "))[3].strip(","), 5)
                                code = "0100000" + val_imm + val_rs1 + "101" + val_rd + "0010011"

                            final_file.append(code)
                            
                        else:  # ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                            val_rd = get_val_reg((line.strip().split(" "))[1].strip(","))
                            val_rs1 = get_val_reg((line.strip().split(" "))[2].strip(","))
                            val_rs2 = get_val_reg((line.strip().split(" "))[3].strip(","))
                            
                            if (instr == "ADD"):
                                code = "0000000" + val_rs2 + val_rs1 + "000" + val_rd + "0110011"
                            elif (instr == "SUB"):
                                code = "0100000" + val_rs2 + val_rs1 + "000" + val_rd + "0110011"
                            elif (instr == "SLL"):
                                code = "0000000" + val_rs2 + val_rs1 + "001" + val_rd + "0110011"
                            elif (instr == "SLT"):
                                code = "0000000" + val_rs2 + val_rs1 + "010" + val_rd + "0110011"
                            elif (instr == "SLTU"):
                                code = "0000000" + val_rs2 + val_rs1 + "011" + val_rd + "0110011"
                            elif (instr == "XOR"):
                                code = "0000000" + val_rs2 + val_rs1 + "100" + val_rd + "0110011"
                            elif (instr == "SRL"):
                                code = "0000000" + val_rs2 + val_rs1 + "101" + val_rd + "0110011"
                            elif (instr == "SRA"):
                                code = "0100000" + val_rs2 + val_rs1 + "101" + val_rd + "0110011"
                            elif (instr == "OR"):
                                code = "0000000" + val_rs2 + val_rs1 + "110" + val_rd + "0110011"
                            else:  # AND
                                code = "0000000" + val_rs2 + val_rs1 + "111" + val_rd + "0110011"

                            final_file.append(code)
                    
                    elif (instr == "NOP"):
                        code = "00000000000000000000000000000000"
                        final_file.append(code)
                    else:  # label
                        pass

                

        for code in final_file:
            print(code)



    except FileNotFoundError:
        print(f"Error: The file '{filename}' was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
    else:
        read_and_reverse_file(sys.argv[1])
