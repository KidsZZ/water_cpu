`include "ctrl_encode_def.v"

// @todo : 根据status判断是否执行中断, 在执行中断后修改status
module ExceptionCtrl (
    input rst,
    input clk,
    input [7:0] STATUS,
    input [7:0] SCAUSE,
    input [7:0] INTMASK,
    input Int,
    input int_ret,
    output EXL_Set,
    output INT_Signal,
    output reg [2:0] INT_PEND
);

  wire [7:0] SCAUSE_PEND;
  assign SCAUSE_PEND = INTMASK & SCAUSE;

  // 中断活动标志
  reg interrupt_active;

  // 只有在未处理中断时，才允许新的中断信号
  wire INT_Signal_raw = ((|SCAUSE_PEND) & STATUS[1] & ~STATUS[0]) | Int;
  assign INT_Signal = INT_Signal_raw & ~interrupt_active;

  // EXL_Set 只在进入新中断时拉高
  assign EXL_Set = INT_Signal;

  // interrupt_active 状态机
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      interrupt_active <= 1'b0;
    end else if (int_ret) begin
      interrupt_active <= 1'b0; // 处理中断结束
    end else if (INT_Signal) begin
      interrupt_active <= 1'b1; // 进入中断
    end
    // 否则保持原值
  end

  // INT_PEND 组合逻辑
  always @(*) begin
    if (Int == 1'b1) begin // 外部中断
      INT_PEND = `int_buttom;
    end else begin
      case (SCAUSE_PEND) // 异常
        `scause_illegal_instr: INT_PEND = `int_illegal_instr;
        `scause_ecall:         INT_PEND = `int_ecall;
        `scause_reserve1:      INT_PEND = `int_reserve1;
        `scause_reserve2:      INT_PEND = `int_reserve2;
        `scause_reserve3:      INT_PEND = `int_reserve3;
        `scause_reserve4:      INT_PEND = `int_reserve4;
        `scause_reserve5:      INT_PEND = `int_reserve5;
        default:               INT_PEND = `int_reserve5;
      endcase
    end
  end

endmodule
