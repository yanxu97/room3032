riscv_btb_earlybranch.s:
.align 4
.section .text
.globl _start
    # This test is meant to isolate behavior for the BTB, showing where there should be a hit,
    # where misprediction cases should happen, and how jumps should be treated (including JALR,
    # where the destination can change based on a register value).

    # As a result of heavily using branches, one can use the PC values to track early branch
    # prediction in the EX stage as well. Thus, the test is written for this purpose as well.

    # For fast evaluation metrics with only BTB connected, you can use this:
    #   - 6 Branch Mispredicts caused by branches
    #   - 3 Branch Mispredicts caused by Jumps (1 on first discover of JAL, another for first JALR, another for JALR incorrect dest.)
    #   - 9 Branch Mispredicts in Total
    #   - 6 occupied lines in the Branch Target Buffer
    #   - 2 occupied jumps for JAL and JALR occurrences
    #
    # __|__ like lines (as opposed to __||__ lines) do not count as branch mispredicts, since the low value would be read by all items reading from this signal.
    # This is due to the fact that all of these are registers and wait for a stable signal still.

_start:
    lw  x4, four
    add x1, x0, x0
    # Test one consists of a loop that iterates for four (4) iterations. The first branch should miss.
    # The next three branches should predict taken from the BTB alone, with the last one incorrectly taken
    # since it would conclude iteration. However, the result can be modified from our branch predictor's input as well.
    # Therefore, we simply should see that a "btb_valid" was listed here with correct storage data:
    # - storage happens in set 13 (zero-indexed), as PC at br is x74, and x74[5:2] = 13_10.
    # - dest_storage has 0x6c (0x74 - 0x08, since each instruction is 0x04)
    # - pc_storage has 0x1 (tag)
    # - jump_storage has 0x0 (no jumps added yet)
testone:
    add x1, x4, x4
    addi x4, x4, -1
    bne x0, x4, testone

    # Test two moves on and utilizes BTB knowledge with jumps, the traditional JAL kind.
    # These, since these are valid, should always be taken no matter what the branch predictor is suggesting to do.

    # Again, we're doing four iterations of this. On the fourth iteration, we go past the jump instruction.
    # For testing the branch predictor, this causes an interesting case where we can keep seeing a NT/T pattern
    # across the iterations. Since it lasts for three iterations, it nearly fills up all 8 bits of the register
    # used to XOR with the PC values.

    # Note that the branch instruction that comes before will also cause a write to happen inside of the BTB.
    lw  x4, four
    add x1, x0, x0
testtwo:
    la x30, testtwo_x7check
    add x1, x4, x4
    addi x4, x4, -1
    beq x0, x4, testtwo_x7check
    jal x7, testtwo
testtwo_x7check:
    bne x7, x30, deadend
    # Before moving on, even if you make it past this line, that branch should NOT
    # show up or change the BTB contents. It should never be taken, so never should be written.

    # Then there is JALR. We have already seen what happens with traditional jumps, but what happens when the destination
    # itself changes because of a register? We predicted the wrong destination, we would have to overwrite even though we are taken.
    # Test that here and track the stalls of the system.
    addi x2, x0, 3
    la x31, testthree
    la x29, testthree_x7trap
    la x28, testthree_x7check
    # The first jump will miss, the second will jump with correct PC, the third will try to jump but with incorrect PC.

    # Again, note that a branch pops up here, so it will modify some of the original taken prediction from BTB here.
testthree:
    add x1, x2, x2
    addi x2, x2, -1
    bne x0, x2, testthree_x7jalr
    la x31, testthree_x7check   # Change the register to force a different jump
testthree_x7jalr:
    jalr x7, x31, 0
testthree_x7trap:
    lw x7, bad
testthree_x7check:
    bne x7, x29, deadend
    lw x7, good


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
