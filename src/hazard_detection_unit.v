module hazard_detection_unit(
    input [2: 0] ex_readMem,
    input [4: 0] ex_rd, id_rs1, id_rs2,

    output reg pause
);

// 检测是否需要暂停流水线
// 如果 ex 阶段正在读内存，并且 ex_rd 不为 x0，且 ex_rd 等于 id 阶段的 rs1 或 rs2，则暂停
always @(*) begin
    pause = 1'b0;
    if((ex_readMem != 3'b000) && (ex_rd != 5'b00000) && ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
        pause = 1'b1;
    end
end

endmodule