# ADR 0002 — Phase 1 microarchitecture: single-cycle, 32-bit aligned fetch

## Status

Accepted — 2026-04-19. Scope: Phase 1 only. Phase 3 introduces pipelining and supersedes this.

## Context

Phase 1's goal is a functionally-correct end-to-end instruction path
(fetch → decode → regfile → ALU → writeback) on which Formats II–VII,
bit-string ops, FPU, and interrupts can be built incrementally. Pipelining,
forwarding, and interlocks are Phase 3 concerns; optimizing for them now
would slow Phase 1 and risk building the wrong abstraction.

V810 instructions are 16-bit (Formats I/II/III) or 32-bit (Formats IV/V/VI/VII).
All instructions are halfword-aligned (2-byte alignment), not necessarily
4-byte-aligned. A 32-bit instruction can span a 4-byte memory boundary.

## Decision

**Microarchitecture.** The Phase 1 CPU is single-cycle and
non-pipelined. One instruction retires per clock. The combinational path
per cycle is:

  fetch → decode → regfile read → ALU → writeback-mux

Synchronous updates at posedge clk: regfile write, PC advance.

**Instruction fetch.** The instruction memory port is 32-bit wide and
accessed only at 4-byte-aligned addresses. The fetch unit selects the
"current halfword" inside the fetched 32-bit word using `pc[1]`:

  - `pc[1] == 0` → instruction halfword = `imem_rdata[15:0]`
  - `pc[1] == 1` → instruction halfword = `imem_rdata[31:16]`

Only 16-bit Format I instructions are supported in Phase 1. 32-bit
instructions are deferred to Phase 2 and will add a second fetch buffer
plus a stall cycle when a 32-bit instruction spans a 4-byte boundary.

**Placeholder opcodes.** The decoder's 6-bit opcode values for Format I
are placeholders (see `rtl/v810_decoder.sv` header). They are
internally consistent with the testbench and sufficient for synthetic
integration testing. Before the core executes real V810 software, these
must be verified against the NEC V810 Family User Manual
(`u10082ej1v0um00.pdf`); tracked as the first item in the
`docs/ISA.md` verification checklist.

## Consequences

**Positive**

- Minimum viable CPU, easy to reason about, easy to unit-test.
- Any instruction-semantic bug is localized to one module.
- Clear, narrow interface to be reused by the Phase 3 pipelined variant.

**Negative / accepted**

- Cannot hit target clock frequency on Cyclone V. Phase 1 optimizes for
  correctness, not Fmax. Phase 3 pipeline fixes this.
- Assumes combinational instruction memory (infinite bandwidth, zero
  latency). The testbench models this with a simple ROM. Real silicon
  integration will need a multi-cycle BRAM or SDRAM controller in front of
  fetch, handled in a later phase.
- Only 16-bit Format I instructions execute until Phase 2 lands 32-bit
  instruction handling.
- Placeholder opcodes mean the core cannot yet run MAME-generated traces.
  Verification-of-opcodes is a blocker on leaving Phase 2.
