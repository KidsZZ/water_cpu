module PC (
    clk,
    rst,
    pause,
    flush,
    NPC,
    PC
);

  input clk;
  input rst;
  input pause;
  input flush;
  input [31:0] NPC;
  output reg [31:0] PC;

  always @(posedge clk, posedge rst)
    if (rst) begin
      pc <= 32'h00;
    end else if (flush) begin
      pc <= NPC;
    end else if (pause) begin
      // 空操作
      // 阻止寄存器值改变
    end else begin
      pc <= NPC;
    end

endmodule

