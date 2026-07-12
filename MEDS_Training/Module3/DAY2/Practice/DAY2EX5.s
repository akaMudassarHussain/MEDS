.data
value: .word 0xDEADBEEF

.text
.globl main
main:
    la s0, value
    lw t1, 0(s0)

    lhu t2, 0(s0)
    lhu t3, 2(s0)

    lbu t4, 0(s0)

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

    li a1, 10
    li a0, 11
    ecall

    mv a1, t4
    addi a0, zero, 1
    ecall

    addi a0, zero, 10
    ecall