riscv_mp0testbranches.s:
.align 4
.section .text
.globl _start
    # (Kept from the test documentation.)
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    lw  x1, one   
    lw  x2, negone   
	add x4, x1, x0
testbr:
    addi x1, x1, 5
	and x3, x0, x2
	add x4, x4, x2
	beq x4, x0, testbr
testjal:
    lw  x1, one   
    lw  x2, negone   
	add x4, x1, x0
	addi x1, x1, 5
	and x3, x0, x2
	add x4, x4, x2
	j x2, testal
testjalr: 
	lw  x1, one   
    lw  x2, negone   
	add x4, x1, x0
	addi x1, x1, 5
	and x3, x0, x2
	add x4, x4, x2
	j x2, testal

halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.

# In case the processor design is not working successfully and the branch is not comparing the values correctly, 
# typically the case of the XOR used in the comparator design being completed incorrectly, then this is when 
# deadend will show here.
deadend:
    lw x8, bad     # X8 <= 0xdeadbeef
# Simulate a halt by continually going to the same argument here.
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
iterval:    .word 0x00000005
clear:      .word 0x00000000
one:	    .word 0x00000001
negone:	    .word 0xffffffff
