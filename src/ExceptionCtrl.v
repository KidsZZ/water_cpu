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
  assign INT_Signal = ((|SCAUSE_PEND) & STATUS[1] & ~STATUS[0]) | Int;
  assign EXL_Set = INT_Signal;

  always @(*) begin
    if (Int == 1'b1) begin
      INT_PEND <= `int_timer;
    end else begin
      case (SCAUSE_PEND)
        `scause_illegal_instr: INT_PEND <= `int_illegal_instr;
        `scause_ecall: INT_PEND <= `int_ecall;
        `scause_reserve1: INT_PEND <= `int_reserve1;
        `scause_reserve2: INT_PEND <= `int_reserve2;
        `scause_reserve3: INT_PEND <= `int_reserve3;
        `scause_reserve4: INT_PEND <= `int_reserve4;
        `scause_reserve5: INT_PEND <= `int_reserve5;
        default: INT_PEND <= `int_reserve5;
      endcase
    end
  end

endmodule
