
# Part 2: Recursive Algorithm -- Option C
# Recursive Fibonacci WITH memoization
# MEDS Module 3 -- Grand Assignment


.data
cache:  .space 128          # 32 words -> valid indices 0..31 (n goes up to 30)

msg1:     .string "fib(10) = "
msg2:     .string "fib(20) = "
msg3:     .string "fib(30) = "
newline:  .string "\n"

.text
.globl main

main:
    
    la   t0, cache
    li   t1, 0                 # i = 0
    li   t2, 32                  # 32 words to initialize
init_loop:
    bge  t1, t2, init_done
    li   t3, -1
    slli t4, t1, 2
    add  t5, t0, t4
    sw   t3, 0(t5)
    addi t1, t1, 1
    j    init_loop
init_done:

    #  Test case 1: fib(10), expected 55 
    la   a1, msg1
    li   a0, 4
    ecall
    li   a0, 10
    call fib_memo
    mv   a1, a0
    li   a0, 1
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    #  Test case 2: fib(20), expected 6765 
    la   a1, msg2
    li   a0, 4
    ecall
    li   a0, 20
    call fib_memo
    mv   a1, a0
    li   a0, 1
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    #  Test case 3: fib(30), expected 832040 
    la   a1, msg3
    li   a0, 4
    ecall
    li   a0, 30
    call fib_memo
    mv   a1, a0
    li   a0, 1
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    # exit cleanly
    li   a0, 10
    ecall



# fib_memo(a0 = n) -> a0 = fib(n), using memoized recursion

fib_memo:
    
    addi sp, sp, -16
    sw   ra, 12(sp)
    sw   s0, 8(sp)
    sw   s1, 4(sp)
    mv   s0, a0                 # s0 = n  (survives both recursive calls)

    #  Base case: fib(0)=0, fib(1)=1 
    li   t0, 1
    ble  s0, t0, fib_base

    #  Check the cache first 
    la   t1, cache
    slli t2, s0, 2
    add  t2, t1, t2
    lw   t3, 0(t2)                 # t3 = cache[n]
    li   t4, -1
    beq  t3, t4, fib_compute          # -1 means "not computed yet"
    mv   a0, t3                          # else: cache hit, return it directly
    j    fib_done

fib_compute:
    
    addi a0, s0, -1
    call fib_memo                        # a0 = fib(n-1)
    mv   s1, a0                            # s1 = fib(n-1) (survives next call)

    # fib(n-2)
    addi a0, s0, -2
    call fib_memo                            # a0 = fib(n-2)

    add  a0, a0, s1                            # a0 = fib(n-1) + fib(n-2)

    # store result 
    la   t1, cache
    slli t2, s0, 2
    add  t2, t1, t2
    sw   a0, 0(t2)

    j    fib_done

fib_base:
    mv   a0, s0                  

fib_done:
    lw   s1, 4(sp)
    lw   s0, 8(sp)
    lw   ra, 12(sp)
    addi sp, sp, 16
    ret
