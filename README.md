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

# Hazards handling

### Data hazards 
Data Hazards occur when an instruction in the IE stage needs a value that hasn't been written back to the register file yet. The Forwarding_unit resolves most data hazards by bypassing values directly from later pipeline stages.

### EX-to-EX Hazard: 
This occurs when two consecutive instructions have a dependency where the first writes to a register and the second reads from it. This handles back-to-back dependent instructions with zero penalty. 
Solution: The result computed by the ALU in the current cycle is forwarded directly from the IE/MA pipeline register back into the ALU inputs for the next instruction. The forwarding unit detects the dependency, and the mux bypasses the register file entirely. 

### Solution: 
The result computed by the ALU in the current cycle is forwarded directly from the IE/MA pipeline register back into the ALU inputs for the next instruction. The forwarding unit detects the dependency, and the mux bypasses the register file entirely. 

### MEM-to-EX Hazard: 
This is the same dependency problem but with one unrelated instruction in between. The producing instruction has moved further down the pipeline and its result is now in the MA/WB register.
### Solution: 
The result from two instructions ago, which has now reached the MA/WB pipeline register, is forwarded back into the ALU inputs. The forwarding unit checks this path only if no IE/MA match exists, since a closer match always has the more recent data.

### Load-use Hazard: 
This occurs when a lw instruction is immediately followed by an instruction that uses the loaded value. Unlike ALU operations where the result is available after the IE stage, lw doesn't produce its value until the end of the MEM stage.
### Solution: 
Forwarding alone cannot solve this because the data simply doesn't exist yet when the next instruction needs it in IE. The only solution is to stall the pipeline for one cycle, inserting a bubble, and then forward the loaded value from MA/WB on the following cycle.

### Control Hazard

### Branch Hazard: 
When a beq instruction is decoded, the decision on making the branch or not is determined only in the MA stage. By the time decision is made, three instructions have already been fetched. If the branch is taken, three cycles are flushed. This makes each branch instruction very expensive, wasting 3 cycles. 
### Solution: 
Implement the decision in ID stage, therefore wasting only 1 cycle.

### Branch forwarding Hazard: 
This occurs when the instruction immediately before a branch writes to a register that the branch needs to compare.
### Solution: 
When the instruction immediately before the branch is still in the execute stage and produces a value the branch comparator needs, the ALU result is forwarded directly from the execute stage back to the branch comparator in the decode stage. This allows the branch to compare the correct values without inserting a stall.

### Jump Hazard: 
When a j instruction is decoded in ID, the next sequential instruction has already been fetched into the IF/ID register during the same cycle. Since the jump is unconditional, that fetched instruction is always wrong
### Solution: 
The IF/ID register is flushed, inserting a one-cycle bubble, and the PC loads the jump target on the next cycle.

# Hazard Unit implementation
The Hazard unit produces three output signals: stall, stall_jump, and stall_branch. The stall signal is asserted for load-use hazards: it freezes the PC (counter holds its value), holds the IF/ID register (preserving the current instruction for re-execution next cycle), and zeros the ID/IE register (inserting a bubble). The stall_jump signal is asserted when Jump is detected, flushing IF/ID. The stall_branch signal is asserted when Branch is active and the comparator detects equality, flushing IF/ID and loading the branch target into the PC. 

### Forwarding Unit Implementation 
The Forwarding unit produces four output signals: Forward_A[1:0], Forward_B[1:0], Forward_branch_A, Forward_branch_B. The Forward_A[1:0] and Forward_B[1:0] signals control the two 3-input muxes in the execute stage that feed the ALU. For each, the unit first checks whether the IE/MA destination register matches the current IE source register and the IE/MA stage is writing and if so, the signal is set to 2'b00, selecting the ALU result from the IE/MA register. If no IE/MA match exists, it checks whether the MA/WB destination register matches and the MEM/WB stage is writing and if so, the signal is set to 2'b01, selecting the write-back data from the MEM/WB register. If neither matches, the signal defaults to 2'b10, selecting the normal register file value from ID/EX. In all cases, matches against register 0 are ignored since it is hardwired to zero. The Forward_branch_A and Forward_branch_B signals handle the special case where a branch in the decode stage depends on a result still being computed in the execute stage. When the IE destination register matches a branch source register, the branch signal is active, and the IE stage is writing, the corresponding forward signal is asserted, routing the ALU result directly to the branch comparator in the decode stage.

# Design Optimizations

### Early branch resolution: 
Moving the branch decision from the IE stage to the ID stage reduces the branch penalty from 3 flushed instructions to 1. This was achieved by adding a comparator in the ID stage that directly compares register values (with forwarding support from IE) instead of using the ALU's subtraction and zero flag. The trade-off is additional combinational logic in the ID stage, which could slightly increase the critical path through that stage.
### Register file write bypass: 
The register file includes a read bypass mechanism. If the WB stage is writing to the same register that the ID stage is reading in the same cycle, the Write_data value is forwarded directly to the read output instead of reading the stale value from the register array. This is implemented as: assign read_data1 = (RegWrite && r_destination == rs) ? Write_data : registers[rs].
### Sign/zero extension in ID: 
The extender operates in the ID stage with the ExtOP control signal applied immediately, so the extended value is forwarded to the ID/IE register already in its final 32-bit form. This avoids carrying the raw 16-bit immediate and ExtOP signal through additional pipeline stages.



