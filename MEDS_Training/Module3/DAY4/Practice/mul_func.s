.text
.globl main

multiply:
        li t0, 0
        blez a1, mul_done

mul_loop:
        add t0, t0, a0
        addi a1, a1, -1
        bnez a1, mul_loop

mul_done:
        mv a0, t0
        ret

main:
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    li a0, 7
    li a1, 6

    call multiply

    mv a1, a0
    addi a0, zero, 1
    ecall

    lw ra, 12(sp)
    lw s0, 8(sp)
    addi sp, sp, 16
    li a0, 10
    ecall