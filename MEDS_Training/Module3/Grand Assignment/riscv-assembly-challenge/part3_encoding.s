
# Part 3: Instruction Encoding -- Field Extractor
# MEDS Module 3 -- Grand Assignment


# Expected output (verified by ENCODING_WORKSHEET.md):
#   R-type (add x6,x7,x8)      opcode=51  rd=6   rs1=7  funct3=0
#   I-type (addi x15,x1,-10)   opcode=19  rd=15  rs1=1  funct3=0
#   S-type (sw x10,8(x2))      opcode=35  rd=8*  rs1=2  funct3=2
#   B-type (beq x1,x2,16)      opcode=99  rd=16* rs1=1  funct3=0
#   U-type (lui x5,0x12345)    opcode=55  rd=5   rs1=8* funct3=5*
#   J-type (jal x1,100)        opcode=111 rd=1   rs1=0* funct3=0*
#   (* = not a real register/funct3 for this format -- raw immediate bits)


.data
instructions: .word 0x00838333, 0xFF608793, 0x00A12423, 0x00208863, 0x123452B7, 0x064000EF

label0: .string "\nR-type (add x6,x7,x8):"
label1: .string "\nI-type (addi x15,x1,-10):"
label2: .string "\nS-type (sw x10,8(x2)):"
label3: .string "\nB-type (beq x1,x2,16):"
label4: .string "\nU-type (lui x5,0x12345):"
label5: .string "\nJ-type (jal x1,100):"

label_table: .word label0, label1, label2, label3, label4, label5

msg_opcode: .string "  opcode="
msg_rd:     .string "  rd="
msg_rs1:    .string "  rs1="
msg_f3:     .string "  funct3="
msg_mnem:   .string "  mnemonic="
newline:    .string "\n"

#  BONUS: mnemonic strings for the mini-disassembler 
str_add:     .string "add"
str_addi:    .string "addi"
str_sw:      .string "sw"
str_beq:     .string "beq"
str_lui:     .string "lui"
str_jal:     .string "jal"
str_unknown: .string "unknown"

.text
.globl main

main:
    la   s0, instructions      # s0 = base of instruction word array
    la   s1, label_table         # s1 = base of label-pointer array
    li   s2, 0                     # s2 = i (loop counter)
    li   s3, 6                       # s3 = count (6 instructions)

decode_loop:
    bge  s2, s3, decode_done

    #  print this instruction's label 
    slli t0, s2, 2
    add  t1, s1, t0
    lw   a1, 0(t1)                 # a1 = address of label string
    li   a0, 4
    ecall
    la   a1, newline
    li   a0, 4
    ecall

    #  fetch the instruction word 
    slli t0, s2, 2
    add  t1, s0, t0
    lw   t2, 0(t1)                   # t2 = instruction word

    #  extract fields (t2 is never modified below) 
    andi t3, t2, 0x7F                  # opcode = instr & 0x7F          (bits 6:0)
    srli t4, t2, 7
    andi t4, t4, 0x1F                    # rd = (instr >> 7) & 0x1F     (bits 11:7)
    srli t5, t2, 12
    andi t5, t5, 0x7                       # funct3 = (instr >> 12) & 0x7 (bits 14:12)
    srli t6, t2, 15
    andi t6, t6, 0x1F                        # rs1 = (instr >> 15) & 0x1F  (bits 19:15)

    #  print opcode 
    la   a1, msg_opcode
    li   a0, 4
    ecall
    mv   a1, t3
    li   a0, 1
    ecall

    #  BONUS: print mnemonic looked up from opcode 
    la   a1, msg_mnem
    li   a0, 4
    ecall
    mv   a0, t3                    # a0 = opcode (argument)
    call get_mnemonic
    mv   a1, a0                      # a1 = returned string address
    li   a0, 4
    ecall

    #  print rd 
    la   a1, msg_rd
    li   a0, 4
    ecall
    mv   a1, t4
    li   a0, 1
    ecall

    #  print rs1 
    la   a1, msg_rs1
    li   a0, 4
    ecall
    mv   a1, t6
    li   a0, 1
    ecall

    #  print funct3 
    la   a1, msg_f3
    li   a0, 4
    ecall
    mv   a1, t5
    li   a0, 1
    ecall

    addi s2, s2, 1
    j    decode_loop

decode_done:
    la   a1, newline
    li   a0, 4
    ecall
    li   a0, 10
    ecall



# BONUS: get_mnemonic(a0 = opcode) -> a0 = address of mnemonic string


get_mnemonic:
    li   t0, 0x33
    beq  a0, t0, mn_add
    li   t0, 0x13
    beq  a0, t0, mn_addi
    li   t0, 0x23
    beq  a0, t0, mn_sw
    li   t0, 0x63
    beq  a0, t0, mn_beq
    li   t0, 0x37
    beq  a0, t0, mn_lui
    li   t0, 0x6F
    beq  a0, t0, mn_jal
    la   a0, str_unknown
    ret
mn_add:
    la   a0, str_add
    ret
mn_addi:
    la   a0, str_addi
    ret
mn_sw:
    la   a0, str_sw
    ret
mn_beq:
    la   a0, str_beq
    ret
mn_lui:
    la   a0, str_lui
    ret
mn_jal:
    la   a0, str_jal
    ret
