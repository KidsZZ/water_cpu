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
  reg [31:0] times;
  reg [1:0] write_state;  // 写入状态机
  reg int_prev;           // 保存上一个INT状态用于边沿检测
  
  // 状态定义
  parameter IDLE = 2'b00;
  parameter WRITE_COUNTER = 2'b01;
  parameter WRITE_DISPLAY = 2'b10;
  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      times <= 0;
      write_state <= IDLE;
      int_prev <= 0;
    end else begin
      int_prev <= INT;
      
      case (write_state)
        IDLE: begin
          // 检测INT上升沿
          if (INT && !int_prev) begin
            times <= times + 1;
            write_state <= WRITE_COUNTER;
          end
        end
        
        WRITE_COUNTER: begin
          // 写入计数器重设值后，转到写显示状态
          write_state <= WRITE_DISPLAY;
        end
        
        WRITE_DISPLAY: begin
          // 写入显示后，回到空闲状态
          write_state <= IDLE;
        end
        
        default: write_state <= IDLE;
      endcase
    end
  end
  
  // 输出控制
  assign mem_w = (write_state == WRITE_COUNTER) || (write_state == WRITE_DISPLAY);
  
  assign Addr_out = (write_state == WRITE_COUNTER) ? 32'hf0000004 : 32'he0000000;
  
  assign Data_out = (write_state == WRITE_COUNTER) ? 32'hf8000000 : times;
  
  assign DMType = `dm_word; // default DMType

endmodule
