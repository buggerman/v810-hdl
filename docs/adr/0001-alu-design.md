# ADR 0001 — ALU is single-cycle combinational; MUL / DIV live in a separate unit

## Status

Accepted — 2026-04-19.

## Context

The V810 ISA includes arithmetic (ADD, SUB), logical (AND, OR, XOR, NOT),
shift (SHL, SHR, SAR), multiplication (MUL, MULU), and division (DIV, DIVU)
instructions that all conceptually belong "in the ALU."

If we implement them in a single module, we have two bad options:

1. **Make the whole ALU multi-cycle.** Every instruction pays the MUL/DIV
   latency cost, even a trivial ADD. Pipeline control gets variable-latency
   semantics for no benefit.
2. **Make MUL/DIV single-cycle with large DSP-block and LUT allocation.**
   Cyclone V has only 112 DSP blocks total, and we need to share them across
   CPU, FPU, KING (in the PaCiFaX integration), and PC Engine-style
   video blocks downstream. A single-cycle 32×32 multiply burns too many.

Most modern RISC cores resolve this by placing multi-cycle operations in a
dedicated functional unit with a valid/ready handshake.

## Decision

`v810_alu` is a single-cycle, purely combinational module that implements:

- ADD, SUB
- AND, OR, XOR, NOT
- SHL, SHR, SAR
- MOV (data passthrough for reg-reg moves)

Multiplication and division will be implemented in a separate module
`v810_muldiv` (later phase) that presents a valid/ready handshake to the
pipeline and takes multiple cycles to produce a result. The decoder chooses
between the ALU and muldiv units based on instruction opcode.

CMP does not need a distinct ALU operation: the decoder issues ALU_SUB and
the writeback stage suppresses the register write while retaining the flag
update.

## Consequences

**Positive**

- Pipeline control is simpler: no variable-latency path through the main ALU.
- Adding or retuning the multiplier/divider later is non-invasive.
- DSP-block allocation decisions are localized to one module.
- Unit testing is easier: the ALU has no state, so every op is one comb test.

**Negative / accepted**

- Carry/borrow polarity for SUB is implemented as "borrow set on a < b
  (unsigned)." This matches most RISC conventions but requires verification
  against the NEC V810 family manual. Tracked as an open item in
  `docs/ISA.md` and will be reconciled before leaving Phase 1.
- PSW overflow/carry are only meaningful on ADD and SUB; logical and shift
  ops force them to zero. The decoder must be aware of which ops produce
  meaningful OV/CY so it does not inadvertently clobber PSW bits that the
  software expects to be preserved by logical ops. Verification item.
