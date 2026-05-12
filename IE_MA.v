module IE_MA(

    input clk,
    input reset,

    //From control signals
    input RegWrite, MemWrite, MemRead, MemtoReg,


    //ALU result
    input [31:0]ALU_result,
    input zero_flag,

    //Data to be written to the memory
    input [31:0] Write_data,

    //Destination register
    input [4:0]r_destination,

    //Outputs

    output reg RegWrite_out, MemWrite_out, MemRead_out, MemtoReg_out, zero_flag_out,
    output reg [31:0]ALU_result_out, Write_data_out,
    output reg [4:0]r_destination_out 
);

always@(posedge clk or posedge reset) begin

    if(reset) begin

        RegWrite_out <= 1'b0;
        MemWrite_out <= 1'b0;
        MemRead_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        zero_flag_out <= 1'b0;
        ALU_result_out <= 32'b0;
        Write_data_out <= 32'b0;
        r_destination_out <= 5'b0;

    end

    else begin

        RegWrite_out <= RegWrite;
        MemWrite_out <= MemWrite;
        MemRead_out <= MemRead;
        MemtoReg_out <= MemtoReg;
        zero_flag_out <= zero_flag;
        ALU_result_out <= ALU_result;
        Write_data_out <= Write_data;
        r_destination_out <= r_destination;


    end

end
endmodule

