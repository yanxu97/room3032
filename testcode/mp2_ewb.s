.align 4
.section .text
.globl _start
    
    
_start:
    
    
    la x1, line1
    la x2, line2
    la x3, line3
    nop
    nop
    
    #lw x11, 0(x1) # use it or not
    
    addi x4, x0, 120 #x78
    sb x4, 0(x3)
    sb x4, 4(x3)
    sb x4, 8(x3)
    sb x4, 12(x3)
    sb x4, 16(x3)
    sb x4, 20(x3)
    sb x4, 24(x3)
    sb x4, 28(x3)
    addi x4, x0, 86 #x56
    sb x4, 1(x3)
    sb x4, 5(x3)
    sb x4, 9(x3)
    sb x4, 13(x3)
    sb x4, 17(x3)
    sb x4, 21(x3)
    sb x4, 25(x3)
    sb x4, 29(x3)
    addi x4, x0, 52 #x34
    sb x4, 2(x3)
    sb x4, 6(x3)
    sb x4, 10(x3)
    sb x4, 14(x3)
    sb x4, 18(x3)
    sb x4, 22(x3)
    sb x4, 26(x3)
    sb x4, 30(x3)
    addi x4, x0, 18 #x12
    sb x4, 3(x3)
    sb x4, 7(x3)
    sb x4, 11(x3)
    sb x4, 15(x3)
    sb x4, 19(x3)
    sb x4, 23(x3)
    sb x4, 27(x3)
    sb x4, 31(x3)
    
    # load to cause write back to mem
    lw x11, 0(x1)
    lw x12, 0(x2)
    
    addi x4, x0, 18 #x12
    sll x4, x4, 8
    addi x4, x4, 52 #x34
    
    sh x4, 0(x2)
    sh x4, 2(x2)
    sh x4, 4(x2)
    sh x4, 6(x2)
    sh x4, 8(x2)
    sh x4, 10(x2)
    sh x4, 12(x2)
    sh x4, 14(x2)
    sh x4, 16(x2)
    sh x4, 18(x2)
    sh x4, 20(x2)
    sh x4, 22(x2)
    sh x4, 24(x2)
    sh x4, 26(x2)
    sh x4, 28(x2)
    sh x4, 30(x2)
    
    # load to cause write back to mem
    lw x11, 0(x1)
    lw x12, 0(x3)
    

inf:
    jal x0, inf

	
.section .rodata
.balign 256
.zero 96
line1:      .word 0x11111111
line11:	    .word 0x00000000
line12:     .word 0x00000000
line13:	    .word 0x00000000
line14:	    .word 0x00000000
line15:	    .word 0x00000000
line16:	    .word 0x00000000
line17:	    .word 0x00000000
line18:	    .word 0x00000000
line19:	    .word 0x00000000
line1a:	    .word 0x00000000
line1b:	    .word 0x00000000
line1c:	    .word 0x00000000
line1d:	    .word 0x00000000
line1e:	    .word 0x00000000
line1f:	    .word 0x00000000
.balign 256
.zero 96
line2:      .word 0x22222222
line21:	    .word 0x00000000
line22:	    .word 0x00000000
line23:	    .word 0x00000000
line24:	    .word 0x00000000
line25:	    .word 0x00000000
line26:	    .word 0x00000000
line27:	    .word 0x00000000
line28:	    .word 0x00000000
line29:	    .word 0x00000000
line2a:	    .word 0x00000000
line2b:	    .word 0x00000000
line2c:	    .word 0x00000000
line2d:	    .word 0x00000000
line2e:	    .word 0x00000000
line2f:	    .word 0x00000000
.balign 256
.zero 96
line3:	    .word 0x33333333
line31:	    .word 0x00000000
line32:	    .word 0x00000000
line33:	    .word 0x00000000
line34:	    .word 0x00000000
line35:	    .word 0x00000000
line36:	    .word 0x00000000
line37:	    .word 0x00000000
line38:	    .word 0x00000000
line39:	    .word 0x00000000
line3a:	    .word 0x00000000
line3b:	    .word 0x00000000
line3c:	    .word 0x00000000
line3d:	    .word 0x00000000
line3e:	    .word 0x00000000
line3f:	    .word 0x00000000
