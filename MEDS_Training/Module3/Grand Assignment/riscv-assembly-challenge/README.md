# RISC-V Assembly Challenge

This repository contains solutions for the RISC-V Assembly Challenge completed using the Venus RISC-V simulator. The project demonstrates array manipulation, recursive algorithms, and instruction encoding in RISC-V assembly language.

## Repository Structure

```
riscv-assembly-challenge/
│── README.md
│── .gitignore
│── part1_array_ops.s
│── part2_recursion.s
│── part3_encoding.s
│── screenshots/
│── docs/
│    ├── ENCODING_WORKSHEET.md
│    ├── PRIVILEGED_SUMMARY.md
│    └── EXTENSION_SUMMARY.md
```

---

# Part 1 – Array Processing

This file contains assembly programs that perform common array operations.

### Tasks
- Print an integer array
- Find the maximum element
- Find the minimum element
- Calculate the sum of all elements
- Reverse an array
- Linear search

File:
```
part1_array_ops.s
```

---

# Part 2 – Recursive Algorithms

This file demonstrates recursive programming in RISC-V.

### Implemented Algorithms

- Recursive Merge Sort
- Merge function
- Recursive function calls
- Stack frame management
- Register preservation following the RISC-V calling convention

The program sorts three different arrays and prints both the original and sorted arrays.

File:
```
part2_recursion.s
```

Example Output

```
Original Array:
38 27 43 3 9 82 10

Sorted Array:
3 9 10 27 38 43 82

Original Array:
5 4 3 2 1

Sorted Array:
1 2 3 4 5

Original Array:
10 15 2 7 6 1 9 8

Sorted Array:
1 2 6 7 8 9 10 15
```

---

# Part 3 – Instruction Encoding

This section contains manual instruction encoding exercises.

Topics include

- R-Type instructions
- I-Type instructions
- S-Type instructions
- B-Type instructions
- U-Type instructions
- J-Type instructions

File:
```
part3_encoding.s
```

Additional notes are available in

```
docs/ENCODING_WORKSHEET.md
```

---

# Documentation

The `docs` folder contains supporting study material.

| File | Description |
|------|-------------|
| ENCODING_WORKSHEET.md | Manual instruction encoding examples |
| PRIVILEGED_SUMMARY.md | Summary of privileged architecture |
| EXTENSION_SUMMARY.md | Overview of RISC-V ISA extensions |

---

# Screenshots

The `screenshots` folder contains screenshots from Venus showing successful execution of each part.

Examples include:

- Array processing output
- Merge Sort output
- Instruction encoding verification

---

# Running the Programs

Open the source file in the Venus RISC-V simulator.

Assemble the program.

Click **Run**.

Observe the console output.

---

# Requirements

- Venus RISC-V Simulator
- RV32I Instruction Set

---

# Concepts Covered

- Arrays
- Loops
- Conditional Branching
- Procedures
- Function Calls
- Stack Frames
- Recursion
- Merge Sort
- Memory Addressing
- Instruction Encoding
- RV32I Assembly Programming

---

# Author

**Mudassar Hussain**

