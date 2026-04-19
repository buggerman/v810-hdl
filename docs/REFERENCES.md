# V810 reference material

This is the curated reading list. See also [`PaCiFaX/docs/RESEARCH-V810.md`](https://github.com/buggerman/PaCiFaX/blob/main/docs/RESEARCH-V810.md) for the fuller research note.

## Primary specification (authoritative)

- **NEC V810 Family 32-bit Microprocessor user manual** — `u10082ej1v0um00.pdf` (1995). The NEC original. Archived at `files.virtual-boy.com/download/978644/`.
- **NEC uPD70732 datasheet** — the V810 variant used in PC-FX. Covers electrical and timing specifics.

## Behavioral reference emulators (C++)

Treat as oracles for validation. Do **not** copy code into HDL.

- **MAME V810** — `src/devices/cpu/v810/v810.cpp` in [mamedev/mame](https://github.com/mamedev/mame). GPL-2.0. Most widely-validated open implementation.
- **Mednafen PC-FX V810** — integrated into Mednafen. GPL-2.0+. Validated against extensive PC-FX software.

## Toolchain

- **[jbrandwood/v810-gcc](https://github.com/jbrandwood/v810-gcc)** — GCC 4 toolchain patches for V810. Produces working binaries usable for test ROMs.
- **[20Enderdude20/Ghidra_v810_v830](https://github.com/20Enderdude20/Ghidra_v810_v830)** — Ghidra processor module for disassembly and reverse engineering.

## Accessible secondary references

- **[Virtual Boy Architecture](https://www.copetti.org/writings/consoles/virtual-boy/)** (Rodrigo Copetti) — clear prose explanation of the V810 pipeline and its implications.
- **[Planet Virtual Boy](https://www.planetvb.com/)** wiki — homebrew-community-maintained V810 notes and test programs.

## Sibling projects

- **[PaCiFaX](https://github.com/buggerman/PaCiFaX)** — first integrator of this core; PC-FX on MiSTer.
