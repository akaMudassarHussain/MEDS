
# Part 1: Array Processing
# MEDS Module 3 -- Grand Assignment


.data
array:      .word -5, 12, -100, 47, 3, -8, 99, -23, 56, -1000, 0, 25
array_size: .word 12

msg_sum:    .string "Sum: "
msg_min:    .string "Min: "
msg_max:    .string "Max: "
msg_neg:    .string "Negative count: "
msg_sorted: .string "Sorted array: "
newline:    .string "\n"

.text
.globl main

main:
    #  sum_array 
    la   a0, array
    lw   a1, array_size
    call sum_array
    mv   t6, a0              

    la   a1, msg_sum
    li   a0, 4
    ecall
    mv   a1, t6
    li   a0, 1
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    #  find_min 
    la   a0, array
    lw   a1, array_size
    call find_min
    mv   t6, a0

    la   a1, msg_min
    li   a0, 4
    ecall
    mv   a1, t6
    li   a0, 1
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    #  find_max 
    la   a0, array
    lw   a1, array_size
    call find_max
    mv   t6, a0

    la   a1, msg_max
    li   a0, 4
    ecall
    mv   a1, t6
    li   a0, 1
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    # count_negative 
    la   a0, array
    lw   a1, array_size
    call count_negative
    mv   t6, a0

    la   a1, msg_neg
    li   a0, 4
    ecall
    mv   a1, t6
    li   a0, 1
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    # selection_sort + print_array 
    la   a1, msg_sorted
    li   a0, 4
    ecall

    la   a0, array
    lw   a1, array_size
    call selection_sort      # sorts the array in place

    la   a0, array
    lw   a1, array_size
    call print_array

    la   a1, newline
    li   a0, 4
    ecall

    # exit cleanly
    li   a0, 10
    ecall



sum_array:
    li   t0, 0                
    li   t1, 0                
sum_loop:
    bge  t1, a1, sum_done
    slli t2, t1, 2             
    add  t3, a0, t2              
    lw   t4, 0(t3)              
    add  t0, t0, t4                  
    addi t1, t1, 1                     
    j    sum_loop
sum_done:
    mv   a0, t0
    ret



find_min:
    lw   t0, 0(a0)             
    li   t1, 1                  
min_loop:
    bge  t1, a1, min_done
    slli t2, t1, 2
    add  t3, a0, t2
    lw   t4, 0(t3)
    bge  t4, t0, min_skip         
    mv   t0, t4                     
min_skip:
    addi t1, t1, 1
    j    min_loop
min_done:
    mv   a0, t0
    ret



find_max:
    lw   t0, 0(a0)             
    li   t1, 1
max_loop:
    bge  t1, a1, max_done
    slli t2, t1, 2
    add  t3, a0, t2
    lw   t4, 0(t3)
    ble  t4, t0, max_skip         
    mv   t0, t4
max_skip:
    addi t1, t1, 1
    j    max_loop
max_done:
    mv   a0, t0
    ret



count_negative:
    li   t0, 0                # t0 = count
    li   t1, 0                  # t1 = i
neg_loop:
    bge  t1, a1, neg_done
    slli t2, t1, 2
    add  t3, a0, t2
    lw   t4, 0(t3)
    bge  t4, zero, neg_skip       # if array[i] >= 0, not negative, skip
    addi t0, t0, 1                   # else count++
neg_skip:
    addi t1, t1, 1
    j    neg_loop
neg_done:
    mv   a0, t0
    ret



selection_sort:
    li   t0, 0                 # t0 = i
sel_outer:
    bge  t0, a1, sel_outer_done
    mv   t1, t0                  # t1 = min_idx = i
    addi t2, t0, 1                 # t2 = j = i+1
sel_inner:
    bge  t2, a1, sel_inner_done
    slli t3, t1, 2
    add  t3, a0, t3
    lw   t4, 0(t3)                     # t4 = array[min_idx]
    slli t5, t2, 2
    add  t5, a0, t5
    lw   t6, 0(t5)                       # t6 = array[j]
    bge  t6, t4, sel_inner_skip            # if array[j] >= array[min_idx], skip
    mv   t1, t2                              # else min_idx = j
sel_inner_skip:
    addi t2, t2, 1
    j    sel_inner
sel_inner_done:
    beq  t1, t0, sel_no_swap                   # if min_idx == i, nothing to swap
    slli t3, t0, 2
    add  t3, a0, t3
    lw   t4, 0(t3)                                 # t4 = array[i]
    slli t5, t1, 2
    add  t5, a0, t5
    lw   t6, 0(t5)                                    # t6 = array[min_idx]
    sw   t6, 0(t3)                                       # array[i] = old array[min_idx]
    sw   t4, 0(t5)                                          # array[min_idx] = old array[i]
sel_no_swap:
    addi t0, t0, 1
    j    sel_outer
sel_outer_done:
    ret



print_array:
    mv   t0, a0                # t0 = ptr (a0/a1 get clobbered by ecall below)
    mv   t1, a1                  # t1 = size
    li   t2, 0                     # t2 = i
pa_loop:
    bge  t2, t1, pa_done
    slli t3, t2, 2
    add  t4, t0, t3
    lw   t5, 0(t4)                     # t5 = array[i]
    mv   a1, t5
    li   a0, 1
    ecall                                 # print integer
    li   a1, 32                             # ASCII space
    li   a0, 11
    ecall                                     # print character
    addi t2, t2, 1
    j    pa_loop
pa_done:
    ret
