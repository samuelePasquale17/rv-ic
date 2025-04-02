# RISC-V Instruction Set

<img src="isa.png" width="500" />

## Instructions

### LUI (Load Upper Immediate)
`rd = imm << 12`
Loads an immediate value into the upper bits of a register.

### AUIPC (Add Upper Immediate to PC)
`rd = PC + (imm << 12)`
Loads an immediate value into the upper bits and adds it to the PC.

### JAL (Jump and Link)
`rd = PC + 4; PC = PC + imm`
Jumps to an address and saves the return address in `rd`.

### JALR (Jump and Link Register)
`rd = PC + 4; PC = (rs1 + imm) & ~1`
Jumps to an address specified in a register and saves the return address.

### BEQ (Branch if Equal)
`if (rs1 == rs2) PC = PC + imm`
Jumps to an address if two registers are equal.

### BNE (Branch if Not Equal)
`if (rs1 != rs2) PC = PC + imm`
Jumps to an address if two registers are not equal.

### BLT (Branch if Less Than)
`if (rs1 < rs2) PC = PC + imm`
Jumps to an address if one register is less than another (signed).

### BGE (Branch if Greater or Equal)
`if (rs1 >= rs2) PC = PC + imm`
Jumps to an address if one register is greater than or equal to another (signed).

### BLTU (Branch if Less Than Unsigned)
`if (rs1 < rs2) PC = PC + imm`
Jumps to an address if one register is less than another (unsigned).

### BGEU (Branch if Greater or Equal Unsigned)
`if (rs1 >= rs2) PC = PC + imm`
Jumps to an address if one register is greater than or equal to another (unsigned).

### LB (Load Byte)
`rd = M[rs1 + imm]`
Loads a byte from memory and sign-extends it.

### LH (Load Halfword)
`rd = M[rs1 + imm]`
Loads a halfword from memory and sign-extends it.

### LW (Load Word)
`rd = M[rs1 + imm]`
Loads a word from memory.

### LBU (Load Byte Unsigned)
`rd = M[rs1 + imm] & 0xFF`
Loads a byte from memory and zero-extends it.

### LHU (Load Halfword Unsigned)
`rd = M[rs1 + imm] & 0xFFFF`
Loads a halfword from memory and zero-extends it.

### SB (Store Byte)
`M[rs1 + imm] = rs2`
Stores a byte in memory.

### SH (Store Halfword)
`M[rs1 + imm] = rs2`
Stores a halfword in memory.

### SW (Store Word)
`M[rs1 + imm] = rs2`
Stores a word in memory.

### ADDI (Add Immediate)
`rd = rs1 + imm`
Adds an immediate value to a register.

### SLTI (Set Less Than Immediate)
`rd = (rs1 < imm) ? 1 : 0`
Sets rd to 1 if rs1 is less than the immediate value (signed).

### SLTIU (Set Less Than Immediate Unsigned)
`rd = (rs1 < imm) ? 1 : 0`
Sets rd to 1 if rs1 is less than the immediate value (unsigned).

### XORI (XOR Immediate)
`rd = rs1 ^ imm`
Performs a bitwise XOR between rs1 and an immediate value.

### ORI (OR Immediate)
`rd = rs1 | imm`
Performs a bitwise OR between rs1 and an immediate value.

### ANDI (AND Immediate)
`rd = rs1 & imm`
Performs a bitwise AND between rs1 and an immediate value.

### SLLI (Shift Left Logical Immediate)
`rd = rs1 << shamt`
Shifts rs1 left logically by shamt bits.

### SRLI (Shift Right Logical Immediate)
`rd = rs1 >> shamt`
Shifts rs1 right logically by shamt bits.

### SRAI (Shift Right Arithmetic Immediate)
`rd = rs1 >> shamt`
Shifts rs1 right arithmetically by shamt bits.

### ADD (Add)
`rd = rs1 + rs2`
Adds two registers.

### SUB (Subtract)
`rd = rs1 - rs2`
Subtracts rs2 from rs1.

### SLL (Shift Left Logical)
`rd = rs1 << rs2`
Shifts rs1 left logically by the value in rs2.

### SLT (Set Less Than)
`rd = (rs1 < rs2) ? 1 : 0`
Sets rd to 1 if rs1 is less than rs2 (signed).

### SLTU (Set Less Than Unsigned)
`rd = (rs1 < rs2) ? 1 : 0`
Sets rd to 1 if rs1 is less than rs2 (unsigned).

### XOR (XOR)
`rd = rs1 ^ rs2`
Performs a bitwise XOR between two registers.

### SRL (Shift Right Logical)
`rd = rs1 >> rs2`
Shifts rs1 right logically by the value in rs2.

### SRA (Shift Right Arithmetic)
`rd = rs1 >> rs2`
Shifts rs1 right arithmetically by the value in rs2.

### OR (OR)
`rd = rs1 | rs2`
Performs a bitwise OR between two registers.

### AND (AND)
`rd = rs1 & rs2`
Performs a bitwise AND between two registers.
