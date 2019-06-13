#  mp3-cp2a.s version 1.0
.align 4
.section .text
.globl _start
_start:
    beq x0, x0, ldr_str_test
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    # cache line boundary

ldr_str_test:
   add x8, x0, x0 # addi x8, x0, %lo(DataSeg)
   nop
   nop
   nop
   nop
   nop
   lw x1, %lo(W)(x8) #9
   lw x3, %lo(Y)(x8) #1
   # cache line boundary
   lw x2, %lo(X)(x8) #2
   lw x4, %lo(Z)(x8) #3
   nop
   sw x1, %lo(Z)(x8) # Z = 9
   sw x2, %lo(Y)(x8) # Y = 2
   sw x3, %lo(X)(x8) # X = 1
   sw x4, %lo(W)(x8) # W = 3
   nop
   # cache line boundary
   lw x1, %lo(W)(x8) #3
   lw x2, %lo(X)(x8) #1
   lw x3, %lo(Y)(x8) #2
   lw x4, %lo(Z)(x8) #9
   beq x0, x0, fetch_stall_test
   nop
   nop
   nop
   # cache line boundary
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   # cache line boundary
   nop
   nop
   nop
   nop
   nop
   nop
   nop
fetch_stall_test:
   add x5, x1, x2 #4
   # cache line boundary
   add x6, x3, x4 #11 or 0xb
   nop
   nop
   nop
   nop
   sw x5, %lo(VICTIM)(x8)
   add x7, x5, x6 #15 or 0xf
   nop
   # cache line boundary
   nop
   nop
   nop
   sw x7, %lo(TOTAL)(x8)
   lw x1, %lo(TOTAL)(x8)
   nop
inf:
   beq x0, x0, inf
   
   nop
   # cache line boundary
	
.section .rodata
.balign 256
DataSeg:
	nop
	nop
	nop
	nop
	nop
	nop
W:    	.word 0x00000009
X:    	.word 0x00000002
   # cache line boundary

Y: 	.word 0x00000001
Z:  	.word 0x00000003
	nop
	nop
	nop
	nop
	nop
	nop
   # cache line boundary

TOTAL: 	.word 0x00000000
	nop
	nop
	nop
	nop
	nop
	nop
	nop
   # cache line boundary

VICTIM:	.word 0x00000000
	nop
	nop
	nop
	nop
	nop
	nop
	nop
