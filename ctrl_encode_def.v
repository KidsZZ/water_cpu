// NPC control signal
`define NPC_PLUS4 3'b000
`define NPC_BRANCH 3'b001
`define NPC_JUMP 3'b010
`define NPC_JALR 3'b100

// ALU control signal
`define ALU_NOP 3'b000 
`define ALU_ADD 3'b001
`define ALU_SUB 3'b010 
`define ALU_AND 3'b011
`define ALU_OR 3'b100

//EXT CTRL itype, stype, btype, utype, jtype
`define EXT_CTRL_ITYPE_SHAMT 6'b100000
`define EXT_CTRL_ITYPE 6'b010000
`define EXT_CTRL_STYPE 6'b001000
`define EXT_CTRL_BTYPE 6'b000100
`define EXT_CTRL_UTYPE 6'b000010
`define EXT_CTRL_JTYPE 6'b000001

`define GPRSel_RD 2'b00
`define GPRSel_RT 2'b01
`define GPRSel_31 2'b10

`define WDSel_FromALU 2'b00
`define WDSel_FromMEM 2'b01
`define WDSel_FromPC 2'b10

`define ALUOp_nop 5'b00000
`define ALUOp_lui 5'b00001
`define ALUOp_auipc 5'b00010
`define ALUOp_add 5'b00011
`define ALUOp_sub 5'b00100
`define ALUOp_bne 5'b00101
`define ALUOp_blt 5'b00110
`define ALUOp_bge 5'b00111
`define ALUOp_bltu 5'b01000
`define ALUOp_bgeu 5'b01001
`define ALUOp_slt 5'b01010
`define ALUOp_sltu 5'b01011
`define ALUOp_xor 5'b01100
`define ALUOp_or 5'b01101
`define ALUOp_and 5'b01110
`define ALUOp_sll 5'b01111
`define ALUOp_srl 5'b10000
`define ALUOp_sra 5'b10001

`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100

// R_type
`define R_TYPE 7'b0110011

`define FUNCT7_ADD	7'b0000000
`define FUNCT3_ADD	3'b000

`define FUNCT7_SUB	7'b0100000
`define FUNCT3_SUB	3'b000

`define FUNCT7_SLL	7'b0000000
`define FUNCT3_SLL	3'b001

`define FUNCT7_SLT	7'b0000000
`define FUNCT3_SLT	3'b010

`define FUNCT7_SLTU	7'b0000000
`define FUNCT3_SLTU	3'b011

`define FUNCT7_XOR	7'b0000000
`define FUNCT3_XOR	3'b100

`define FUNCT7_SRL	7'b0000000
`define FUNCT3_SRL	3'b101

`define FUNCT7_SRA	7'b0100000
`define FUNCT3_SRA	3'b101

`define FUNCT7_OR	7'b0000000
`define FUNCT3_OR	3'b110

`define FUNCT7_AND	7'b0000000
`define FUNCT3_AND	3'b111

// I_type
`define I_TYPE 7'b0010011

`define FUNCT3_ADDI	3'b000
`define FUNCT3_SLTI	3'b010
`define FUNCT3_SLTIU	3'b011
`define FUNCT3_XORI	3'b100
`define FUNCT3_ORI	3'b110
`define FUNCT3_ANDI	3'b111

`define FUNCT7_SLLI	7'b0000000
`define FUNCT3_SLLI	3'b001

`define FUNCT7_SRLI	7'b0000000
`define FUNCT3_SRLI	3'b101

`define FUNCT7_SRAI	7'b0100000
`define FUNCT3_SRAI	3'b101

// LOAD_type
`define LOAD_TYPE 7'b0000011

`define FUNCT3_LB	3'b000
`define FUNCT3_LH	3'b001
`define FUNCT3_LW	3'b010
`define FUNCT3_LBU	3'b100
`define FUNCT3_LHU	3'b101

// Stype
`define S_TYPE 7'b0100011

`define FUNCT3_SB	3'b000
`define FUNCT3_SH	3'b001
`define FUNCT3_SW	3'b010

// SB_type
`define SB_TYPE 7'b1100011

`define FUNCT3_BEQ	3'b000
`define FUNCT3_BNE	3'b001
`define FUNCT3_BLT	3'b100
`define FUNCT3_BGE	3'b101
`define FUNCT3_BLTU	3'b110
`define FUNCT3_BGEU	3'b111

// JALR_type
`define JALR_TYPE 7'b1100111

// JAL_type
`define JAL_TYPE 7'b1101111

// LUI_type
`define LUI_TYPE 7'b0110111

// AUIPC_type
`define AUIPC_TYPE 7'b0010111



