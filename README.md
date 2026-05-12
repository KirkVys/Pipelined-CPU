# Pipelined-CPU
Pipelined-CPU project presents the design and implementation of a MIPS processor in Verilog with 5-stage pipelined design. Processor design supports 11 instructions: 

<img width="400" height="500" alt="image" src="https://github.com/user-attachments/assets/4076f332-2253-4c1a-83b0-de66d39e1053" />

Pipeline design improves throughput by dividing instruction execution into five stages (IF, ID, IE, MA, WB) and overlapping them, so that up to five instructions can be in different stages simultaneously. 

<img width="500" height="200" alt="image" src="https://github.com/user-attachments/assets/19f5a360-603c-477d-8577-1ee244451fb1" />
