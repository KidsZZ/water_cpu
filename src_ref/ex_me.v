module ex_me(
    input clk, rst, flush,

    input ex_aluOut_WB_memOut,
    input ex_writeReg,
    input [2: 0] ex_DMType,
    input ex_mem_w,
    input [1: 0] ex_pcImm_NEXTPC_rs1Imm,
    input ex_conditionBranch,
    input [31: 0] ex_pcImm,
    input [31: 0] ex_rs1Imm,
    input [31: 0] ex_outAlu,
    input [31: 0] ex_rs2Data,
    input [4: 0] ex_rd,
    input [4: 0] ex_rs2,

    output reg me_aluOut_WB_memOut,
    output reg me_writeReg,
    output reg [2: 0] me_DMType,
    output reg me_mem_w,
    output reg [1: 0] me_pcImm_NEXTPC_rs1Imm,
    output reg me_conditionBranch,
    output reg [31: 0] me_pcImm,
    output reg [31: 0] me_rs1Imm,
    output reg [31: 0] me_outAlu,
    output reg [31: 0] me_rs2Data,
    output reg [4: 0] me_rd,
    output reg [4: 0] me_rs2
);

always @(posedge clk or posedge rst) begin
    if(rst || flush) begin
        me_aluOut_WB_memOut = 1'b0;
        me_writeReg = 1'b0;
        me_DMType = 3'b000;
        me_mem_w = 1'b0;
        me_pcImm_NEXTPC_rs1Imm = 2'b00;
        me_conditionBranch = 1'b0;
        me_pcImm = 32'd0;
        me_rs1Imm = 32'd0;
        me_outAlu = 32'd0;
        me_rs2Data = 32'd0;
        me_rd = 5'd0;
        me_rs2 = 5'd0;
    end else begin
        me_aluOut_WB_memOut <= ex_aluOut_WB_memOut;
        me_writeReg <= ex_writeReg;
        me_DMType <= ex_DMType;
        me_mem_w <= ex_mem_w;
        me_pcImm_NEXTPC_rs1Imm <= ex_pcImm_NEXTPC_rs1Imm;
        me_conditionBranch <= ex_conditionBranch;
        me_pcImm <= ex_pcImm;
        me_rs1Imm <= ex_rs1Imm;
        me_outAlu <= ex_outAlu;
        me_rs2Data <= ex_rs2Data;
        me_rd <= ex_rd;
        me_rs2 <= ex_rs2;
    end
    
end

endmodule