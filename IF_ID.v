module IF_ID(

    input clk,
    input reset,
    input stall,
    input stall_jump, // This name is misleading, this control signal should be named as flush_jump, because we flush the instruction and not stall it.
    input stall_branch, // This name is misleading, this control signal should be named as flush_branch, because we flush the instruction and not stall it.
    input [31:0]PC_4,
    input [31:0]Instruction,

    output reg [31:0] PC_4_out,
    output reg [31:0] Instruction_out
);


always@(posedge clk or posedge reset) begin

    if(reset) begin

        PC_4_out <= 32'b0;
        Instruction_out <= 32'b0;

    end

    else if(stall_jump || stall_branch) begin

        PC_4_out <= 32'b0;
        Instruction_out <= 32'b0;

    end

    else if(stall) begin

        PC_4_out <= PC_4_out;
        Instruction_out <= Instruction_out;        

    end

    else begin

        PC_4_out <= PC_4;
        Instruction_out <= Instruction;

    end

end

endmodule

