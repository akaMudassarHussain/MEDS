.data
array: .word 5, 10, -90, 89, 56, 79, 94, -20, -34, 99, 130, -78, 45

.text
.globl main
main:
    li t0, 1
    li s1, 13
    la s0, array
    lw t1, 0(s0)

loop:
    bge t0, s1, done
    slli t2, t0, 2
    add t3, s0, t2
    lw t4, 0(t3)
    blt t4, t1, skip
    mv t1, t4

skip:
    addi t0, t0, 1
    j loop

done:
    mv a1, t1
    addi a0, zero, 1
    ecall

    addi a0, zero, 10
    ecall

