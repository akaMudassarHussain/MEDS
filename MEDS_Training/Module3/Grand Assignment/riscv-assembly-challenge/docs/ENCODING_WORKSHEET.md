# Encoding Worksheet — Hand-Encoded Instructions

One instruction per RISC-V format (R, I, S, B, U, J), fully derived by hand.
Each result was cross-checked using two independent methods: (1) building
the raw 32-bit binary string field-by-field, and (2) summing each field
shifted into its correct bit position. Both methods agreed for every
instruction below.

---

## 1. R-type: `add x6, x7, x8`

**Fields:** opcode=`0110011`, funct3=`000`, funct7=`0000000`, rd=x6, rs1=x7, rs2=x8

| Field | Value | Binary |
|---|---|---|
| funct7 | 0 | 0000000 |
| rs2 | x8 | 01000 |
| rs1 | x7 | 00111 |
| funct3 | 0 | 000 |
| rd | x6 | 00110 |
| opcode | ADD | 0110011 |

**Binary (31→0):** `0000000 01000 00111 000 00110 0110011`

**Shift-and-add check:**
```
(0<<25) + (8<<20) + (7<<15) + (0<<12) + (6<<7) + 0x33
= 0x000000 + 0x800000 + 0x038000 + 0x000000 + 0x000300 + 0x000033
= 0x00838333
```

**Result: `0x00838333`**

---

## 2. I-type: `addi x15, x1, -10`

**Fields:** opcode=`0010011`, funct3=`000`, imm=-10, rd=x15, rs1=x1

-10 as a 12-bit two's complement value: take `10` = `0000 0000 1010`,
invert → `1111 1111 0101`, add 1 → `1111 1111 0110` = `0xFF6`

| Field | Value | Binary |
|---|---|---|
| imm[11:0] | -10 | 111111110110 |
| rs1 | x1 | 00001 |
| funct3 | 0 | 000 |
| rd | x15 | 01111 |
| opcode | ADDI | 0010011 |

**Binary (31→0):** `111111110110 00001 000 01111 0010011`

**Shift-and-add check:**
```
(0xFF6<<20) + (1<<15) + (0<<12) + (15<<7) + 0x13
= 0xFF600000 + 0x8000 + 0x0 + 0x780 + 0x13
= 0xFF608793
```

**Result: `0xFF608793`**

---

## 3. S-type: `sw x10, 8(x2)`

**Fields:** opcode=`0100011`, funct3=`010`, imm=8, rs1=x2, rs2=x10 (value being stored)

imm=8 as 12 bits: `000000001000` → split as imm[11:5]=`0000000`, imm[4:0]=`01000`

| Field | Value | Binary |
|---|---|---|
| imm[11:5] | 0 | 0000000 |
| rs2 | x10 | 01010 |
| rs1 | x2 | 00010 |
| funct3 | 2 (word) | 010 |
| imm[4:0] | 8 | 01000 |
| opcode | SW | 0100011 |

**Binary (31→0):** `0000000 01010 00010 010 01000 0100011`

**Shift-and-add check:**
```
(0<<25) + (10<<20) + (2<<15) + (2<<12) + (8<<7) + 0x23
= 0x0 + 0xA00000 + 0x10000 + 0x2000 + 0x400 + 0x23
= 0x00A12423
```

**Result: `0x00A12423`**

---

## 4. B-type: `beq x1, x2, 16`

**Fields:** opcode=`1100011`, funct3=`000`, offset=+16 bytes, rs1=x1, rs2=x2

16 as a 13-bit signed offset (bit0 is always 0, implicit): binary `0 0000000 1 0000 0`
Splitting per the B-type layout: imm[12]=0, imm[11]=0, imm[10:5]=`000000`, imm[4:1]=`1000`

| Field | Value | Binary |
|---|---|---|
| imm[12] | 0 | 0 |
| imm[10:5] | 0 | 000000 |
| rs2 | x2 | 00010 |
| rs1 | x1 | 00001 |
| funct3 | 0 (BEQ) | 000 |
| imm[4:1] | 8 | 1000 |
| imm[11] | 0 | 0 |
| opcode | BRANCH | 1100011 |

**Binary (31→0):** `0 000000 00010 00001 000 1000 0 1100011`

**Shift-and-add check:**
```
(0<<31) + (0<<25) + (2<<20) + (1<<15) + (0<<12) + (8<<8) + (0<<7) + 0x63
= 0x0 + 0x0 + 0x200000 + 0x8000 + 0x0 + 0x800 + 0x0 + 0x63
= 0x00208863
```

**Result: `0x00208863`**

---

## 5. U-type: `lui x5, 0x12345`

**Fields:** opcode=`0110111`, imm[31:12]=`0x12345`, rd=x5

| Field | Value | Binary |
|---|---|---|
| imm[31:12] | 0x12345 | 00010010001101000101 |
| rd | x5 | 00101 |
| opcode | LUI | 0110111 |

**Binary (31→0):** `00010010001101000101 00101 0110111`

**Shift-and-add check:**
```
(0x12345<<12) + (5<<7) + 0x37
= 0x12345000 + 0x280 + 0x37
= 0x123452B7
```

**Result: `0x123452B7`**

---

## 6. J-type: `jal x1, 100`

**Fields:** opcode=`1101111`, offset=+100 bytes, rd=x1

100 as a 21-bit signed offset (bit0 implicit 0): `100` decimal = `1100100` binary (bit6..bit0).
Per the J-type layout: imm[20]=0, imm[19:12]=`00000000`, imm[11]=0, imm[10:1]=`0000110010`

| Field | Value | Binary |
|---|---|---|
| imm[20] | 0 | 0 |
| imm[10:1] | 50 | 0000110010 |
| imm[11] | 0 | 0 |
| imm[19:12] | 0 | 00000000 |
| rd | x1 | 00001 |
| opcode | JAL | 1101111 |

**Binary (31→0):** `0 0000110010 0 00000000 00001 1101111`

**Shift-and-add check:**
```
(0<<31) + (50<<21) + (0<<20) + (0<<12) + (1<<7) + 0x6F
= 0x0 + 0x6400000 + 0x0 + 0x0 + 0x80 + 0x6F
= 0x064000EF
```

**Result: `0x064000EF`**  *(also independently verified by full bit-string construction — matches)*

---

## Summary Table

| # | Instruction | Format | Hex Encoding |
|---|---|---|---|
| 1 | `add x6, x7, x8` | R | `0x00838333` |
| 2 | `addi x15, x1, -10` | I | `0xFF608793` |
| 3 | `sw x10, 8(x2)` | S | `0x00A12423` |
| 4 | `beq x1, x2, 16` | B | `0x00208863` |
| 5 | `lui x5, 0x12345` | U | `0x123452B7` |
| 6 | `jal x1, 100` | J | `0x064000EF` |

These 6 values are loaded directly as `.word` data in `part3_encoding.s`,
which decodes them back into opcode/rd/rs1/funct3 using shift-and-mask —
proving these hand-derivations are correct.

**How to verify in Venus:** paste each instruction (e.g. `add x6, x7, x8`)
into the Editor tab, assemble it, and check the generated machine code in
the instruction/memory panel — it should match the hex value above exactly.

