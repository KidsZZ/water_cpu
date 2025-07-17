`timescale 1ns / 1ps


module GRE_array #(parameter WIDTH = 200) (
    input Clk, 
    input Rst, 
    input write_enable, 
    input flush,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);

    always @(posedge Clk or posedge Rst) begin // 时序逻辑, 每个时钟周期更新输出
        if (Rst) begin
            out <= {WIDTH{1'b0}}; // 复位逻辑
        end else if (write_enable) begin
            if (flush) begin
                out <= {WIDTH{1'b0}}; // 如果flush为高，则清空输出
            end else begin
                out <= in; // 否则将输入写入输出
            end
        end
    end

endmodule