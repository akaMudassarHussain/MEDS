# RISC-V Privileged Architecture — Summary

*Based on RISC-V Privileged Specification (Volume 2), Sections 3.1–3.4*

## Why Privilege Levels Exist

A CPU that ran every program at equal trust would be fundamentally unsafe:
any user program could reprogram interrupt handlers, read another
process's memory, or halt the whole machine. RISC-V solves this with a
layered privilege model, where each layer can only do what its layer is
permitted to do, and control can only move to a *more* privileged layer
through carefully defined, hardware-checked mechanisms (traps).

## Privilege Levels

| Level | Encoding | Who runs here | Notes |
|---|---|---|---|
| **Machine (M)** | 11 | Firmware, bootloader | Mandatory on every RISC-V implementation. Full, unrestricted access to hardware. The "root" of trust. |
| **Supervisor (S)** | 01 | OS kernel (e.g. Linux) | Optional. Manages virtual memory (page tables) and mediates hardware access for user programs. |
| **User (U)** | 00 | Applications | Optional. Most restricted — cannot directly access privileged CSRs or raw hardware. |

A minimal embedded core (such as the kind built for a class FPGA project)
commonly implements **only M-mode** — there's no need for OS-level
isolation if there's no OS. A general-purpose Linux-capable chip needs
all three, because the M/S/U split is exactly what lets the OS kernel
safely isolate user processes from each other and from the hardware.

## Key Control and Status Registers (CSRs)

CSRs are a separate register file from the 32 general-purpose registers,
dedicated to controlling and reporting on privileged operation.

| CSR | Purpose |
|---|---|
| **mstatus** | Global status: whether interrupts are currently enabled, which privilege mode the processor was in before the current trap, and related state bits. |
| **mtvec** | Holds the address of the trap handler. When a trap occurs, hardware automatically redirects the PC to this address. |
| **mepc** | "Exception PC" — hardware automatically saves the address of the interrupted instruction here the moment a trap fires, so execution can be resumed later. |
| **mcause** | A numeric code identifying *why* the trap occurred (e.g. illegal instruction, `ecall`, timer interrupt, misaligned access). The trap handler reads this first to decide what to do. |
| **mtval** | Extra diagnostic detail for certain traps (e.g. the faulting memory address for a page fault), used mainly for debugging/logging. |

## Trap Handling Flow

A "trap" is the umbrella term for both **exceptions** (synchronous events
caused directly by the currently executing instruction, e.g. `ecall`,
illegal instruction) and **interrupts** (asynchronous events, e.g. a
timer or external device signal).

1. **Trap occurs.** The processor detects an exception or interrupt.
2. **Hardware response (automatic, not software):**
   - `mepc` ← current PC (so we know where to resume)
   - `mcause` ← a code identifying the trap's cause
   - PC ← `mtvec` (execution jumps to the trap handler)
3. **Trap handler executes.** Software reads `mcause` to identify the
   situation, and does whatever is appropriate — e.g. servicing a
   system call, emulating an unsupported instruction, or handling a
   device interrupt.
4. **Handler executes `MRET`** ("Machine Return"). This restores the PC
   from `mepc` and returns the processor to its previous privilege
   level, resuming normal execution exactly where it left off.

This mirrors the same "remember where I was, do something else, then
come back" pattern used by `jal`/`ret` in ordinary function calls — the
key difference is that a trap is triggered automatically by hardware
(not deliberately by a `jal` instruction), and it uses `mepc`/`MRET`
instead of `ra`/`ret` to remember and restore the return point.

## Why This Matters

The privileged architecture is what makes a single RISC-V core capable of
safely running a full multi-tasking operating system: it's the reason a
crashing user application doesn't take down the kernel, the reason the
kernel can enforce memory protection between processes, and the reason
system calls (`ecall`) can safely hand control from an unprivileged
application to trusted kernel code and back again.
