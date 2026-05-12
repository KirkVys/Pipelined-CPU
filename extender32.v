module extender32(

    input [15:0]imm,
    input ExtOp,
    output reg [31:0] ext
);

always@(*) begin

    if(ExtOp == 0)
        ext = {16'b0,imm};

    else if(ExtOp == 1)
        ext = imm[15] ? {{16{imm[15]}},imm}:{16'b0,imm};

    else 
        ext = {16'b0,imm};

end

endmodule

