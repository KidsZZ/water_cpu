`include "ctrl_encode_def.v"
//// NPC control signal
//`define NPC_PLUS4   3'b000
//`define NPC_BRANCH  3'b001
//`define NPC_JUMP    3'b010
//`define NPC_JALR 3'b100

module NPC (
    PC,
    PC_EX,
    NPCOp,
    IMM,
    NPC,
    aluout,
    PCWrite,
    INT_Signal,
    EXL_Set,
    INT_PEND,
    clk
);  // next pc module

  input [31:0] PC;  // pc
  input [31:0] PC_EX;  // pc_EX
  input [2:0] NPCOp;  // next pc operation
  input [31:0] IMM;  // immediate
  input [31:0] aluout;
  input PCWrite;
  input INT_Signal;  // interrupt signal
  input EXL_Set;  // exception level set
  input [2:0] INT_PEND;  // interrupt pending number (0-31)
  input clk;
  output reg [31:0] NPC;  // next pc

  wire [31:0] PCPLUS4;
  assign PCPLUS4 = PC + 4;  // pc + 4

  reg [31:0] INT_ADDR;

  always @(*) begin
    case (INT_PEND)// 
      `int_buttom: INT_ADDR = 32'h000000e8;// buttom Interrupt
      `int_illegal_instr: INT_ADDR = 32'h0000009c;  // 非法指令
      `int_ecall: INT_ADDR = 32'h00000050;  // 系统调用
      default: INT_ADDR = 32'h8000000;  // Default vector address
    endcase
  end

  reg [31:0] SEPC;

  always @(posedge clk) begin
    if (PCWrite && INT_Signal) begin
      SEPC = PC_EX; // 保存发生中断时的PC_EX地址
    end
  end


  always @(*) begin
    if (PCWrite) begin
      if (INT_Signal) begin
        // 发生中断时使用中断地址
        NPC = INT_ADDR;
      end else begin
        case (NPCOp)
          `NPC_PLUS4:  NPC = PCPLUS4; // pc + 4
          `NPC_BRANCH: NPC = PC_EX + IMM; // 相对跳转
          `NPC_JUMP:   NPC = PC_EX + IMM; // jal 相对跳转
          `NPC_JALR:   NPC = aluout; // jalr 绝对跳转
          `NPC_INT_RET: begin
            NPC = SEPC + 4; // 中断返回地址
          end
          default:     NPC = PCPLUS4;
        endcase
      end
    end else NPC = PC;
  end  // end always

endmodule
