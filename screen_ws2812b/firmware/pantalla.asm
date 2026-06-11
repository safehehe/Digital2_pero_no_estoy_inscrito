.equ SCREEN_BASE 0x500000
.equ INIT 0x100 #un frame 64 pixeles

.section .text
.globl init_screen
.globl write_screen

init_screen:
    li gp, SCREEN_BASE
    li t0, 1
    sw t0, INIT(gp)
    sw zero, INIT(gp)
    ret

write_screen:
    #a1 frame
    #a0 pixel
    #a2 color
    #slli a1, a1, $clog2(QTY_PIXELS)
    #add a0,a0,a1 esto si hay más de un frame
    addi a0,a0,SCREEN_BASE
    sw a2, 0(a0)
    ret