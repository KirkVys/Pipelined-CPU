module CPU(

    input clk,
    input reset

);

//FETCH STAGE Wires
//===========================================================================================================

//Inputs of the fetch stage
wire [31:0]PC;
wire [31:0]PC_4;
wire [31:0]Instruction; 

//Outputs of the fetch stage and inputs of the decode stage
wire [31:0]ID_PC_4;
wire [31:0]ID_Instruction;

assign PC_4 = PC + 4;

//DECODE STAGE Wires
//===========================================================================================================

//Inputs of the decode stage
wire RegDst, ExtOP, RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Jump, Branch;
wire [4:0]rs, rt, rd, shamt;
wire [25:0] jump_addr;
wire [15:0] imm;
wire [31:0] extended;
wire [3:0] ALUOp; 


//Outputs of the decode stage
wire IE_RegDst, IE_RegWrite, IE_ALUSrc, IE_MemWrite, IE_MemRead, IE_MemtoReg;
wire [3:0]IE_ALUOp;
wire [31:0]IE_read_data1, IE_read_data2;
wire [31:0]IE_extended;
wire [4:0]IE_rs, IE_rt, IE_rd, IE_shamt;
wire [31:0]Instruction_branch;

assign Instruction_branch = ID_PC_4 + (extended << 2);

//EXECUTION STAGE Wires
//===========================================================================================================

//Inputs of the execute stage
wire [31:0] read_data1, read_data2, input2, read_data1_branch, read_data2_branch;
reg [31:0] input1, input2_intermediate;
wire [31:0] ALUResult;
wire zero_flag;
wire [4:0]r_destination;

//Outputs of the execute stage
wire MA_RegWrite, MA_MemWrite, MA_MemRead, MA_MemtoReg, MA_zero_flag, stall, stall_jump, stall_branch;
wire [31:0]MA_ALU_result;
wire [31:0]MA_Write_data;
wire [4:0]MA_r_destination;
wire [1:0]Forward_A, Forward_B;
wire Forward_branch_A, Forward_branch_B;

always@(*) begin

    case(Forward_A) 
        2'b00: input1 = MA_ALU_result;
        2'b01: input1 = Write_data; //if the forward value is the data you just pulled from memory. Assigning Write_data resolves Mem-to-Ex as well as Load-Use hazard. 
        default: input1 = IE_read_data1;
    endcase

    case(Forward_B) 
        2'b00: input2_intermediate = MA_ALU_result;
        2'b01: input2_intermediate = Write_data; //if the forward value is the data you just pulled from memory. Assigning Write_data resolves Mem-to-Ex as well as Load-Use hazard.
        default: input2_intermediate = IE_read_data2;
    endcase

end


assign input2 = IE_ALUSrc ? IE_extended : input2_intermediate; // input2_intermediate is from register file but can be changed by forwarding unit if hazard happens
assign r_destination = IE_RegDst ? IE_rd : IE_rt; // r_destination values is determined in execution stage but has to travel through MA and WB stages
assign read_data1_branch = Forward_branch_A ? ALUResult : read_data1;
assign read_data2_branch = Forward_branch_B ? ALUResult : read_data2;

//MEMORY-ACCESS STAGE
//===========================================================================================================

//Inputs of the memory-access stage
wire [31:0]Read_data;

//Outputs of the memory-access stage
wire [31:0]WB_Read_data;
wire WB_RegWrite, WB_MemtoReg;
wire [31:0]WB_ALU_result;
wire [4:0]WB_r_destination;

//WRITE-BACK STAGE
//===========================================================================================================

//Outputs of the write-back stage
wire [31:0]Write_data;

assign Write_data = WB_MemtoReg ? WB_Read_data : WB_ALU_result;


//WIRING THE MODULES


//FETCH STAGE MODULES
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
counter_32 Counter(
    .clk(clk), 
    .reset(reset),
    .Jump(Jump),
    .Branch(stall_branch),
    .stall(stall),
    .jump_addr(jump_addr), 
    .Instruction_branch(Instruction_branch),

    .counter(PC)
);

instruction_memory IM(
    .addr(PC), 

    .instr(Instruction)
);

IF_ID IFID(

    .clk(clk),
    .reset(reset),
    .stall(stall),
    .stall_jump(stall_jump),
    .stall_branch(stall_branch),
    .PC_4(PC_4),
    .Instruction(Instruction),

    .PC_4_out(ID_PC_4),
    .Instruction_out(ID_Instruction)

);

//DECODE STAGE MODULES
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
extender32 Ext(

    .imm(imm),
    .ExtOp(ExtOP),

    .ext(extended)

);

control Control(
    .Instruction(ID_Instruction),  

    .RegWrite(RegWrite), 
    .RegDst(RegDst),
    .ExtOP(ExtOP), 
    .ALUSrc(ALUSrc), 
    .MemWrite(MemWrite), 
    .MemRead(MemRead), 
    .MemtoReg(MemtoReg),
    .Jump(Jump),
    .Branch(Branch), 
    .rs(rs), 
    .rt(rt), 
    .rd(rd), 
    .ALUOp(ALUOp),
    .imm(imm), 
    .jump_addr(jump_addr), 
    .shamt(shamt)
);

register_file RF(

    .clk(clk),
    .RegWrite(WB_RegWrite),
    .rs(rs),
    .rt(rt),
    .r_destination(WB_r_destination),
    .Write_data(Write_data),

    .read_data1(read_data1),
    .read_data2(read_data2)
);

ID_IE IDIE(

    .clk(clk),
    .reset(reset),
    .stall(stall),
    .RegDst(RegDst), 
    .RegWrite(RegWrite), 
    .ALUSrc(ALUSrc), 
    .MemWrite(MemWrite), 
    .MemRead(MemRead), 
    .MemtoReg(MemtoReg), 
    .ALUOp(ALUOp),
    .read_data1(read_data1), 
    .read_data2(read_data2),
    .imm_extended(extended),
    .rs(rs), 
    .rt(rt), 
    .rd(rd), 
    .shamt(shamt),

    .RegDst_out(IE_RegDst), 
    .RegWrite_out(IE_RegWrite), 
    .ALUSrc_out(IE_ALUSrc), 
    .MemWrite_out(IE_MemWrite), 
    .MemRead_out(IE_MemRead), 
    .MemtoReg_out(IE_MemtoReg), 
    .ALUOp_out(IE_ALUOp),
    .read_data1_out(IE_read_data1), 
    .read_data2_out(IE_read_data2), 
    .imm_extended_out(IE_extended), 
    .rs_out(IE_rs), 
    .rt_out(IE_rt), 
    .rd_out(IE_rd), 
    .shamt_out(IE_shamt)

);

//EXECUTE STAGE MODULES
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ALU alu(

    .a(input1),
    .b(input2),
    .shamt(IE_shamt),
    .ALUOp(IE_ALUOp),

    .result(ALUResult),
    .zero_flag(zero_flag)

);

Forwarding_unit FU(

    .IE_rs(IE_rs), 
    .IE_rt(IE_rt),
    .ID_rs(rs),
    .ID_rt(rt), 
    .MA_r_destination(MA_r_destination), 
    .WB_r_destination(WB_r_destination), 
    .IE_r_destination(r_destination),
    .Branch(Branch),
    .IE_RegWrite(IE_RegWrite),
    .MA_RegWrite(MA_RegWrite), 
    .WB_RegWrite(WB_RegWrite), 

    .Forward_A(Forward_A), 
    .Forward_B(Forward_B),
    .Forward_branch_A(Forward_branch_A),
    .Forward_branch_B(Forward_branch_B)

);

Hazard_unit HU(

  .IE_MemRead(IE_MemRead),
  .Jump(Jump),
  .Branch(Branch),
  .IE_rt(IE_rt), //In load instruction, the destination register is always rt
  .ID_rs(rs), //rs from decode stage
  .ID_rt(rt), //rt from decode stage
  .ID_read_data1(read_data1_branch), 
  .ID_read_data2(read_data2_branch),

  .stall(stall),   
  .stall_jump(stall_jump),
  .stall_branch(stall_branch)

);

IE_MA IEMA(

    .clk(clk),
    .reset(reset),
    .RegWrite(IE_RegWrite), 
    .MemWrite(IE_MemWrite), 
    .MemRead(IE_MemRead), 
    .MemtoReg(IE_MemtoReg), 
    .ALU_result(ALUResult),
    .zero_flag(zero_flag),
    .Write_data(input2_intermediate), //data hazard handling
    .r_destination(r_destination),

    .RegWrite_out(MA_RegWrite),
    .MemWrite_out(MA_MemWrite), 
    .MemRead_out(MA_MemRead), 
    .MemtoReg_out(MA_MemtoReg), 
    .zero_flag_out(MA_zero_flag),
    .ALU_result_out(MA_ALU_result), 
    .Write_data_out(MA_Write_data),
    .r_destination_out(MA_r_destination)

);

//MEMORY-ACCESS STAGE MODULES
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
data_memory DM(

    .clk(clk),
    .Mem_write(MA_MemWrite),
    .Mem_read(MA_MemRead),
    .addr(MA_ALU_result),
    .Write_data(MA_Write_data),

    .Read_data(Read_data)

);

MA_WB MAWB(

    .clk(clk),
    .reset(reset),
    .RegWrite(MA_RegWrite), 
    .MemtoReg(MA_MemtoReg),
    .Read_data(Read_data),
    .ALU_result(MA_ALU_result),
    .r_destination(MA_r_destination),

    .RegWrite_out(WB_RegWrite), 
    .MemtoReg_out(WB_MemtoReg),
    .Read_data_out(WB_Read_data), 
    .ALU_result_out(WB_ALU_result),
    .r_destination_out(WB_r_destination)
);

endmodule