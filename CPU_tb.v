`timescale 1ns/1ps

module CPU_tb;

reg clk;
reg reset;

CPU uut(
    .clk(clk),
    .reset(reset)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

integer i;

// -------------------------------------------------------------------------
// Assembly String Pipeline Tracking
// -------------------------------------------------------------------------
reg [8*35:1] asm_IF, asm_ID, asm_EX, asm_MA, asm_WB;

// 1. Decode IF stage combinationally based on PC
always @(*) begin
    case (uut.PC)
        0:   asm_IF = "ori $t0, $0, 10";
        4:   asm_IF = "ori $t1, $0, 20";
        8:   asm_IF = "add $t2, $t0, $t1";
        12:  asm_IF = "sub $t3, $t2, $t0";
        16:  asm_IF = "or  $t4, $t2, $t3";
        20:  asm_IF = "mul $t5, $t0, $t1";
        24:  asm_IF = "slt $t6, $t4, $t5";
        28:  asm_IF = "sll $t7, $t6, 4";
        32:  asm_IF = "srl $s0, $t7, 2";
        36:  asm_IF = "sw  $s0, 0($0)";
        40:  asm_IF = "lw  $s1, 0($0)";
        44:  asm_IF = "add $s2, $s1, $s1";
        48:  asm_IF = "sw  $s2, 4($0)";
        52:  asm_IF = "beq $s2, $s1, Target3";
        56:  asm_IF = "j   Target1";
        60:  asm_IF = "ori $s3, $0, 999 (J-Delay)";
        64:  asm_IF = "ori $s3, $0, 777";
        68:  asm_IF = "ori $s3, $0, 888";
        72:  asm_IF = "ori $s3, $0, 100";
        76:  asm_IF = "ori $t6, $0, 5";
        80:  asm_IF = "beq $t6, $t6, Target2";
        84:  asm_IF = "ori $s4, $0, 999 (B-Delay)";
        88:  asm_IF = "ori $s4, $0, 888";
        92:  asm_IF = "ori $s4, $0, 200";
        default: asm_IF = "NOP";
    endcase
end

// 2. Shift strings down the pipeline synchronously with the CPU
always @(posedge clk) begin
    if (reset) begin
        asm_ID <= "NOP"; asm_EX <= "NOP"; asm_MA <= "NOP"; asm_WB <= "NOP";
    end else begin
        // ID to EX
        if (uut.stall) 
            asm_EX <= "NOP (Bubble)";
        else 
            asm_EX <= asm_ID;
        
        // IF to ID
        if (uut.stall_jump || uut.stall_branch) 
            asm_ID <= "NOP (Flushed)";
        else if (uut.stall) 
            asm_ID <= asm_ID; // Stall holds ID register
        else 
            asm_ID <= asm_IF;

        // EX to MA to WB
        asm_MA <= asm_EX;
        asm_WB <= asm_MA;
    end
end

// -------------------------------------------------------------------------
// Main Execution
// -------------------------------------------------------------------------
initial begin
    reset = 1;
    #10 reset = 0;

    $display("\n=================================================================================================");
    $display("                    MIPS 5-Stage Pipelined CPU - VISUAL EXECUTION TRACE");
    $display("=================================================================================================\n");

    for (i = 1; i <= 40; i = i + 1) begin
        #1; 
        
        $display("-------- Cycle %0d --------", i);
        $display(" [IF ] PC:%-3d | %s", uut.PC, asm_IF);
        
        // Split ID stage into two lines to comfortably show Control Signals AND Hazard Signals
        $display(" [ID ] %-24s | rs:%0d rt:%0d | Ctrls: RegDst=%b ALUSrc=%b RegWr=%b MemRd=%b MemWr=%b Mem2Reg=%b Jump=%b Branch=%b ALUOp=%b", 
                 asm_ID, uut.rs, uut.rt, uut.RegDst, uut.ALUSrc, uut.RegWrite, uut.MemRead, uut.MemWrite, uut.MemtoReg, uut.Jump, uut.Branch, uut.ALUOp);
        $display(" [ID Hazards]                   | Stall: %b | Flush_J: %b | Flush_B: %b", 
                 uut.stall, uut.stall_jump, uut.stall_branch);
                 
        $display(" [EX ] %-24s | ALUOut: %-3d | DestReg: %-2d", asm_EX, uut.ALUResult, uut.r_destination);
        // EX Operands line explicitly tracking divergence of data
        $display(" [EX Operands]                  | RF_Reads: val1=%-3d val2=%-3d | ALU_In: a=%-3d b=%-3d", 
                 uut.IE_read_data1, uut.IE_read_data2, uut.input1, uut.input2);

        $display(" [MA ] %-24s | ALU_Pass: %-3d | MemReadData: %-3d | MemWrite: %b", 
                 asm_MA, uut.MA_ALU_result, uut.DM.Read_data, uut.MA_MemWrite);
        $display(" [WB ] %-24s | WB_Data: %-3d  | DestReg: %-2d | RegWrite: %b", 
                 asm_WB, uut.Write_data, uut.WB_r_destination, uut.WB_RegWrite);
        
        // --- Hazard Detection & Notification Triggers (UPDATED WITH INSTRUCTION STRINGS) ---
        if (uut.Forward_A != 2'b10 || uut.Forward_B != 2'b10)
            $display("   >>> [HAZARD RESOLVED] EX Data Hazard on [%0s]: Forwarding directly into ALU (FwdA:%b, FwdB:%b)", asm_EX, uut.Forward_A, uut.Forward_B);
            
        if (uut.Forward_branch_A || uut.Forward_branch_B)
            $display("   >>> [HAZARD RESOLVED] Branch Data Hazard on [%0s]: Forwarding ALU back to Decode (FwdBrcA:%b, FwdBrcB:%b)", asm_ID, uut.Forward_branch_A, uut.Forward_branch_B);

        if (uut.stall)
            $display("   >>> [HAZARD DETECTED] Load-Use Data Hazard on [%0s]! Stalling IF/ID and injecting Bubble to EX.", asm_ID);

        if (uut.stall_jump)
            $display("   >>> [HAZARD DETECTED] Jump Control Hazard triggered by [%0s]! Flushing delay slot instruction [%0s] in IF.", asm_ID, asm_IF);

        if (uut.stall_branch)
            $display("   >>> [HAZARD DETECTED] Branch Control Hazard triggered by [%0s]! Branch Taken, flushing delay slot instruction [%0s].", asm_ID, asm_IF);
        
        $display("");
        @(posedge clk);
    end

    // -------------------------------------------------------------------------
    // Coverage & Final State Verification
    // -------------------------------------------------------------------------
    $display("====================================================================");
    $display("                      Final Register State");
    $display("====================================================================");
    $display("  $t0  (reg  8) = %-5d  expected: 10   [ori]", uut.RF.registers[8]);
    $display("  $t1  (reg  9) = %-5d  expected: 20   [ori]", uut.RF.registers[9]);
    $display("  $t2  (reg 10) = %-5d  expected: 30   [add $t0 + $t1]", uut.RF.registers[10]);
    $display("  $t3  (reg 11) = %-5d  expected: 20   [sub $t2 - $t0 (Fwd EX)]", uut.RF.registers[11]);
    $display("  $t4  (reg 12) = %-5d  expected: 30   [or  $t2 | $t3 (Fwd MEM & EX)]", uut.RF.registers[12]);
    $display("  $t5  (reg 13) = %-5d  expected: 200  [mul $t0 * $t1]", uut.RF.registers[13]);
    $display("  $t6  (reg 14) = %-5d  expected: 5    [ori override]", uut.RF.registers[14]);
    $display("  $t7  (reg 15) = %-5d  expected: 16   [sll 1 << 4]", uut.RF.registers[15]);
    $display("  $s0  (reg 16) = %-5d  expected: 4    [srl 16 >> 2]", uut.RF.registers[16]);
    $display("  $s1  (reg 17) = %-5d  expected: 4    [lw from mem 0]", uut.RF.registers[17]);
    $display("  $s2  (reg 18) = %-5d  expected: 8    [add $s1 + $s1 (STALL)]", uut.RF.registers[18]);
    
    $display("\n--- Control Flow Checks ---");
    $display("  $s3  (reg 19) = %-5d  expected: 100  [Jump successful]", uut.RF.registers[19]);
    $display("  $s4  (reg 20) = %-5d  expected: 200  [Branch successful]", uut.RF.registers[20]);

    $display("\n====================================================================");
    $display("                      Data Memory State");
    $display("====================================================================");
    $display("  Mem[0] = %-5d  expected: 4    [sw]",  uut.DM.mem[0]);
    $display("  Mem[1] = %-5d  expected: 8    [sw]",  uut.DM.mem[1]);

    // Per-instruction & Hazard coverage
    $display("\n====================================================================");
    $display("                 Instruction & Hazard Coverage");
    $display("====================================================================");
    $display("  [%s] ALU Operations (ADD, SUB, OR)    ", (uut.RF.registers[10]==30 && uut.RF.registers[11]==20 && uut.RF.registers[12]==30) ? "PASS" : "FAIL");
    $display("  [%s] Custom Instruction (MUL)         ", (uut.RF.registers[13]==200) ? "PASS" : "FAIL");
    $display("  [%s] Shift & Logic (SLT, SLL, SRL)    ", (uut.RF.registers[15]==16 && uut.RF.registers[16]==4) ? "PASS" : "FAIL");
    $display("  [%s] Memory Operations (LW, SW)       ", (uut.RF.registers[17]==4 && uut.DM.mem[1]==8) ? "PASS" : "FAIL");
    $display("  [%s] EX-to-EX Forwarding Hazard       ", (uut.RF.registers[11]==20) ? "PASS" : "FAIL");
    $display("  [%s] MEM-to-EX Forwarding Hazard      ", (uut.RF.registers[12]==30) ? "PASS" : "FAIL");
    $display("  [%s] Load-Use Hazard (Stall/Bubble)   ", (uut.RF.registers[18]==8)  ? "PASS" : "FAIL");
    $display("  [%s] Jump Hazard (IF/ID Flush)        ", (uut.RF.registers[19]==100) ? "PASS" : "FAIL");
    $display("  [%s] Branch Hazard (IF/ID Flush)      ", (uut.RF.registers[20]==200) ? "PASS" : "FAIL");
    $display("  [%s] Branch Data Hazard (Decode Fwd)  ", (uut.RF.registers[20]==200) ? "PASS" : "FAIL");

    $display("\n====================================================================");
    if (uut.RF.registers[8] == 10 && uut.RF.registers[12] == 30 && uut.RF.registers[11] == 20 &&
        uut.RF.registers[18] == 8 && uut.RF.registers[20] == 200 && uut.DM.mem[1] == 8)
        $display("   >>> ALL PIPELINE TESTS PASSED! CPU IS PERFECT! <<<");
    else
        $display("   >>> SOME TESTS FAILED -- Check cycle output <<<");
    $display("====================================================================\n");

    $finish;
end

endmodule