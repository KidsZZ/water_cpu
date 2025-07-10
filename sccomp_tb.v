
// testbench for simulation
module sccomp_tb ();

  reg clk, rstn, Int;
  reg  [ 4:0] reg_sel;
  wire [31:0] reg_data;

`ifndef STOP_INSTR
  localparam stop_instr = 200;
`else
  localparam stop_instr = `STOP_INSTR;
`endif
  localparam stop_pc = 4 * stop_instr;  // stop after 4 instructions

  // instantiation of sccomp    
  sccomp U_SCCOMP (
      .clk (clk),
      .rstn(rstn),
      .Int(Int)
  );

  integer foutput;
  integer counter = 0;
  integer i;

  initial begin
    // 添加VCD波形记录
    $dumpfile("dump.vcd");
    $dumpvars(0, sccomp_tb);

    $readmemh("asm&bin/ecall.coe",
              U_SCCOMP.U_IM.ROM);  // load instructions into instruction memory
    //    $monitor("PC = 0x%8X, instr = 0x%8X", U_SCCOMP.PC, U_SCCOMP.instr); // used for debug
    foutput = $fopen("results.txt");
    clk = 1;
    rstn = 1;
    #5;
    rstn = 0;
    #20;
    rstn = 1;
    #100;
    Int = 1;
    #100;
    Int = 0;
  end

  always begin
    #(50) clk = ~clk;

    if (clk == 1'b1) begin

      if (counter == stop_instr) begin
        counter = counter + 1;
        // $fdisplay(foutput, "----------------------------------------");
        // $fdisplay(foutput, "PC        : %08h", U_SCCOMP.PC);
        // $fdisplay(foutput, "STOP_NuUM : %08h", (U_SCCOMP.PC) / 4);
        // $fdisplay(foutput, "INSTR     : %08h", U_SCCOMP.instr);
        // $fdisplay(foutput, "REG FILE:");
        // $fdisplay(foutput, " r00: %08h  r01: %08h  r02: %08h  r03: %08h", 0,
        //           U_SCCOMP.U_SCPU.U_RF.rf[1], U_SCCOMP.U_SCPU.U_RF.rf[2],
        //           U_SCCOMP.U_SCPU.U_RF.rf[3]);
        // $fdisplay(foutput, " r04: %08h  r05: %08h  r06: %08h  r07: %08h",
        //           U_SCCOMP.U_SCPU.U_RF.rf[4], U_SCCOMP.U_SCPU.U_RF.rf[5],
        //           U_SCCOMP.U_SCPU.U_RF.rf[6], U_SCCOMP.U_SCPU.U_RF.rf[7]);
        // $fdisplay(foutput, " r08: %08h  r09: %08h  r10: %08h  r11: %08h",
        //           U_SCCOMP.U_SCPU.U_RF.rf[8], U_SCCOMP.U_SCPU.U_RF.rf[9],
        //           U_SCCOMP.U_SCPU.U_RF.rf[10], U_SCCOMP.U_SCPU.U_RF.rf[11]);
        // $fdisplay(foutput, " r12: %08h  r13: %08h  r14: %08h  r15: %08h",
        //           U_SCCOMP.U_SCPU.U_RF.rf[12], U_SCCOMP.U_SCPU.U_RF.rf[13],
        //           U_SCCOMP.U_SCPU.U_RF.rf[14], U_SCCOMP.U_SCPU.U_RF.rf[15]);
        // $fdisplay(foutput, " r16: %08h  r17: %08h  r18: %08h  r19: %08h",
        //           U_SCCOMP.U_SCPU.U_RF.rf[16], U_SCCOMP.U_SCPU.U_RF.rf[17],
        //           U_SCCOMP.U_SCPU.U_RF.rf[18], U_SCCOMP.U_SCPU.U_RF.rf[19]);
        // $fdisplay(foutput, " r20: %08h  r21: %08h  r22: %08h  r23: %08h",
        //           U_SCCOMP.U_SCPU.U_RF.rf[20], U_SCCOMP.U_SCPU.U_RF.rf[21],
        //           U_SCCOMP.U_SCPU.U_RF.rf[22], U_SCCOMP.U_SCPU.U_RF.rf[23]);
        // $fdisplay(foutput, " r24: %08h  r25: %08h  r26: %08h  r27: %08h",
        //           U_SCCOMP.U_SCPU.U_RF.rf[24], U_SCCOMP.U_SCPU.U_RF.rf[25],
        //           U_SCCOMP.U_SCPU.U_RF.rf[26], U_SCCOMP.U_SCPU.U_RF.rf[27]);
        // $fdisplay(foutput, " r28: %08h  r29: %08h  r30: %08h  r31: %08h",
        //           U_SCCOMP.U_SCPU.U_RF.rf[28], U_SCCOMP.U_SCPU.U_RF.rf[29],
        //           U_SCCOMP.U_SCPU.U_RF.rf[30], U_SCCOMP.U_SCPU.U_RF.rf[31]);
        // $fdisplay(foutput, "----------------------------------------\n");
        // $fdisplay(foutput, "DATA MEMORY (dmem):");
        // for (i = 0; i < 128; i = i + 4) begin
        //   $fdisplay(foutput, " [%02h]: %08h  [%02h]: %08h  [%02h]: %08h  [%02h]: %08h", i * 4,
        //             U_SCCOMP.U_DM.dmem[i], (i + 1) * 4, U_SCCOMP.U_DM.dmem[i+1], (i + 2) * 4,
        //             U_SCCOMP.U_DM.dmem[i+2], (i + 3) * 4, U_SCCOMP.U_DM.dmem[i+3]);
        // end
        // $fdisplay(foutput, "----------------------------------------\n");
        //$fdisplay(foutput, "hi lo:\t %h %h", U_SCCOMP.U_SCPU.U_RF.rf.hi, U_SCCOMP.U_SCPU.U_RF.rf.lo);
        $fclose(foutput);
        $finish;
      end else begin
        counter = counter + 1;
        //          $display("pc: %h", U_SCCOMP.U_SCPU.PC);
        //          $display("instr: %h", U_SCCOMP.U_SCPU.instr);
      end
    end
  end  //end always

endmodule
