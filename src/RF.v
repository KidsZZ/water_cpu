
module RF(  input         clk, 
            input         rst,
            input         RFWr, 
            input  [4:0]  A1, A2, A3, 
input  [31:0] WD, 
output [31:0] RD1, RD2);
    
reg [31:0] rf[31:0];

integer i;
// 一个时钟周期内先wb,在id, 所以下降沿
always @(negedge clk, posedge rst) 
    if (rst) begin
      for (i=0; i<32; i=i+1)
        rf[i] <= 0; // 全都初始化为0
    end
      
    else 
      if (RFWr&&(|A3!=0)) begin
        rf[A3] <= WD; // 阻塞赋值
      end
    
// 提取寄存器的值(保证x0的值为0)
  assign RD1 = (A1 != 0) ? rf[A1] : 0;
  assign RD2 = (A2 != 0) ? rf[A2] : 0;

endmodule 
