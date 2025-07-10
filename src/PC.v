module PC( clk, rst, NPC, PC );

  input              clk;
  input              rst;
  input       [31:0] NPC;
  output reg  [31:0] PC;

  always @(posedge clk, posedge rst) // 时序逻辑, 控制每个时钟周期更新PC
    if (rst) 
      PC <= 32'h0000_0000; // 初始地址(按下rstn恢复)
    else
      PC <= NPC; // 每个时钟周期将NPC更新到PC
      
endmodule

