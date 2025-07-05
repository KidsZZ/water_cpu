module reg_file (
    input rst,
    clk,
    write_reg,
    input [4:0] rs1,
    rs2,
    target_reg,
    input [31:0] write_rd_data,

    output reg [31:0] read_rs1_data,
    output reg [31:0] read_rs2_data
);

  reg [31:0] regs[31:0];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
    regs[0] = 32'd0;
    regs[1] = 32'd0;
    regs[2] = 32'd0;
    regs[3] = 32'd0;
    regs[4] = 32'd0;
    regs[5] = 32'd0;
    regs[6] = 32'd0;
    regs[7] = 32'd0;
    regs[8] = 32'd0;
    regs[9] = 32'd0;
    regs[10] = 32'd0;
    regs[11] = 32'd0;
    regs[12] = 32'd0;
    regs[13] = 32'd0;
    regs[14] = 32'd0;
    regs[15] = 32'd0;
    regs[16] = 32'd0;
    regs[17] = 32'd0;
    regs[18] = 32'd0;
    regs[19] = 32'd0;
    regs[20] = 32'd0;
    regs[21] = 32'd0;
    regs[22] = 32'd0;
    regs[23] = 32'd0;
    regs[24] = 32'd0;
    regs[25] = 32'd0;
    regs[26] = 32'd0;
    regs[27] = 32'd0;
    regs[28] = 32'd0;
    regs[29] = 32'd0;
    regs[30] = 32'd0;
    regs[31] = 32'd0;
    end else begin
      if (write_reg && target_reg != 5'h0) regs[target_reg] = write_rd_data;
    end
  end

  always @(*) begin
    if (rs1 == 5'h0) begin
      read_rs1_data = 32'h0000_0000;
    end else begin
      if (rs1 == target_reg) begin
        read_rs1_data = write_rd_data;
      end else begin
        read_rs1_data = regs[rs1];
      end
    end
  end

  always @(*) begin
    if (rs2 == 5'h0) begin
      read_rs2_data = 32'h0000_0000;
    end else begin
      if (rs2 == target_reg) begin
        read_rs2_data = write_rd_data;
      end else begin
        read_rs2_data = regs[rs2];
      end
    end
  end

endmodule
