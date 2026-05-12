module Forwarding_unit(

    input[4:0]ID_rs, ID_rt, IE_rs, IE_rt, MA_r_destination, WB_r_destination, IE_r_destination,
    input MA_RegWrite, WB_RegWrite, Branch, IE_RegWrite,

    output reg [1:0]Forward_A, Forward_B, 
    output reg Forward_branch_A, Forward_branch_B

);


//General Data hazards (Ex-to-Ex, Mem-to-Ex, and Load-Use Hazards). 
always@(*) begin

    //Check for RS register
    if(MA_r_destination == IE_rs && MA_RegWrite && MA_r_destination != 0) //Ex-to-Ex Hazard 
        Forward_A = 2'b00;
    else if(WB_r_destination == IE_rs && WB_RegWrite && WB_r_destination != 0)  //Mem-to-Ex and Load-Use Hazards
        Forward_A = 2'b01;
    else
        Forward_A = 2'b10; // No Hazards

    //Check for RT register
    if(MA_r_destination == IE_rt && MA_RegWrite && MA_r_destination != 0) //Ex-to-Ex Hazard 
        Forward_B = 2'b00;
    else if(WB_r_destination == IE_rt && WB_RegWrite && WB_r_destination != 0)  //Mem-to-Ex and Load-Use Hazards
        Forward_B = 2'b01;
    else
        Forward_B = 2'b10; // No Hazards

end

//Data hazard because of the branch instruction executing in the decode stage
always@(*) begin
    // Check rs for branch
    if(IE_r_destination == ID_rs && Branch && IE_r_destination != 0 && IE_RegWrite)
        Forward_branch_A = 1'b1;
    else
        Forward_branch_A = 1'b0;

    // Check rt for branch
    if(IE_r_destination == ID_rt && Branch && IE_r_destination != 0 && IE_RegWrite)
        Forward_branch_B = 1'b1;
    else
        Forward_branch_B = 1'b0;
end


endmodule