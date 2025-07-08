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
        if (ID_EX_MemRead && 
            ((ID_EX_rd != 5'b0) && 
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)))) begin
            stall = 1'b1;  
            IF_ID_flush = 1'b0;
            PCWrite = 1'b0; 
        end 
        else if (ID_EX_NPCOp != 3'b000) begin
            stall = 1'b0;
            IF_ID_flush = 1'b1;
            PCWrite = 1'b1; 
        end
        else if (ID_EX_INT_Signal == 1'b1) begin
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