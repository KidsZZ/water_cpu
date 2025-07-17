module HazardDetectionUnit(
    input [4:0] IF_ID_rs1,  
    input [4:0] IF_ID_rs2,  
    input [4:0] ID_EX_rd,   
    input ID_EX_MemRead,    
    input [2:0] ID_EX_NPCOp,
    input ID_EX_INT_Signal,
    output reg stall,       
    output reg IF_ID_flush, 
    output reg PCWrite      
);

    always @(*) begin
        if (ID_EX_MemRead && // load-use 冒险检测
            ((ID_EX_rd != 5'b0) &&
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)))) begin
            stall = 1'b1;  // 暂停信号线
            IF_ID_flush = 1'b0; // flush信号线
            PCWrite = 1'b0; 
        end 
        else if (ID_EX_NPCOp != 3'b000) begin // 分支指令冒险检测
            // 只要发生跳转, NPCOp不为000, 就需要清除IF_ID寄存器
            stall = 1'b0;
            IF_ID_flush = 1'b1;
            PCWrite = 1'b1; 
        end
        else if (ID_EX_INT_Signal == 1'b1) begin
            // 如果有中断信号, 需要清除IF_ID寄存器
            stall = 1'b0;
            IF_ID_flush = 1'b1;
            PCWrite = 1'b1; 
        end 
        else begin
            stall = 1'b0;
            IF_ID_flush = 1'b0;
            PCWrite = 1'b1;
        end
    end

endmodule