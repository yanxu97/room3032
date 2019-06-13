riscv_btb_earlybranch.s:
.align 4
.section .text
.globl _start
    # We will iterate 30 times, over a series of branches and jumps, to flood the global branch predictor with a certain:
    # NT/T/NT/T/NT/T/NT/T OR T/NT/T/NT/T/NT/T/NT pattern. On one of these patterns, our branch predictor will be trained by the
    # iterations to be strongly not taken - since the branch is missed each time. On the other pattern, our branch predictor will be
    # trained for the corresponding local branch predictor TO take the branch. The pattern is broken after 30 iterations complete.

_start:
    addi x1, x0, 40
    add x2, x0, x0
loop:
    addi x1, x1, -1
    addi x2, x2, 1
    beq x0, x1, halt
testone:
    add x3, x2, x0 # Add computation that left shifts data to waste cycles, and push PC to higher value
    j loop

halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.

# In case the processor design is not working successfully and the branch is not comparing the values correctly,
# typically the case of the XOR used in the comparator design being completed incorrectly, then this is when
# deadend will show here.
deadend:
    lw x8, bad     # X8 <= 0xdeadbeef
# Simulate a loop without halt by continually going to the same argument here.
deadloop:
    beq x8, x8, deadloop

# Container for all data loaded into the program.
# bad: Used for when our design is malfunctioning and a bad case is noticed (no jump happened correctly).
# threshold: Unused. Previously found in the given test case.
# result: Unused. Can be adapted to hold the value in R3 at the end of factorial calculation with an sw.
# good: Unused. Previously found in the given test case.
# factval: The value of x in the expression (x!), for what factorial we are calculating here.
# clear: A value of 0x0, that is used either to clear and load (initialize) a register, or check
#        against another register to make sure the end of iteration has been achieved here.
.section .rodata

bad:        .word 0xdeadbeef
threshold:  .word 0x00000040
result:     .word 0x00000000
good:       .word 0x600d600d
factval:    .word 0x00000005
clear:      .word 0x00000000
one:	      .word 0x00000001
negone:	    .word 0xffffffff
four:       .word 0x00000004
