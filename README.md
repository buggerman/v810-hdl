# v810-hdl

**Open-source NEC V810 CPU core in SystemVerilog.**

> Status: Pre-alpha. No RTL yet. Research and specification phase.

The NEC V810 is a 32-bit RISC microprocessor from 1992 used in the NEC PC-FX, the Nintendo Virtual Boy, and several arcade boards. As of early 2026, **no open-source HDL implementation of the V810 exists anywhere**. This project aims to change that.

## Why

- **Unlocks PC-FX on MiSTer** — see the sibling [`PaCiFaX`](https://github.com/buggerman/PaCiFaX) project.
- **Unlocks Virtual Boy on MiSTer** — Virtual Boy uses a cacheless V810 and has no MiSTer core yet.
- **Unlocks V810-based arcade boards** for future FPGA preservation work.
- **Standalone value**: a verified V810 HDL core is itself a contribution to the open hardware community.

## Target

Primary synthesis target is the Intel Cyclone V (DE10-Nano) to fit the MiSTer ecosystem, but the design aims to be synthesizer-agnostic — pure SystemVerilog, no vendor-locked IP in the core itself. Memory interfaces are abstracted so integrators can wire up SDRAM, BRAM, or wishbone as needed.

## Design principles

- **SystemVerilog** (IEEE 1800). No Verilog-2001-only constructs; no VHDL.
- **No vendor IP** in the core. FIFOs, register files, ALU, FPU are portable.
- **Cycle-accurate where it matters** (pipeline hazards, interlocks, bit-string ops).
- **Test-driven.** Every feature gets a corresponding C-language test ROM compiled with [`v810-gcc`](https://github.com/jbrandwood/v810-gcc), and a testbench that compares execution traces against MAME's V810 reference.
- **Permissively licensed** under Apache-2.0 so consumers can integrate into GPL-3.0 MiSTer cores (and most other projects) without friction.

## Spec reference

- NEC V810 family user manual (`u10082ej1v0um00.pdf`, archived at virtual-boy.com) — authoritative.
- NEC uPD70732 datasheet for the PC-FX-variant silicon.
- [MAME V810 C++ emulator](https://github.com/mamedev/mame/blob/master/src/devices/cpu/v810/v810.cpp) — behavioral oracle for test comparison, GPL-2.0. Used as reference, not copied.

## Status

See [`docs/ROADMAP.md`](docs/ROADMAP.md).

Currently in **Phase 0: Specification & Test Harness Prep**.

## Getting involved

If you have HDL experience, CPU design background, or V810 reverse-engineering knowledge, open an issue. Specific skills useful right now:

- SystemVerilog CPU design
- Verilator / iverilog testbench authoring
- FPU design (IEEE 754 single-precision, V810 subset)
- V810 toolchain / homebrew experience (for writing tests)

All contributions are accepted under Apache-2.0 per the [`LICENSE`](LICENSE) file. By submitting a pull request, you agree your contribution is licensed accordingly (see section 5 of the license).

## License

Apache License 2.0. See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).

The Apache-2.0 license grants a patent license from contributors and includes patent retaliation — standard practice for open silicon IP (RISC-V cores, OpenTitan, lowRISC, etc.).
