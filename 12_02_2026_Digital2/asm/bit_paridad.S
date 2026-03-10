
#a0 <- data[7:0] 10101101 
#a1 tmp
#a2 <-       par 1
#t1 iterarion counter
.equ MASK_0, 0x01
.section .text
start :
    li t1, 0x08

loopMain :
    andi a1, t0, MASK_0 #obtener bit 0
    xor a2, a2, a1      #contar bit
    addi t1, -1         #restar contador
    beqz t1, start
    srli a0, a0, 1      #corrimiento a derecha
    j loopMain
    