module register_file(

    input clk,
    input RegWrite, //1 = write, 0 = no write
    input [4:0]rs,
    input [4:0]rt,
    input [4:0]r_destination,
    input [31:0]Write_data,
    
    output  [31:0]read_data1,
    output  [31:0]read_data2
);
 

reg [31:0] registers[31:0];

//Initializing all registers to 0, making it easier for debugging
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1)
        registers[i] = 32'd0;
end

//Simulating the write on the first half of the clock cycle, and read on the second half
assign read_data1 = (rs == 0) ? 32'd0 : ((RegWrite && r_destination == rs) ? Write_data : registers[rs]);                   
assign read_data2 = (rt == 0) ? 32'd0 : ((RegWrite && r_destination == rt) ? Write_data : registers[rt]);

//assign write_data = MemtoReg ? MemoryResult : ALUResult; //Done in Write-Back stage
//assign RegDestination = RegDst ? rd : rt;  //Done in execution stage

always @(posedge clk) begin

if(RegWrite && r_destination!=0)
    registers[r_destination] <= Write_data;

end

endmodule
