module hazard_detection_unit(
    input ex_aluOut_WB_memOut,
    input [4: 0] ex_rd, id_rs1, id_rs2,

    output reg pause
);

always @(*) begin
    pause = 1'b0;
    if((ex_aluOut_WB_memOut == 1'b1) && ((ex_rd == id_rs1) || (ex_rd == id_rs2))) begin
        pause = 1'b1;
    end
end

endmodule