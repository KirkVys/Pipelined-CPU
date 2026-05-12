module counter_32(

    input clk,
    input reset,
    input Jump, Branch, stall,
    input [25:0]jump_addr,
    input [31:0]Instruction_branch,
    output reg [31:0]counter

);

wire [31:0]PC;
assign PC = counter + 4;

always@(posedge clk or posedge reset) begin

    if(reset)
     counter <= 32'd0;
    else if(stall)
     counter <= counter;
    else if(Jump)
     counter <= {PC[31:28], jump_addr, 2'b0};
    else if(Branch)
     counter <= Instruction_branch;
    else
     counter <= counter + 4;

end

endmodule