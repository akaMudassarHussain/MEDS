# RISC-V Extension Summary — "C" (Compressed) Extension

## What It Adds

The base RV32I instruction set uses fixed 32-bit instructions. The
Compressed ("C") extension adds an *additional* set of 16-bit encodings
for the most commonly used instructions — things like `add`, `li`, `mv`,
`beqz`, `sw`/`lw` with small offsets, and function prologues/epilogues.
A compressed instruction is functionally identical to some existing
32-bit instruction; it's simply a shorter way of encoding the same
operation when the operands fall within a limited (but very common)
range — e.g. only using registers x8–x15, or only small immediate
values.

## How It Works

Compressed and standard instructions are freely mixed in the same
instruction stream. The processor tells them apart by looking at the
bottom 2 bits of the first halfword it fetches:

- If those 2 bits are `11`, it's a normal 32-bit instruction.
- Any other value means it's a 16-bit compressed instruction.

Because of this, instruction fetch can no longer assume every
instruction is exactly 4 bytes — the PC may advance by only 2 bytes for
a compressed instruction. This is one of the reasons compressed-aware
decoders are more complex than a pure RV32I decoder.

## Key Instructions

A few representative examples (each maps 1:1 onto a full RV32I
instruction, just packed into 16 bits):

- `c.add rd, rs2` → `add rd, rd, rs2`
- `c.li rd, imm` → `addi rd, x0, imm`
- `c.mv rd, rs2` → `add rd, x0, rs2`
- `c.lw`/`c.sw` — compact load/store for common stack-frame-style
  accesses
- `c.j`, `c.beqz`, `c.bnez` — compact unconditional/conditional jumps

## Why It Matters

- **Code size:** Real-world measurements typically show roughly a
  **25–30% reduction** in compiled code size when the C extension is
  used, since a large fraction of real programs' instructions are
  exactly the simple, common operations the C extension targets.
- **Instruction fetch bandwidth:** Smaller code means fewer bytes need
  to be fetched from memory/flash to execute the same program — directly
  relevant to embedded and IoT devices where memory is limited and
  every fetch costs power and time.
- **No performance penalty for correctness:** Because every compressed
  instruction expands to an *exact* equivalent 32-bit instruction, using
  the C extension doesn't change program behavior at all — it's a
  pure size/efficiency optimization, transparent to the programmer
  (the assembler picks compressed encodings automatically wherever
  applicable).
- **Certification relevance:** The C extension is part of the RVA23
  profile requirements, so any chip targeting general-purpose Linux
  compatibility under that profile is expected to support it.

## Practical Application

In MEDS Lab's FPGA / RTL context, supporting the C extension in a
custom-built RISC-V core would mean the instruction decoder can no
longer assume a fixed 4-byte instruction width — it must detect
compressed instructions via the bottom-2-bits check, decode the
compact encoding, and internally expand it to the equivalent full
instruction before execution (or implement dedicated compressed
execution paths). This is a meaningfully more complex decoder than
the base RV32I decoder built in this module, which is exactly why the
C extension is treated as an optional add-on rather than part of the
mandatory base ISA.
