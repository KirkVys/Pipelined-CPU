module data_memory (

    input clk,
    input Mem_write,
    input Mem_read,
    input [31:0]addr,
    input [31:0]Write_data, 

    output reg[31:0]Read_data

);


reg [31:0] mem [0:255];

wire [7:0] index;
assign index = addr[9:2];

// Synchronous write — happens at clock edge, no race conditions
always@(posedge clk) begin

    if(Mem_write)
        mem[index] <= Write_data; 
    //no need for the else statement, because it won't create a latch. It's an array of memory cells, and not a single register.
end

// Combinational read — available immediately in the same cycle
always@(*) begin

    if(Mem_read)
        Read_data = mem[index];
    else
        Read_data = 32'b0;    

end

endmodule

 