# v810-hdl Roadmap

> Realistic target: **12–18 months to a verified standalone V810 core** for a dedicated developer with prior CPU HDL experience.

## Phase 0 — Specification & test harness

- [ ] Read NEC V810 user manual end-to-end, extract instruction encoding to `docs/ISA.md`
- [x] Draft `docs/ISA.md` format and verification checklist
- [ ] Build `v810-gcc` toolchain locally, confirm it produces working binaries
- [ ] Build MAME with V810 CPU enabled; confirm we can capture per-instruction-retire traces
- [ ] Write a trivial V810 C program ("hello, ADD"), run under MAME, capture golden trace
- [x] Choose license (Apache-2.0)
- [x] Set up CI skeleton (GitHub Actions running Verilator lint + testbench)

## Phase 1 — Skeleton CPU (current)

- [x] Top-level module, clock/reset, memory port stubs
- [x] Register file (32×32, r0 hardwired)
- [x] Register file testbench
- [x] Single-cycle ALU: ADD, SUB, AND, OR, XOR, NOT, SHL, SHR, SAR, MOV
- [x] ALU testbench covering flag semantics and edge cases
- [x] ADR 0001: ALU scope and MUL/DIV separation decision
- [x] Instruction fetch unit (32-bit aligned, halfword-select via `pc[1]`)
- [x] Decoder for Format I register-register instructions (placeholder opcodes)
- [x] Top-level wiring: fetch → decode → regfile → ALU → writeback
- [x] First passing end-to-end integration test (3-instruction program)
- [x] ADR 0002: single-cycle microarchitecture + aligned-fetch decision
- [ ] Second integration test covering all 10 Format I ALU ops
- [ ] Verify Format I opcode hex values against NEC manual

## Phase 2 — Full integer ISA

- [ ] 32-bit instruction fetch with halfword-boundary spanning
- [ ] Format II: imm5 instructions (incl. MOV imm5, SHL imm5, LDSR, STSR, SEI, CLI, TRAP, RETI, HALT)
- [ ] Format V: imm16 instructions (MOVEA, MOVHI, ADDI, ORI, ANDI, XORI)
- [ ] Format VI: loads/stores with displacement
- [ ] Format III: conditional branches, 16 condition codes
- [ ] Format IV: JMP/JAL
- [ ] `v810_muldiv` multi-cycle unit (separate from ALU per ADR 0001)
- [ ] Sign/zero extension correct for all widths
- [ ] PSW and condition-code flags wired to the pipeline
- [ ] Sufficient test coverage for each instruction

## Phase 3 — Pipeline

- [ ] 5-stage pipeline implementation
- [ ] Forwarding paths
- [ ] Hardware interlocks for RAW hazards
- [ ] Branch misprediction handling
- [ ] Pipeline regression tests (confirm behavior unchanged vs Phase 2)

## Phase 4 — Interrupts and system instructions

- [ ] Interrupt controller interface
- [ ] Exception vectors
- [ ] `RETI`, `TRAP`, `HALT`
- [ ] `LDSR` / `STSR` for system registers
- [ ] Privilege levels
- [ ] Bit-string instructions (multi-cycle, interruptible)

## Phase 5 — FPU

- [ ] IEEE 754 single-precision add/sub/mul/div
- [ ] Conversion instructions
- [ ] FPU exception conditions
- [ ] FPU exception interaction with interrupt model

## Phase 6 — Cycle accuracy pass

- [ ] Compare cycle counts against MAME for representative programs
- [ ] Fix discrepancies where they matter (memory access timing, FPU latencies)
- [ ] Decide on uPD70732 cache (implement or document as non-goal for v1)

## Phase 7 — Real software

- [ ] Boot Virtual Boy test ROMs
- [ ] Boot simple PC-FX homebrew
- [ ] Publish v1.0 tag

## Post-1.0

- Optional cache modes
- Optional formal verification (small-step against MAME)
- Performance/area tuning per integrator
