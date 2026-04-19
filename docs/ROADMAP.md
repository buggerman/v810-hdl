# v810-hdl Roadmap

> Realistic target: **12–18 months to a verified standalone V810 core** for a dedicated developer with prior CPU HDL experience.

## Phase 0 — Specification & test harness

**Goal**: know exactly what we're building and be able to run test ROMs before writing RTL.

- [ ] Read NEC V810 user manual end-to-end, extract instruction encoding to `docs/ISA.md`
- [x] Draft `docs/ISA.md` format and verification checklist (values pending manual verification)
- [ ] Build `v810-gcc` toolchain locally, confirm it produces working binaries
- [ ] Build MAME with V810 CPU enabled; confirm we can capture per-instruction-retire traces
- [ ] Write a trivial V810 C program ("hello, ADD"), run under MAME, capture golden trace
- [x] Choose license (Apache-2.0)
- [x] Set up CI skeleton (GitHub Actions running Verilator lint + testbench)

## Phase 1 — Skeleton CPU (current)

**Goal**: register file, fetch/decode, simplest ALU instructions running.

- [x] Top-level module, clock/reset, memory port stubs (`rtl/v810.sv`)
- [x] Register file (32×32, r0 hardwired) (`rtl/register_file.sv`)
- [x] Register file testbench (`tb/tb_register_file.sv`)
- [x] Single-cycle ALU: ADD, SUB, AND, OR, XOR, NOT, SHL, SHR, SAR, MOV (`rtl/v810_alu.sv`)
- [x] ALU testbench covering flag semantics and edge cases (`tb/tb_v810_alu.sv`)
- [x] ADR 0001: ALU scope and MUL/DIV separation decision
- [ ] Instruction fetch (no pipeline yet)
- [ ] Decoder for Format I register-register instructions
- [ ] First passing end-to-end instruction trace (fetch → decode → execute → writeback)

## Phase 2 — Full integer ISA

- [ ] All loads/stores with displacement (Format VI)
- [ ] All branches + condition codes (Format III, IV)
- [ ] Immediate-form instructions (Format II, V)
- [ ] Sign/zero extension correct for all widths
- [ ] PSW and condition-code flags wired to the pipeline
- [ ] `v810_muldiv` multi-cycle unit (separate from ALU per ADR 0001)
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
