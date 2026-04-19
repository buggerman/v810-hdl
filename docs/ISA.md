# V810 Instruction Set Reference

> **Status**: draft, pending verification against the authoritative NEC V810 Family User Manual (`u10082ej1v0um00.pdf`). Anything in this document should be treated as a working hypothesis until a specific opcode encoding has been checked against the manual. The verification checklist at the bottom tracks open items.
>
> **Current placeholder opcodes** live in `rtl/v810_decoder.sv` as `localparam`s prefixed `OP_*_REG`. They are internally consistent with `tb/tb_v810_top.sv`, so the Phase 1 integration test is correct by construction. Real V810 binaries will require each value to be reconciled with the manual.

## Overview

The V810 is a 32-bit RISC ISA with seven instruction formats, a fixed 32-entry register file, and a flat linear address space. Instructions are either 16-bit or 32-bit wide and are naturally aligned. Little-endian byte ordering.

## Register model

### General-purpose registers (32 x 32-bit)

| Register | Role | Notes |
|---|---|---|
| r0 | zero | hardwired, writes discarded |
| r1–r25 | general-purpose | software calling convention per v810-gcc |
| r26–r29 | bit-string working registers | used implicitly by bit-string ops; must be saved on interrupt mid-instruction |
| r30 | link | by v810-gcc convention |
| r31 | stack pointer | by v810-gcc convention |

### System registers

Accessed via `LDSR` / `STSR`. Architectural slots include (full map to be verified):

- EIPC / EIPSW — exception PC + PSW snapshot
- FEPC / FEPSW — fatal-error PC + PSW snapshot
- PSW — program status word
- ECR — exception cause register
- PIR — processor ID
- TKCW — task control word
- CHCW — cache control word (uPD70732 only)
- ADTRE — address trap register

## Program Status Word (PSW)

Flag bit positions to be validated against manual. Expected set:

- **Z** — zero
- **S** — sign
- **OV** — overflow
- **CY** — carry
- **ID** — interrupt disable
- **EP** — exception pending
- **NP** — NMI pending
- **AE** — address trap enable (if present)
- **FPR×** — FPU exception flag group (INV, DIV0, OVF, UDF, INX, RSV)

## Instruction formats

### Format I — reg/reg, 16 bits

```
| 6 bits | 5 bits | 5 bits |
| opcode |  reg2  |  reg1  |
```

Arithmetic / logical / data-movement register-register operations (MOV, ADD, SUB, CMP, OR, AND, XOR, NOT, MUL, MULU, DIV, DIVU, SHL, SHR, SAR, JMP-via-register, …). Semantic: "OP reg1, reg2" means `reg2 <- f(reg2, reg1)`.

### Format II — imm5/reg, 16 bits

```
| 6 bits | 5 bits | 5 bits |
| opcode |  reg2  |  imm5  |
```

Small-immediate forms plus several degenerate encodings used for system control: MOV imm5, ADD imm5, CMP imm5, SHL imm5, SHR imm5, SAR imm5, LDSR, STSR, SEI, CLI, TRAP, RETI, HALT.

### Format III — conditional branch, 16 bits

```
| 3 bits | 4 bits | 9 bits       |
| opcode |  cond  | disp9 (ldw1) |
```

16 condition codes × PC-relative 9-bit displacement, sign-extended and left-shifted by 1 (targets aligned to 16-bit boundaries). Covers BEQ, BNE, BC, BNC, BN, BP, BLT, BGE, BLE, BGT, BR, BV, BNV, … and BH, BNH.

### Format IV — unconditional, 32 bits

```
| 6 bits | 26 bits       |
| opcode | disp26 (ldw1) |
```

JMP, JAL. Displacement is PC-relative, sign-extended, left-shifted by 1.

### Format V — imm16/reg, 32 bits

```
| 6 bits | 5 bits | 5 bits | 16 bits |
| opcode |  reg2  |  reg1  |  imm16  |
```

MOVEA, MOVHI, ADDI, ORI, ANDI, XORI. reg1 is source, reg2 is destination.

### Format VI — load/store displacement, 32 bits

```
| 6 bits | 5 bits | 5 bits | 16 bits |
| opcode |  reg2  |  reg1  |  disp16 |
```

- Loads: LD.B, LD.H, LD.W (reg2 = dest, reg1 = base, disp16 sign-extended)
- Stores: ST.B, ST.H, ST.W (reg2 = data source)
- Optional I/O: IN.B, IN.H, IN.W, OUT.B, OUT.H, OUT.W (PC-FX uses memory-mapped I/O — verify relevance)

### Format VII — FPU / extended, 32 bits

```
| 6 bits | 5 bits | 5 bits | 6 bits      | 10 bits |
| opcode |  reg2  |  reg1  | sub-opcode  |  rsvd   |
```

- **FPU** (IEEE 754 single-precision): ADDF.S, SUBF.S, MULF.S, DIVF.S, CMPF.S, CVT.WS, CVT.SW, TRNC.SW
- **Bit-string** (multi-cycle, interruptible, use r26–r29 implicitly): SCH0BSU, SCH0BSD, SCH1BSU, SCH1BSD, ORBSU, ANDBSU, XORBSU, MOVBSU, NOTBSU, ANDNBSU, ORNBSU, XORNBSU
- Other extended ops (`CAXI` compare-and-exchange, if encoded here)

## Instruction inventory (logical)

### Arithmetic
MOV, MOVEA, MOVHI, ADD, ADDI, SUB, CMP, MUL, MULU, DIV, DIVU.

### Logical
AND, ANDI, OR, ORI, XOR, XORI, NOT.

### Shift
SHL, SHR, SAR (each in reg-reg and imm5 forms).

### Load / Store
LD.B, LD.H, LD.W, ST.B, ST.H, ST.W.

### Branch / Jump
BCOND × 16, JMP, JR, JAL, JALR.

### Bit-string (multi-cycle, interruptible)
SCH0BSU, SCH0BSD, SCH1BSU, SCH1BSD, ORBSU, ANDBSU, XORBSU, MOVBSU, NOTBSU, ANDNBSU, ORNBSU, XORNBSU.

### FPU (IEEE 754 single)
ADDF.S, SUBF.S, MULF.S, DIVF.S, CMPF.S, CVT.WS, CVT.SW, TRNC.SW.

### System / Control
LDSR, STSR, RETI, TRAP, HALT, SEI, CLI, CAXI.

## Verification checklist

Items below must be verified against the NEC manual before the decoder is considered trustworthy. Each item becomes a GitHub issue with label `isa-verify`.

- [ ] Exact opcode hex values for every Format I, II, III, IV, V, VI, VII instruction (**currently placeholders in `rtl/v810_decoder.sv`**)
- [ ] Exact bit width and position of Format VII sub-opcode
- [ ] PSW bit positions (Z, S, OV, CY, ID, EP, NP, AE)
- [ ] FPU exception flag encoding and interaction with PSW
- [ ] Bit-string instruction save-on-interrupt semantics (which register slots are preserved, which are clobbered)
- [ ] `CAXI` atomicity semantics
- [ ] IN/OUT relevance on V810 (some sources say these are V60-family only)
- [ ] System register index assignments (which SR index maps to which arch register)
- [ ] `SUBR` presence (may not exist; some sources list it only for V60)
- [ ] Branch target alignment and exception on misalignment
- [ ] Exception vector addresses
- [ ] Cache control behavior on uPD70732 variant (deferred; not in v1 scope)
- [ ] SUB carry/borrow polarity (current implementation assumes CY=1 on borrow; see ADR 0001)

Source of truth: NEC V810 Family User Manual (`u10082ej1v0um00.pdf`). All uncertainty in this document resolves against that document.
