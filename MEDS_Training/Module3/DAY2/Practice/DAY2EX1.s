.text
.globl main
main:
    li t0, 12
    li t1, 64

    slli t2, t0, 3
    slri t3, t1, 2

    sub t4, t2, t3
    mv a1, t4
    addi a0, zero, 1
    ecall

    addi a0, zero, 10
    ecall