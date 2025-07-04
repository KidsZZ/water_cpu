module mem_ctrl_change (
    input [2:0] readMem,
    input [1:0] writeMem,
    output reg mem_w,
    output reg [2:0] dm_ctrl
);

  always @(*) begin
    if (writeMem > 0) begin
      mem_w = 1'b1;
      case (writeMem)
        2'b01: begin
          dm_ctrl = 3'b101;  // byte write
        end
        2'b10: begin
          dm_ctrl = 3'b100;  // half-word write
        end
        2'b11: begin
          dm_ctrl = 3'b010;  // word write
        end
        default: begin
          dm_ctrl = 3'b101;  // no write
        end
      endcase
    end else begin
      mem_w = 1'b0;
      case (readMem)
        3'b001: begin
          dm_ctrl = `dm_word  // 
        end
        3'b110: begin
          dm_ctrl = `dm_halfword; // half-word read
        end
        3'b111: begin
            dm_ctrl = `dm_byte; // byte read
        end
        3'b011: begin
            dm_ctrl = `dm_byte_unsigned;  // load byte unsigned
        end
        3'b010: begin
            dm_ctrl = `dm_halfword_unsigned;  // load half-word unsigned
        end
        default: begin
          dm_ctrl = `dm_none; // no read
        end
      endcase
    end


  end

endmodule
