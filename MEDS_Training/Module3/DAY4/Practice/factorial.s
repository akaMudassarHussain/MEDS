.text
.globl main

factorial:
        addi sp, sp, -16
        sw   ra, 12(sp)
        sw   s0, 8(sp)
        li t0, 1
        ble a0, t0, base_case
        addi a0, a0, -1
        call factorial
        mv a1, a0
        mv a0, s0
        call multiply
        j fact_ret
