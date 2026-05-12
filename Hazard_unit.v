module Hazard_unit(

  input IE_MemRead, Jump, Branch,
  input [4:0] IE_rt, ID_rs, ID_rt,
  input [31:0] ID_read_data1, ID_read_data2,
  output reg stall,
  output stall_jump,
  output reg stall_branch

);

//Logic for handling the jump hazard
assign stall_jump = Jump;

//Logic for handling the load data hazard
always@(*) begin

    if(IE_MemRead && ((IE_rt == ID_rs) || (IE_rt == ID_rt)) && IE_rt != 0)
        stall = 1'b1;
    else 
        stall = 1'b0;

end

//Logic for handling the branch hazard
always@(*) begin

    if(Branch) begin
        if(ID_read_data1 == ID_read_data2)
            stall_branch = 1'b1;
        else
            stall_branch = 1'b0;
    end

    else
        stall_branch = 1'b0;

end

endmodule