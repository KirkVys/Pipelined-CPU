module ID_IE(

    input clk,
    input reset,
    input stall,

    //From control unit
    input RegDst, RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg,
    input [3:0] ALUOp,

    //From register file
    input [31:0]read_data1, read_data2,

    //From extender
    input [31:0]imm_extended,

    //Destination registers and shift amount
    input [4:0]rs, rt, rd, shamt,

 

    //Outputs
    output reg RegDst_out, RegWrite_out, ALUSrc_out, MemWrite_out, MemRead_out, MemtoReg_out,
    output reg [3:0]ALUOp_out,
    output reg [31:0]read_data1_out, read_data2_out, imm_extended_out,
    output reg [4:0]rs_out, rt_out, rd_out, shamt_out 

);


always@(posedge clk or posedge reset) begin

    if(reset) begin

        RegDst_out <= 1'b0;
        RegWrite_out <= 1'b0;
        ALUSrc_out <= 1'b0;
        MemWrite_out <= 1'b0;
        MemRead_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        ALUOp_out <= 4'b0;
        read_data1_out <= 32'b0;
        read_data2_out <= 32'b0;
        imm_extended_out <= 32'b0;
        rs_out <= 5'b0;
        rt_out <= 5'b0;
        rd_out <= 5'b0;
        shamt_out <= 5'b0;
    
    end

    else if(stall) begin

        RegDst_out <= 1'b0;
        RegWrite_out <= 1'b0;
        ALUSrc_out <= 1'b0;
        MemWrite_out <= 1'b0;
        MemRead_out <= 1'b0;
        MemtoReg_out <= 1'b0;
        ALUOp_out <= 4'b0;
        read_data1_out <= 32'b0;
        read_data2_out <= 32'b0;
        imm_extended_out <= 32'b0;
        rs_out <= 5'b0;
        rt_out <= 5'b0;
        rd_out <= 5'b0;
        shamt_out <= 5'b0;

    end

    else begin

        RegDst_out <= RegDst;
        RegWrite_out <= RegWrite;
        ALUSrc_out <= ALUSrc;
        MemWrite_out <= MemWrite;
        MemRead_out <= MemRead;
        MemtoReg_out <= MemtoReg;
        ALUOp_out <= ALUOp;
        read_data1_out <= read_data1;
        read_data2_out <= read_data2;
        imm_extended_out <= imm_extended;
        rs_out <= rs;
        rt_out <= rt;
        rd_out <= rd;
        shamt_out <= shamt;

    end

end
endmodule

