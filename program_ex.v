# ==============================================================================
# SETUP
# ==============================================================================
[3408000A]  ori $t0, $0, 10       # $t0 = 10
[34090014]  ori $t1, $0, 20       # $t1 = 20

# ==============================================================================
# EX-TO-EX & MEM-TO-EX FORWARDING (Data Hazards)
# ==============================================================================
[01095020]  add $t2, $t0, $t1     # $t2 = 30
[01485822]  sub $t3, $t2, $t0     # $t3 = 20 (Forwards $t2 from EX stage)
[014B6025]  or  $t4, $t2, $t3     # $t4 = 30 (Forwards $t2 from MEM, $t3 from EX)

# ==============================================================================
# MATH & SHIFTS
# ==============================================================================
[71096800]  mul $t5, $t0, $t1     # $t5 = 200 (Custom MUL instruction)
[018D702A]  slt $t6, $t4, $t5     # $t6 = 1 (30 < 200)
[000E7900]  sll $t7, $t6, 4       # $t7 = 16 (Shift left logical)
[000F8082]  srl $s0, $t7, 2       # $s0 = 4  (Shift right logical)

# ==============================================================================
# LOAD-USE STALL TEST
# ==============================================================================
[AC100000]  sw  $s0, 0($0)        # Mem[0] = 4
[8C110000]  lw  $s1, 0($0)        # $s1 = 4 
[02319020]  add $s2, $s1, $s1     # $s2 = 8  <-- LOAD-USE HAZARD! Pipeline STALLS for 1 cycle here.
[AC120004]  sw  $s2, 4($0)        # Mem[1] = 8 (Word address 1)

# ==============================================================================
# CONTROL HAZARDS (Jump and Branch Flushes)
# ==============================================================================
[12510003]  beq $s2, $s1, Target3 # Branch Not Taken (8 != 4), PC continues normally
[08000012]  j   Target1           # Jump to instruction 18
[341303E7]  ori $s3, $0, 999      # <-- JUMP DELAY SLOT. Hardware will FLUSH this to a NOP.
[34130309]  ori $s3, $0, 777      # (Skipped by Jump)
[34130378]  ori $s3, $0, 888      # Target3 (Skipped by Jump)
Target1:
[34130064]  ori $s3, $0, 100      # $s3 = 100 (Jump successfully lands here)

# ==============================================================================
# ADVANCED DECODE FORWARDING TEST (Branch Data Hazard)
# ==============================================================================
[340E0005]  ori $t6, $0, 5        # $t6 = 5
[11CE0002]  beq $t6, $t6, Target2 # Branch Taken (5 == 5) <-- Forwards 5 directly into the Decode stage!
[341403E7]  ori $s4, $0, 999      # <-- BRANCH DELAY SLOT. Hardware will FLUSH this to a NOP.
[34140378]  ori $s4, $0, 888      # (Skipped by Branch)
Target2:
[341400C8]  ori $s4, $0, 200      # $s4 = 200 (Branch successfully lands here)

# ==============================================================================
# PIPELINE DRAIN (NOPs)
# ==============================================================================
[00000000]  nop                   # Let the final instruction reach the Writeback stage
[00000000]  nop                   
[00000000]  nop                   
[00000000]  nop












ori $t0, $0, 10       # $t0 = 10
ori $t1, $0, 20       # $t1 = 20


add $t2, $t0, $t1     # $t2 = 30
sub $t3, $t2, $t0     # $t3 = 20 (Forwards $t2 from EX stage)
or  $t4, $t2, $t3     # $t4 = 30 (Forwards $t2 from MEM, $t3 from EX)


mul $t5, $t0, $t1     # $t5 = 200 (Custom MUL instruction)
slt $t6, $t4, $t5     # $t6 = 1 (30 < 200)
sll $t7, $t6, 4       # $t7 = 16 (Shift left logical)
srl $s0, $t7, 2       # $s0 = 4  (Shift right logical)


sw  $s0, 0($0)        # Mem[0] = 4
lw  $s1, 0($0)        # $s1 = 4 
add $s2, $s1, $s1     # $s2 = 8  <-- LOAD-USE HAZARD! Pipeline STALLS for 1 cycle here.
sw  $s2, 4($0)        # Mem[1] = 8 (Word address 1)


beq $s2, $s1, Target3 # Branch Not Taken (8 != 4), PC continues normally
j   Target1           # Jump to instruction 18
ori $s4, $0, 999      # <-- BRANCH DELAY SLOT. Hardware will FLUSH this to a NOP.
ori $s3, $0, 777      # (Skipped by Jump)
ori $s3, $0, 888      # Target3 (Skipped by Jump)
Target1:
ori $s3, $0, 100      # $s3 = 100 (Jump successfully lands here)


ori $t6, $0, 5        # $t6 = 5
beq $t6, $t6, Target2 # Branch Taken (5 == 5) <-- Forwards 5 directly into the Decode stage!
ori $s4, $0, 999      # <-- BRANCH DELAY SLOT. Hardware will FLUSH this to a NOP.
ori $s4, $0, 888      # (Skipped by Branch)
Target2:
ori $s4, $0, 200      # $s4 = 200 (Branch successfully lands here)


[00000000]  nop                   # Let the final instruction reach the Writeback stage
[00000000]  nop                   
[00000000]  nop                   
[00000000]  nop