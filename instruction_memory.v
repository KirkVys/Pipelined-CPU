module instruction_memory (
    //input         clk,        // Clock
    input  [31:0] addr,       // PC address
    output [31:0] instr   // Instruction output
);
    // 256 x 32-bit memory
    reg [31:0] mem [0:255];

    // Word index (word-aligned)
    wire [7:0] index;
    assign index = addr[9:2];

    //Asynchronous read, to not skip one cycle
    assign instr = mem[index];

    // Load program from file
    integer i;
    initial begin
        //Clean the memory to all zeros
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'd0;
            
        //Read the file (Verilog will stop when the file ends)
        $readmemh("program_final.hex", mem, 0, 255);
    end
endmodule

 