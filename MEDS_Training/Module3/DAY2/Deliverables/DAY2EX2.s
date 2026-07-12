.text
.globl main
main:
    li t0, 0xDEADBEEF

    andi t1, t0, 0xFF
    srli t2, t0, 8
    andi t2, t2, 0xFF
    srli t3, t0, 16

    mv a1, t1
    addi a0, zero, 1
    ecall

    li a1, 10
    li a0, 11
    ecall

    mv a1, t2
    addi a0, zero, 1
    ecall

    li a1, 10
    li a0, 11
    ecall

    mv a1, t3
    addi a0, zero, 1
    ecall

    addi a0, zero, 10
    ecall
