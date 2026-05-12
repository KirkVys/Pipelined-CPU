module ALU(

    input [31:0]a,
    input [31:0]b,
    input [4:0]shamt,
    input [3:0]ALUOp,

    output reg [31:0]result,
    output zero_flag
);

wire sub_mode;
assign sub_mode = (ALUOp == 4'b0011) || (ALUOp == 4'b0111);

wire [31:0] adder_result;
wire adder_cout;

Adder_Substractor AS(
    .a(a),
    .b(b),
    .cin(sub_mode),
    .result(adder_result),
    .cout(adder_cout)
);

always@(*) begin

    case(ALUOp)
        4'b0000: result = a & b; //AND
        4'b0001: result = a | b; //OR
        4'b0010: result = adder_result; //ADD
        4'b0011: result = adder_result; //SUB
        4'b0100: result = a ^ b; //XOR
        4'b0101: result = b << shamt; //Shift logical left
        4'b0110: result = b >> shamt; //Shift logical right
        4'b0111: result = {31'b0, adder_result[31]}; //SLT;
        4'b1000: result = a * b; //MUL
        default: result = 32'd0;
    endcase
end

assign zero_flag = (result == 32'b0);
endmodule




 
