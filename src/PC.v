module pc (
    input rst,
    input clk,
    input pause,
    input flush,
    input [31:0] next_pc,

    output reg [31:0] pc
);

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      pc <= 32'h0;
    end else if (flush) begin
      pc <= next_pc;
    end else if (pause) begin
      // 空操作
      // 阻止寄存器值改变
    end else begin
      pc <= next_pc;
    end
  end

endmodule
