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
    GPRSel,
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
  output [1:0] GPRSel;  // general purpose register selection
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


  // i format
  wire itype_load = (Op == `LOAD_TYPE);

  // i format
  wire itype = (Op == `I_TYPE);
  wire i_addi = (itype & (Funct3 == `FUNCT3_ADDI));  // addi 000
  wire i_ori = (itype & (Funct3 == `FUNCT3_ORI));  // ori 110

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
  assign RegWrite = rtype | itype | jalr | jal | lui | auipc;  // register write
  assign MemWrite = stype;  // memory write
  assign ALUSrc   = itype | stype | jal | jalr | lui | auipc;  // ALU B is from instruction immediate

  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
  assign EXTOp[5] = 0;
  //assign EXTOp[4]    =  i_ori | i_andi | jalr;
  assign EXTOp[4] = i_ori;
  assign EXTOp[3] = stype;
  assign EXTOp[2] = sbtype;
  assign EXTOp[1] = lui | auipc;
  assign EXTOp[0] = jal;




  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = itype_load;
  assign WDSel[1] = jal | jalr;

  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	3'b100
  assign NPCOp[0] = sbtype & Zero;
  assign NPCOp[1] = jal;
  assign NPCOp[2] = jalr;



  assign ALUOp[0] = itype_load | stype | i_addi | i_ori | r_add | r_or | lui;
  assign ALUOp[1] = jalr | itype_load | stype | i_addi | r_add | r_and | auipc;
  //assign ALUOp[2] = i_andi|r_and|i_ori|r_or|sb_beq|r_sub;
  //assign ALUOp[3] = i_andi|r_and|i_ori|r_or;
  assign ALUOp[2] = r_and | i_ori | r_or | sb_beq | r_sub;
  assign ALUOp[3] = r_and | i_ori | r_or;
  assign ALUOp[4] = 0;

  assign DMType = ({3{s_sw}} & 3'b100) | 
                  ({3{s_sh}} & 3'b010) | 
                  ({3{s_sb}} & 3'b001);

endmodule
