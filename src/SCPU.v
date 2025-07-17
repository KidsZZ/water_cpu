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
  wire [1:0] ForwardA;
  wire [1:0] ForwardB;
  wire [31:0] RD1_forwarded;
  wire [31:0] RD2_forwarded;
  wire [31:0] B_EX;
  wire PCWrite;
  reg [31:0] RF_WD;

  // exceptional
  wire [7:0] STATUS = 8'b00000010;
  wire [7:0] SCAUSE;
  wire [7:0] INTMASK = 8'b11111111;  // @TODO: 之后引入多级中断后在修改
  wire IF_ID_EXL_Set;
  wire IF_ID_INT_Signal;
  wire [2:0] IF_ID_INT_PEND;
  wire ID_EX_EXL_Set;
  wire ID_EX_INT_Signal;
  wire [2:0] ID_EX_INT_PEND;
  wire int_ret;


  // Wire assignments
  assign ID_EX_write_enable = 1'b1;
  assign EX_MEM_write_enable = 1'b1;
  assign MEM_WB_write_enable = 1'b1;

  // Instruction field assignments from IF_ID stage
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

  // Output assignments
  assign Addr_out = aluout_MEM;
  assign Data_out = RD2_MEM;
  assign mem_w = MemWrite_MEM;
  assign DMType = DMType_MEM;

  // Control signal assignments
  assign ID_EX_MemRead = WDSel_EX[0];
  assign ID_EX_flush = stall_signal | IF_ID_flush;
  assign IF_ID_write_enable = ~stall_signal;

  // Forwarding assignments
  assign RD1_forwarded = (ForwardA == 2'b00) ? RD1_EX :
                         (ForwardA == 2'b01) ? RF_WD :
                         (ForwardA == 2'b10) ? aluout_MEM : 32'b0;
  assign RD2_forwarded = (ForwardB == 2'b00) ? RD2_EX :
                         (ForwardB == 2'b01) ? RF_WD :
                         (ForwardB == 2'b10) ? aluout_MEM : 32'b0;
  assign B_EX = ALUSrc_EX ? immout_EX : RD2_forwarded;



  // IF_ID Pipeline Registers using GRE_array
  GRE_array #(32) IF_ID_PC_reg (
      .Clk(clk), // 时钟线
      .Rst(rst), // 复位线
      .write_enable(IF_ID_write_enable), // 写使能(当前恒为1)
      .flush(IF_ID_flush), // 清除信号
      .in(PC_out), // 输入if PC
      .out(IF_ID_PC) // 输出id PC
  );

  GRE_array #(32) IF_ID_inst_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(IF_ID_write_enable),
      .flush(IF_ID_flush),
      .in(inst_in),
      .out(IF_ID_inst)
  );

  // ID_EX Pipeline Registers using GRE_array
  GRE_array #(1) ID_EX_RegWrite_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(RegWrite),
      .out(RegWrite_EX)
  );

  GRE_array #(1) ID_EX_MemWrite_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(MemWrite),
      .out(MemWrite_EX)
  );

  GRE_array #(5) ID_EX_ALUOp_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(ALUOp),
      .out(ALUOp_EX)
  );

  GRE_array #(1) ID_EX_ALUSrc_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(ALUSrc),
      .out(ALUSrc_EX)
  );

  GRE_array #(2) ID_EX_GPRSel_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(GPRSel),
      .out(GPRSel_EX)
  );

  GRE_array #(2) ID_EX_WDSel_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(WDSel),
      .out(WDSel_EX)
  );

  GRE_array #(3) ID_EX_DMType_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(DMType_ID),
      .out(DMType_EX)
  );

  wire [2:0] NPCOp_EX_temp;
  GRE_array #(3) ID_EX_NPCOp_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(NPCOp),
      .out(NPCOp_EX_temp)
  );
  assign NPCOp_EX = {NPCOp_EX_temp[2:1], NPCOp_EX_temp[0] & Zero_EX};

  GRE_array #(32) ID_EX_RD1_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(RD1),
      .out(RD1_EX)
  );

  GRE_array #(32) ID_EX_RD2_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(RD2),
      .out(RD2_EX)
  );

  GRE_array #(32) ID_EX_immout_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(immout),
      .out(immout_EX)
  );

  GRE_array #(5) ID_EX_rs1_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(rs1),
      .out(rs1_EX)
  );

  GRE_array #(5) ID_EX_rs2_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(rs2),
      .out(rs2_EX)
  );

  GRE_array #(5) ID_EX_rd_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(rd),
      .out(rd_EX)
  );

  GRE_array #(32) ID_EX_PC_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(IF_ID_PC),
      .out(PC_EX)
  );

  GRE_array #(1) ID_EX_EXL_Set_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(IF_ID_EXL_Set),
      .out(ID_EX_EXL_Set)
  );

  GRE_array #(1) ID_EX_INT_Signal_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(IF_ID_INT_Signal),
      .out(ID_EX_INT_Signal)
  );

  GRE_array #(3) ID_EX_INT_PEND_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(ID_EX_write_enable),
      .flush(ID_EX_flush),
      .in(IF_ID_INT_PEND),
      .out(ID_EX_INT_PEND)
  );

  // EX_MEM Pipeline Registers using GRE_array
  GRE_array #(32) EX_MEM_PC_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(PC_EX),
      .out(PC_MEM)
  );

  GRE_array #(1) EX_MEM_RegWrite_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(RegWrite_EX),
      .out(RegWrite_MEM)
  );

  GRE_array #(1) EX_MEM_MemWrite_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(MemWrite_EX),
      .out(MemWrite_MEM)
  );

  GRE_array #(2) EX_MEM_WDSel_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(WDSel_EX),
      .out(WDSel_MEM)
  );

  GRE_array #(2) EX_MEM_GPRSel_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(GPRSel_EX),
      .out(GPRSel_MEM)
  );

  GRE_array #(3) EX_MEM_DMType_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(DMType_EX),
      .out(DMType_MEM)
  );

  GRE_array #(32) EX_MEM_aluout_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(aluout_EX),
      .out(aluout_MEM)
  );

  GRE_array #(32) EX_MEM_RD2_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(RD2_forwarded),
      .out(RD2_MEM)
  );

  GRE_array #(5) EX_MEM_rd_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(EX_MEM_write_enable),
      .flush(1'b0),
      .in(rd_EX),
      .out(rd_MEM)
  );

  // MEM_WB Pipeline Registers using GRE_array
  GRE_array #(32) MEM_WB_PC_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(MEM_WB_write_enable),
      .flush(1'b0),
      .in(PC_MEM),
      .out(PC_WB)
  );

  GRE_array #(1) MEM_WB_RegWrite_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(MEM_WB_write_enable),
      .flush(1'b0),
      .in(RegWrite_MEM),
      .out(RegWrite_WB)
  );

  GRE_array #(2) MEM_WB_WDSel_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(MEM_WB_write_enable),
      .flush(1'b0),
      .in(WDSel_MEM),
      .out(WDSel_WB)
  );

  GRE_array #(32) MEM_WB_Data_in_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(MEM_WB_write_enable),
      .flush(1'b0),
      .in(Data_in),
      .out(Data_in_WB)
  );

  GRE_array #(32) MEM_WB_aluout_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(MEM_WB_write_enable),
      .flush(1'b0),
      .in(aluout_MEM),
      .out(aluout_WB)
  );

  GRE_array #(5) MEM_WB_rd_reg (
      .Clk(clk),
      .Rst(rst),
      .write_enable(MEM_WB_write_enable),
      .flush(1'b0),
      .in(rd_MEM),
      .out(rd_WB)
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
      .DMType(DMType_ID),
      .SCAUSE(SCAUSE),
      .int_ret(int_ret)
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
      .ID_EX_INT_Signal(ID_EX_INT_Signal),
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
      .INT_Signal(ID_EX_INT_Signal),
      .EXL_Set(ID_EX_EXL_Set),
      .INT_PEND(ID_EX_INT_PEND),
      .PCWrite(PCWrite),
      .aluout(aluout_EX),
      .clk(clk)
  );

  ExceptionCtrl u_Excep (
    .rst(rst),
    .clk(clk),
      .STATUS(STATUS),
      .SCAUSE(SCAUSE),
      .INTMASK(INTMASK),
      .EXL_Set(IF_ID_EXL_Set),
      .INT_Signal(IF_ID_INT_Signal),
      .INT_PEND(IF_ID_INT_PEND),
      .Int(INT),
      .int_ret(int_ret)
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
