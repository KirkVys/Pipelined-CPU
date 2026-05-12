# Pipelined-CPU
Pipelined-CPU project presents the design and implementation of a MIPS processor in Verilog with 5-stage pipelined design. Processor design supports 11 instructions: 

<img width="400" height="500" alt="image" src="https://github.com/user-attachments/assets/4076f332-2253-4c1a-83b0-de66d39e1053" />



Pipeline design improves throughput by dividing instruction execution into five stages (IF, ID, IE, MA, WB) and overlapping them, so that up to five instructions can be in different stages simultaneously. 

<img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/19f5a360-603c-477d-8577-1ee244451fb1" />



Pipeline registers are inserted between each stage to latch the intermediate results and control signals, ensuring that each stage operates on its own instruction's data independently of the others. However, this overlap introduces hazards: data hazards (when an instruction depends on a result not yet written back), and control hazards (when branch/jump decisions affect which instruction should be fetched next).

The pipelined CPU extends the single cycle design with four pipeline registers (IF/ID, ID/IE, IE/MA, MA/WB), a Forwarding_unit, Hazard_unit, additional muxes, and an Adder. 

### Pipeline Registers

Pipelined processor differs from the single cycle one by having additional modules, which are called pipelined registers (IF/ID, ID/IE, IE/MA, MA/WB). They are needed to store intermediate values of instruction data between stages. As the instruction progresses through the pipeline, only the relevant data is carried forward. Here are the diagrams which clearly show what data is passed to different pipeline registers. All four pipeline registers are driven by clock signal (clk) and get updated on the positive edge of the clock signal and can be cleared using (reset) signal. 

When a stall is required (load-use hazard), the ID/IE register is zeroed out (bubble insertion), effectively converting the instruction into a NOP that writes nothing and accesses no memory. When a flush is required (branch taken or jump), the IF/ID register is zeroed out, discarding the incorrectly fetched instruction.

### Hazards handling

Data hazards occur when an instruction in the IE stage needs a value that hasn't been written back to the register file yet. The Forwarding_unit resolves most data hazards by bypassing values directly from later pipeline stages.

EX-to-EX Hazard: This occurs when two consecutive instructions have a dependency where the first writes to a register and the second reads from it. This handles back-to-back dependent instructions with zero penalty. 
Solution: The result computed by the ALU in the current cycle is forwarded directly from the IE/MA pipeline register back into the ALU inputs for the next instruction. The forwarding unit detects the dependency, and the mux bypasses the register file entirely. 



