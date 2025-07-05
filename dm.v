`include "ctrl_encode_def.v"
// data memory
module dm (
    clk,
    DMWr,
    addr,
    din,
    dout,
    dm_ctrl
);
  input clk;
  input DMWr;
  input [31:0] addr;  // 32位地址总线
  input [31:0] din;
  input [2:0] dm_ctrl;  // 数据存储器控制信号
  output [31:0] dout;

  reg [31:0] dmem[127:0];
  reg [31:0] Data_write_to_dm;
  reg [3:0] wea_mem;
  reg [31:0] Data_read;
  wire [6:0] mem_addr = addr[8:2];  // 提取存储器地址
  wire [31:0] Data_read_from_dm = dmem[mem_addr];

  // 写入控制逻辑
  always @(*) begin
    if (DMWr) begin  // 写内存操作
      case (dm_ctrl)
        `dm_word: begin
          Data_write_to_dm = din;
          wea_mem = 4'b1111;
        end
        `dm_halfword, `dm_halfword_unsigned: begin
          if (addr[1] == 0) begin  // 低半字
            Data_write_to_dm = dmem[mem_addr];
            Data_write_to_dm[15:0] = din[15:0];
            wea_mem = 4'b0011;
          end else begin  // 高半字
            Data_write_to_dm = dmem[mem_addr];
            Data_write_to_dm[31:16] = din[15:0];
            wea_mem = 4'b1100;
          end
        end
        `dm_byte, `dm_byte_unsigned: begin
          Data_write_to_dm = dmem[mem_addr];
          case (addr[1:0])
            2'b00: begin
              Data_write_to_dm[7:0] = din[7:0];
              wea_mem = 4'b0001;
            end
            2'b01: begin
              Data_write_to_dm[15:8] = din[7:0];
              wea_mem = 4'b0010;
            end
            2'b10: begin
              Data_write_to_dm[23:16] = din[7:0];
              wea_mem = 4'b0100;
            end
            2'b11: begin
              Data_write_to_dm[31:24] = din[7:0];
              wea_mem = 4'b1000;
            end
          endcase
        end
        default: begin
          Data_write_to_dm = 32'b0;
          wea_mem = 4'b0000;
        end
      endcase
    end else begin
      Data_write_to_dm = 32'b0;
      wea_mem = 4'b0000;
    end
  end

  // 读取控制逻辑
  always @(*) begin
    case (dm_ctrl)
      `dm_word: begin
        Data_read = Data_read_from_dm;
      end
      `dm_halfword: begin
        if (addr[1] == 0) begin
          Data_read = {{16{Data_read_from_dm[15]}}, Data_read_from_dm[15:0]};
        end else begin
          Data_read = {{16{Data_read_from_dm[31]}}, Data_read_from_dm[31:16]};
        end
      end
      `dm_halfword_unsigned: begin
        if (addr[1] == 0) begin
          Data_read = {16'b0, Data_read_from_dm[15:0]};
        end else begin
          Data_read = {16'b0, Data_read_from_dm[31:16]};
        end
      end
      `dm_byte: begin
        case (addr[1:0])
          2'b00: Data_read = {{24{Data_read_from_dm[7]}}, Data_read_from_dm[7:0]};
          2'b01: Data_read = {{24{Data_read_from_dm[15]}}, Data_read_from_dm[15:8]};
          2'b10: Data_read = {{24{Data_read_from_dm[23]}}, Data_read_from_dm[23:16]};
          2'b11: Data_read = {{24{Data_read_from_dm[31]}}, Data_read_from_dm[31:24]};
        endcase
      end
      `dm_byte_unsigned: begin
        case (addr[1:0])
          2'b00: Data_read = {24'b0, Data_read_from_dm[7:0]};
          2'b01: Data_read = {24'b0, Data_read_from_dm[15:8]};
          2'b10: Data_read = {24'b0, Data_read_from_dm[23:16]};
          2'b11: Data_read = {24'b0, Data_read_from_dm[31:24]};
        endcase
      end
      default: begin
        Data_read = 32'b0;
      end
    endcase
  end

  // 时钟同步写入
  always @(posedge clk) begin
    if (DMWr && (|wea_mem)) begin
      dmem[mem_addr] <= Data_write_to_dm;
      $display("dmem[0x%8X] = 0x%8X, dm_ctrl = %d", addr, Data_write_to_dm, dm_ctrl);
    end
  end

  assign dout = Data_read;

endmodule
