`include "ctrl_encode_def.v"

//123
module ctrl (
    Op,
    Funct7,
    Funct3,
    Zero,
    RegWrite,
    MemWrite,
    EXTOp,
    ALUOp,
    NPCOp,
    ALUSrc,
    WDSel,
    DMType,
);

  input [6:0] Op;  // opcode
  input [6:0] Funct7;  // funct7
  input [2:0] Funct3;  // funct3
  input Zero;

  output RegWrite;  // control signal for register write
  output MemWrite;  // control signal for memory write
  output [5:0] EXTOp;  // control signal to signed extension
  output [4:0] ALUOp;  // ALU opertion
  output [2:0] NPCOp;  // next pc operation
  output ALUSrc;  // ALU source for A
  output [2:0] DMType;
  output [1:0] WDSel;  // (register) write data selection

  // r format
  wire rtype = (Op == `R_TYPE);  //0110011
  wire r_add = (rtype & (Funct7 == `FUNCT7_ADD) & (Funct3 == `FUNCT3_ADD));  // r_add 0000000 000
  wire r_sub = (rtype & (Funct7 == `FUNCT7_SUB) & (Funct3 == `FUNCT3_SUB));  // r_sub 0100000 000
  wire r_sll = (rtype & (Funct7 == `FUNCT7_SLL) & (Funct3 == `FUNCT3_SLL));  // sll 0000000 001
  wire r_slt = (rtype & (Funct7 == `FUNCT7_SLT) & (Funct3 == `FUNCT3_SLT));  // slt 0000000 010
  wire r_sltu = (rtype & (Funct7 == `FUNCT7_SLTU) & (Funct3 == `FUNCT3_SLTU));  // sltu 0000000 011
  wire r_xor = (rtype & (Funct7 == `FUNCT7_XOR) & (Funct3 == `FUNCT3_XOR));  // xor 0000000 100
  wire r_srl = (rtype & (Funct7 == `FUNCT7_SRL) & (Funct3 == `FUNCT3_SRL));  // srl 0000000 101
  wire r_sra = (rtype & (Funct7 == `FUNCT7_SRA) & (Funct3 == `FUNCT3_SRA));  // sra 0100000 101
  wire r_or = (rtype & (Funct7 == `FUNCT7_OR) & (Funct3 == `FUNCT3_OR));  // or 0000000 110
  wire r_and = (rtype & (Funct7 == `FUNCT7_AND) & (Funct3 == `FUNCT3_AND));  // and 0000000 111


  // il format
  wire itype_load = (Op == `LOAD_TYPE);
  wire i_lb = (itype_load & (Funct3 == `FUNCT3_LB));    // lb 000
  wire i_lh = (itype_load & (Funct3 == `FUNCT3_LH));    // lh 001
  wire i_lw = (itype_load & (Funct3 == `FUNCT3_LW));    // lw 010
  wire i_lbu = (itype_load & (Funct3 == `FUNCT3_LBU));  // lbu 100
  wire i_lhu = (itype_load & (Funct3 == `FUNCT3_LHU));  // lhu 101

  // i format
  wire itype = (Op == `I_TYPE);
  wire i_addi = (itype & (Funct3 == `FUNCT3_ADDI));  // addi 000
  wire i_slti = (itype & (Funct3 == `FUNCT3_SLTI));  // slti 010
  wire i_sltiu = (itype & (Funct3 == `FUNCT3_SLTIU)); // sltiu 011
  wire i_xori = (itype & (Funct3 == `FUNCT3_XORI));  // xori 100
  wire i_ori = (itype & (Funct3 == `FUNCT3_ORI));  // ori 110
  wire i_andi = (itype & (Funct3 == `FUNCT3_ANDI)); // andi 111
  
  // immediate shift instructions
  wire i_slli = (itype & (Funct3 == `FUNCT3_SLLI) & (Funct7 == `FUNCT7_SLLI)); // slli
  wire i_srli = (itype & (Funct3 == `FUNCT3_SRLI) & (Funct7 == `FUNCT7_SRLI)); // srli
  wire i_srai = (itype & (Funct3 == `FUNCT3_SRAI) & (Funct7 == `FUNCT7_SRAI)); // srai

  //jalr
  wire jalr = (Op == `JALR_TYPE);  // jalr 1100111

  // j format
  wire jal = (Op == `JAL_TYPE);  // jal 1101111

  // s format
  wire stype = (Op == `S_TYPE);  // store type 0100011
  wire s_sw = (stype & (Funct3 == `FUNCT3_SW));  // sw 010
  wire s_sh = (stype & (Funct3 == `FUNCT3_SH));  // sh 001
  wire s_sb = (stype & (Funct3 == `FUNCT3_SB));  // sb 000

  // sb format
  wire sbtype = (Op == `SB_TYPE);  // branch type 1100011
  wire sb_beq = (sbtype & (Funct3 == `FUNCT3_BEQ));  // beq 000
  wire sb_bne = (sbtype & (Funct3 == `FUNCT3_BNE));  // bne 001
  wire sb_blt = (sbtype & (Funct3 == `FUNCT3_BLT));  // blt 100
  wire sb_bge = (sbtype & (Funct3 == `FUNCT3_BGE));  // bge 101
  wire sb_bltu = (sbtype & (Funct3 == `FUNCT3_BLTU));  // bltu 110
  wire sb_bgeu = (sbtype & (Funct3 == `FUNCT3_BGEU));  // bgeu 111

  // u format
  wire lui = (Op == `LUI_TYPE);  // lui 0110111
  wire auipc = (Op == `AUIPC_TYPE);  // auipc 0010111

  // generate control signals
  assign RegWrite = rtype | itype | itype_load | jalr | jal | lui | auipc;  // register write
  assign MemWrite = stype;  // memory write
  assign ALUSrc   = itype | itype_load | stype | jal | jalr | lui | auipc;  // ALU B is from instruction immediate

  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000 (for shift amounts)
  // EXT_CTRL_ITYPE	      6'b010000 (for regular I-type)
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5] = i_slli | i_srli | i_srai;  // shift amount extension
  assign EXTOp[4] = (itype | itype_load | jalr) & (~EXTOp[5]);  // regular I-type extension
  assign EXTOp[3] = stype;
  assign EXTOp[2] = sbtype;
  assign EXTOp[1] = lui | auipc;
  assign EXTOp[0] = jal;




  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = itype_load;
  assign WDSel[1] = jal | jalr;

  // NPCOp assignments
  // NPC_PLUS4   3'b000 - next PC = PC + 4
  // NPC_BRANCH  3'b001 - next PC = PC + immediate (branch taken)
  // NPC_JUMP    3'b010 - next PC = PC + immediate (jal)
  // NPC_JALR    3'b100 - next PC = ALU result (jalr)
  // Note: Branch condition evaluation is done by ALU, Zero flag indicates condition result
  assign NPCOp[0] = (sb_beq & Zero) | (sb_bne & ~Zero) | 
                   (sb_blt & ~Zero) | (sb_bge & Zero) | 
                   (sb_bltu & ~Zero) | (sb_bgeu & Zero);
  assign NPCOp[1] = jal;
  assign NPCOp[2] = jalr;



  // ALUOp assignments for 5-bit control signal
  // ALUOp encoding (refer to ctrl_encode_def.v):
  // ALUOp_nop   = 5'b00000, ALUOp_lui   = 5'b00001, ALUOp_auipc = 5'b00010
  // ALUOp_add   = 5'b00011, ALUOp_sub   = 5'b00100, ALUOp_bne   = 5'b00101
  // ALUOp_blt   = 5'b00110, ALUOp_bge   = 5'b00111, ALUOp_bltu  = 5'b01000
  // ALUOp_bgeu  = 5'b01001, ALUOp_slt   = 5'b01010, ALUOp_sltu  = 5'b01011
  // ALUOp_xor   = 5'b01100, ALUOp_or    = 5'b01101, ALUOp_and   = 5'b01110
  // ALUOp_sll   = 5'b01111, ALUOp_srl   = 5'b10000, ALUOp_sra   = 5'b10001
  
  assign ALUOp =
      // nop
      5'b00000 & {5{1'b0}} |
      // lui
      ({5{lui}}    & 5'b00001) |
      // auipc
      ({5{auipc}}  & 5'b00010) |
      // add, addi, load, store, jal, jalr
      ({5{r_add | i_addi | itype_load | stype | jal | jalr}} & 5'b00011) |
      // sub
      ({5{r_sub}}  & 5'b00100) |
      // bne
      ({5{sb_bne}} & 5'b00101) |
      // blt
      ({5{sb_blt}} & 5'b00110) |
      // bge
      ({5{sb_bge}} & 5'b00111) |
      // bltu
      ({5{sb_bltu}} & 5'b01000) |
      // bgeu
      ({5{sb_bgeu}} & 5'b01001) |
      // slt, slti
      ({5{r_slt | i_slti}} & 5'b01010) |
      // sltu, sltiu
      ({5{r_sltu | i_sltiu}} & 5'b01011) |
      // xor, xori
      ({5{r_xor | i_xori}} & 5'b01100) |
      // or, ori
      ({5{r_or | i_ori}} & 5'b01101) |
      // and, andi
      ({5{r_and | i_andi}} & 5'b01110) |
      // sll, slli
      ({5{r_sll | i_slli}} & 5'b01111) |
      // srl, srli
      ({5{r_srl | i_srli}} & 5'b10000) |
      // sra, srai
      ({5{r_sra | i_srai}} & 5'b10001);

  assign DMType = ({3{s_sw}} & `dm_word) | 
                  ({3{s_sh}} & `dm_halfword) | 
                  ({3{s_sb}} & `dm_byte) |
                  ({3{i_lw}} & `dm_word) |
                  ({3{i_lh}} & `dm_halfword) |
                  ({3{i_lb}} & `dm_byte) |
                  ({3{i_lhu}} & `dm_halfword_unsigned) |
                  ({3{i_lbu}} & `dm_byte_unsigned);

endmodule
