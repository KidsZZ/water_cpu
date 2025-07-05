`include "ctrl_encode_def.v"

module SCPU (
    input         clk,        // clock
    input         rst,        // rst
    input         MIO_ready,
    input  [31:0] inst_in,    // instruction
    input  [31:0] Data_in,    // data from data memory
    output        mem_w,      // output: memory write signal
    output [31:0] PC_out,     // PC address
    // memory write
    output [ 2:0] DMType,     // dm control signal
    output [31:0] Addr_out,   // ALU output
    output [31:0] Data_out,   // data to data memory
    output        CPU_MIO,
    input         INT

    // input  [4:0] reg_sel,    // register selection (for debug use)
    // output [31:0] reg_data , // selected register data (for debug use)
    //    output [2:0] DMType
);

  // Wire declarations
  wire [63:0] IF_ID_in;
  wire [63:0] IF_ID_out;
  wire [160:0] ID_EX_in;
  wire [160:0] ID_EX_out;
  wire [110:0] EX_MEM_in;
  wire [110:0] EX_MEM_out;
  wire [103:0] MEM_WB_in;
  wire [103:0] MEM_WB_out;
  wire IF_ID_write_enable;
  wire IF_ID_flush;
  wire ID_EX_write_enable;
  wire ID_EX_flush;
  wire EX_MEM_write_enable;
  wire MEM_WB_write_enable;
  wire [31:0] IF_ID_PC;
  wire [31:0] IF_ID_inst;
  wire [6:0] Op;
  wire [2:0] Funct3;
  wire [6:0] Funct7;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [31:0] immout;
  wire [4:0] iimm_shamt;
  wire [11:0] iimm;
  wire [11:0] simm;
  wire [11:0] bimm;
  wire [19:0] uimm;
  wire [19:0] jimm;
  wire [31:0] aluout_EX;
  wire Zero_EX;
  wire RegWrite_EX;
  wire MemWrite_EX;
  wire [4:0] ALUOp_EX;
  wire ALUSrc_EX;
  wire [1:0] GPRSel_EX;
  wire [1:0] WDSel_EX;
  wire [2:0] DMType_EX;
  wire [2:0] NPCOp_EX;
  wire [31:0] RD1_EX;
  wire [31:0] RD2_EX;
  wire [31:0] immout_EX;
  wire [4:0] rs1_EX;
  wire [4:0] rs2_EX;
  wire [4:0] rd_EX;
  wire [31:0] PC_EX;
  wire [31:0] NPC;
  wire [31:0] PC_MEM;
  wire RegWrite_MEM;
  wire MemWrite_MEM;
  wire [1:0] WDSel_MEM;
  wire [1:0] GPRSel_MEM;
  wire [2:0] DMType_MEM;
  wire [31:0] aluout_MEM;
  wire [31:0] RD2_MEM;
  wire [4:0] rd_MEM;
  wire [31:0] PC_WB;
  wire RegWrite_WB;
  wire [1:0] WDSel_WB;
  wire [31:0] Data_in_WB;
  wire [31:0] aluout_WB;
  wire [4:0] rd_WB;
  wire RegWrite;
  wire MemWrite;
  wire ALUSrc;
  wire [1:0] WDSel;
  wire [1:0] GPRSel;
  wire [4:0] ALUOp;
  wire [2:0] NPCOp;
  wire [2:0] DMType_ID;
  wire [5:0] EXTOp;
  wire Zero;
  wire ID_EX_MemRead;
  wire [31:0] RD1;
  wire [31:0] RD2;
  wire stall_signal;
  wire Branch_or_Jump;
  wire [1:0] ForwardA;
  wire [1:0] ForwardB;
  wire [31:0] RD1_forwarded;
  wire [31:0] RD2_forwarded;
  wire [31:0] B_EX;
  wire PCWrite;
  reg [31:0] RF_WD;


  // Wire assignments
  assign ID_EX_write_enable = 1'b1;
  assign EX_MEM_write_enable = 1'b1;
  assign MEM_WB_write_enable = 1'b1;
  // IF_ID
  assign IF_ID_in = {PC_out, inst_in};
  assign IF_ID_PC = IF_ID_out[63:32];
  assign IF_ID_inst = IF_ID_out[31:0];
  assign Op = IF_ID_inst[6:0];
  assign Funct3 = IF_ID_inst[14:12];
  assign Funct7 = IF_ID_inst[31:25];
  assign rs1 = IF_ID_inst[19:15];
  assign rs2 = IF_ID_inst[24:20];
  assign rd = IF_ID_inst[11:7];
  assign iimm_shamt = IF_ID_inst[24:20];
  assign iimm = IF_ID_inst[31:20];
  assign simm = {IF_ID_inst[31:25], IF_ID_inst[11:7]};
  assign bimm = {IF_ID_inst[31], IF_ID_inst[7], IF_ID_inst[30:25], IF_ID_inst[11:8]};
  assign uimm = IF_ID_inst[31:12];
  assign jimm = {IF_ID_inst[31], IF_ID_inst[19:12], IF_ID_inst[20], IF_ID_inst[30:21]};

  // ID_EX
  assign ID_EX_in = {
    RegWrite,
    MemWrite,
    ALUOp,
    ALUSrc,
    GPRSel,
    WDSel,
    DMType_ID,
    NPCOp,
    RD1,
    RD2,
    immout,
    rs1,
    rs2,
    rd,
    IF_ID_PC
  };
  assign RegWrite_EX = ID_EX_out[160];
  assign MemWrite_EX = ID_EX_out[159];
  assign ALUOp_EX = ID_EX_out[158:154];
  assign ALUSrc_EX = ID_EX_out[153];
  assign GPRSel_EX = ID_EX_out[152:151];
  assign WDSel_EX = ID_EX_out[150:149];
  assign DMType_EX = ID_EX_out[148:146];
  assign NPCOp_EX = {ID_EX_out[145:144], ID_EX_out[143] & Zero_EX};
  assign RD1_EX = ID_EX_out[142:111];
  assign RD2_EX = ID_EX_out[110:79];
  assign immout_EX = ID_EX_out[78:47];
  assign rs1_EX = ID_EX_out[46:42];
  assign rs2_EX = ID_EX_out[41:37];
  assign rd_EX = ID_EX_out[36:32];
  assign PC_EX = ID_EX_out[31:0];
  // EX_MEM
  assign EX_MEM_in = {
    PC_EX, RegWrite_EX, MemWrite_EX, WDSel_EX, GPRSel_EX, DMType_EX, aluout_EX, RD2_forwarded, rd_EX
  };
  assign PC_MEM = EX_MEM_out[109:78];
  assign RegWrite_MEM = EX_MEM_out[77];
  assign MemWrite_MEM = EX_MEM_out[76];
  assign WDSel_MEM = EX_MEM_out[75:74];
  assign GPRSel_MEM = EX_MEM_out[73:72];
  assign DMType_MEM = EX_MEM_out[71:69];
  assign aluout_MEM = EX_MEM_out[68:37];
  assign RD2_MEM = EX_MEM_out[36:5];
  assign rd_MEM = EX_MEM_out[4:0];
  assign Addr_out = aluout_MEM;
  assign Data_out = RD2_MEM;
  assign mem_w = MemWrite_MEM;
  assign DMType = DMType_MEM;
  // MEM_WB
  assign MEM_WB_in = {PC_MEM, RegWrite_MEM, WDSel_MEM, Data_in, aluout_MEM, rd_MEM};
  assign PC_WB = MEM_WB_out[103:72];
  assign RegWrite_WB = MEM_WB_out[71];
  assign WDSel_WB = MEM_WB_out[70:69];
  assign Data_in_WB = MEM_WB_out[68:37];
  assign aluout_WB = MEM_WB_out[36:5];
  assign rd_WB = MEM_WB_out[4:0];
  assign ID_EX_MemRead = WDSel_EX[0];
  assign Branch_or_Jump = (NPCOp_EX != 3'b000);
  assign ID_EX_flush = stall_signal | Branch_or_Jump;
  assign IF_ID_write_enable = ~stall_signal;
  assign RD1_forwarded = (ForwardA == 2'b00) ? RD1_EX :
                         (ForwardA == 2'b01) ? RF_WD :
                         (ForwardA == 2'b10) ? aluout_MEM : 32'b0;
  assign RD2_forwarded = (ForwardB == 2'b00) ? RD2_EX :
                         (ForwardB == 2'b01) ? RF_WD :
                         (ForwardB == 2'b10) ? aluout_MEM : 32'b0;
  assign B_EX = ALUSrc_EX ? immout_EX : RD2_forwarded;



  GRE_array #(200) IF_ID (
      .Clk(clk),
      .Rst(rst),
      .write_enable(IF_ID_write_enable),
      .flush(IF_ID_flush),
      .in(IF_ID_in),
      .out(IF_ID_out)
  );

  GRE_array #(200) ID_EX (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(ID_EX_in),
      .out(ID_EX_out)
  );

  GRE_array #(200) EX_MEM (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(EX_MEM_in),
      .out(EX_MEM_out)
  );

  GRE_array #(200) MEM_WB (
      .Clk(clk),
      .Rst(rst),
      .write_enable(MEM_WB_write_enable),
      .flush(1'b0),
      .in(MEM_WB_in),
      .out(MEM_WB_out)
  );

  PC u_PC (
      .clk(clk),
      .rst(rst),
      .NPC(NPC),
      .PC (PC_out)
  );

  ctrl u_ctrl (
      .Op(Op),
      .Funct7(Funct7),
      .Funct3(Funct3),
      .Zero(Zero),
      .RegWrite(RegWrite),
      .MemWrite(MemWrite),
      .EXTOp(EXTOp),
      .ALUOp(ALUOp),
      .NPCOp(NPCOp),
      .ALUSrc(ALUSrc),
      .GPRSel(GPRSel),
      .WDSel(WDSel),
      .DMType(DMType_ID)
  );

  EXT u_EXT (
      .iimm_shamt(iimm_shamt),
      .iimm(iimm),
      .simm(simm),
      .bimm(bimm),
      .uimm(uimm),
      .jimm(jimm),
      .EXTOp(EXTOp),
      .immout(immout)
  );

  RF u_RF (
      .clk (clk),
      .rst (rst),
      .RFWr(RegWrite_WB),
      .A1  (rs1),
      .A2  (rs2),
      .A3  (rd_WB),
      .WD  (RF_WD),
      .RD1 (RD1),
      .RD2 (RD2)
  );

  alu u_alu (
      .A(RD1_forwarded),
      .B(B_EX),
      .ALUOp(ALUOp_EX),
      .C(aluout_EX),
      .Zero(Zero_EX),
      .PC(PC_EX)
  );



  HazardDetectionUnit u_hazard (
      .IF_ID_rs1(rs1),
      .IF_ID_rs2(rs2),
      .ID_EX_rd(rd_EX),
      .ID_EX_MemRead(ID_EX_MemRead),
      .ID_EX_NPCOp(NPCOp_EX),
      .stall(stall_signal),
      .IF_ID_flush(IF_ID_flush),
      .PCWrite(PCWrite)
  );

  ForwardingUnit u_forward (
      .MEM_RegWrite(RegWrite_MEM),
      .MEM_rd(rd_MEM),
      .WB_RegWrite(RegWrite_WB),
      .WB_rd(rd_WB),
      .EX_rs1(rs1_EX),
      .ForwardA(ForwardA),
      .EX_rs2(rs2_EX),
      .ForwardB(ForwardB)
  );


  NPC u_NPC (
      .PC(PC_out),
      .PC_EX(PC_EX),
      .NPCOp(NPCOp_EX),
      .IMM(immout_EX),
      .NPC(NPC),
      .PCWrite(PCWrite),
      .aluout(aluout_EX)
  );


  always @(*) begin
    case (WDSel_WB)
      `WDSel_FromALU: RF_WD = aluout_WB;
      `WDSel_FromMEM: RF_WD = Data_in_WB;
      `WDSel_FromPC: RF_WD = PC_WB + 4;
      default: RF_WD = 32'b0;
    endcase
  end

endmodule
