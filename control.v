module control(

    input [31:0] Instruction,

    output reg RegDst, ExtOP, RegWrite, ALUSrc, MemWrite, MemRead, MemtoReg, Jump, Branch,
    output [4:0]rs, rt, rd,
    output [4:0]shamt,
    output [15:0] imm,
    output [25:0] jump_addr,
    output reg [3:0] ALUOp



);

wire [5:0]opCode;
wire [5:0]funct;

assign opCode = Instruction[31:26];
assign rs = Instruction[25:21];
assign rt = Instruction[20:16];
assign rd = Instruction[15:11];
assign funct = Instruction[5:0];
assign shamt = Instruction[10:6];
assign imm = Instruction[15:0];
assign jump_addr = Instruction[25:0];

always@(*) begin

    case(opCode)
        6'h00: begin   //R-type
            RegDst = 1;
            ExtOP = 0;
            RegWrite = 1;
            ALUSrc = 0;
            MemWrite = 0;
            MemRead = 0;
            MemtoReg = 0;
            Branch = 0;
            Jump = 0;
            case(funct) 
                6'h20: ALUOp = 4'b0010; //ADD
                6'h22: ALUOp = 4'b0011; //SUB
                6'h2A: ALUOp = 4'b0111; //SLT
                6'h00: ALUOp = 4'b0101; //SLL
                6'h02: ALUOp = 4'b0110; //SRL
                6'h25: ALUOp = 4'b0001; //OR
                default: ALUOp = 0;
            endcase
        end
        6'h1C: begin   //MUL R-Type
            RegDst = 1;
            ExtOP = 0;
            RegWrite = 1;
            ALUSrc = 0;
            MemWrite = 0;
            MemRead = 0;
            MemtoReg = 0;
            Branch = 0;
            Jump = 0;
            ALUOp = 4'b1000;
        end        
        6'h0D: begin   //ORI
            RegDst = 0;
            ExtOP = 0;
            RegWrite = 1;
            ALUSrc = 1;
            MemWrite = 0;
            MemRead = 0;
            MemtoReg = 0;
            Branch = 0;
            Jump = 0;
            ALUOp = 4'b0001;
        end    
        6'h23: begin   //LW
            RegDst = 0;
            ExtOP = 1;
            RegWrite = 1;
            ALUSrc = 1;
            MemWrite = 0;
            MemRead = 1;
            MemtoReg = 1;
            Branch = 0;
            Jump = 0;
            ALUOp = 4'b0010;
        end
        6'h2B: begin   //SW
            RegDst = 0;
            ExtOP = 1;
            RegWrite = 0;
            ALUSrc = 1;
            MemWrite = 1;
            MemRead = 0;
            MemtoReg = 0;
            Branch = 0;
            Jump = 0;
            ALUOp = 4'b0010;
        end
        6'h02: begin   //Jump
            RegDst = 0;
            ExtOP = 0;
            RegWrite = 0;
            ALUSrc = 0;
            MemWrite = 0;
            MemRead = 0;
            MemtoReg = 0;
            Branch = 0;
            Jump = 1;
            ALUOp = 4'b0000;
        end
        6'h04: begin   //Branch
            RegDst = 0;
            ExtOP = 1;
            RegWrite = 0;
            ALUSrc = 0;
            MemWrite = 0;
            MemRead = 0;
            MemtoReg = 0;
            Branch = 1;
            Jump = 0;
            ALUOp = 4'b0011;
        end
        default: begin
            RegDst = 0;
            ExtOP = 0;
            RegWrite = 0;
            ALUSrc = 0;
            MemWrite = 0;
            MemRead = 0;
            MemtoReg = 0;
            Branch = 0;
            Jump = 0;
            ALUOp = 0;        
        end
    endcase 
end

endmodule

