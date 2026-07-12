# Exercise 3: Sum an array of 8 words

.data
array: .word 5, 10, 15, 20, 25, 30, 35, 40

.text
.globl main
main:
    la   s0, array      # s0 = base address
    li   s1, 8            # s1 = size
    li   t0, 0              # t0 = i
    li   t1, 0                # t1 = sum

loop:
    bge  t0, s1, done
    slli t2, t0, 2               # t2 = i * 4 (byte offset)
    add  t3, s0, t2                # t3 = &array[i]
    lw   t4, 0(t3)                    # t4 = array[i]
    add  t1, t1, t4                     # sum += array[i]
    addi t0, t0, 1                        # i++
    j    loop

done:
    mv   a1, t1
    addi a0, zero, 1
    ecall

    addi a0, zero, 10
    ecall