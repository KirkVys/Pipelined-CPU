module Adder_Substractor(

    input [31:0]a,
    input [31:0]b,
    input cin,
    
    output [31:0]result,
    output cout

);

wire [31:0] carry;
wire [31:0] b_modified;

assign b_modified = b ^ {32{cin}};

genvar i;
generate

    for(i=0; i<32; i = i+1) begin : adder_loop
     if(i==0) 
      Full_adder FA (a[i], b_modified[i], cin, result[i], carry[i]);
     else
      Full_adder FA (a[i], b_modified[i], carry[i-1], result[i], carry[i]); 
     end
endgenerate

assign cout = carry[31];

endmodule