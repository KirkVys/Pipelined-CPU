module MA_WB(

    input clk,
    input reset,

    //Control signals
    input RegWrite, MemtoReg,

    //Data retrieved from memory
    input [31:0]Read_data,

    //ALUResult to register
    input [31:0]ALU_result,

    //Destination register
    input [4:0]r_destination,

    //Outputs
    output reg RegWrite_out, MemtoReg_out,
    output reg [31:0]Read_data_out, ALU_result_out,
    output reg [4:0]r_destination_out

);

always@(posedge clk or posedge reset) begin

    if(reset) begin

        RegWrite_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        Read_data_out <= 32'b0;
        ALU_result_out <= 32'b0;
        r_destination_out <= 5'b0;

    end

    else begin

        RegWrite_out <= RegWrite;
        MemtoReg_out <= MemtoReg;
        Read_data_out <= Read_data;
        ALU_result_out <= ALU_result;
        r_destination_out <= r_destination;

    end
end
endmodule

