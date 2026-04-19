// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 architectural constants, types, and enumerations shared across the core.
// Opcode values are intentionally NOT declared here yet — they will be added
// in a dedicated `v810_isa_pkg` once docs/ISA.md verification items are cleared.

package v810_pkg;

  // Architectural widths
  localparam int XLEN    = 32;               // register and data-path width
  localparam int ALEN    = 32;               // address-bus width
  localparam int NGPR    = 32;               // number of general-purpose registers
  localparam int GPR_IDX = $clog2(NGPR);     // 5 bits
  localparam int NSR     = 32;               // number of system registers (tentative)
  localparam int SR_IDX  = $clog2(NSR);      // 5 bits

  // Instruction format categories per NEC V810 family manual.
  typedef enum logic [2:0] {
    FMT_I   = 3'd0,  // reg/reg,         16-bit
    FMT_II  = 3'd1,  // imm5/reg,        16-bit
    FMT_III = 3'd2,  // conditional br,  16-bit
    FMT_IV  = 3'd3,  // JMP/JAL,         32-bit
    FMT_V   = 3'd4,  // imm16/reg,       32-bit
    FMT_VI  = 3'd5,  // ld/st + disp16,  32-bit
    FMT_VII = 3'd6   // FPU / extended,  32-bit
  } fmt_e;

  // PSW flag bit positions (to be verified against NEC manual).
  localparam int PSW_Z  = 0;   // zero
  localparam int PSW_S  = 1;   // sign
  localparam int PSW_OV = 2;   // overflow
  localparam int PSW_CY = 3;   // carry
  localparam int PSW_ID = 12;  // interrupt disable  (TODO: verify)
  localparam int PSW_EP = 14;  // exception pending  (TODO: verify)
  localparam int PSW_NP = 15;  // NMI pending        (TODO: verify)

  // ALU operation selector. Internal to the core; the decoder maps from
  // instruction opcodes to these values. See docs/adr/0001-alu-design.md.
  typedef enum logic [3:0] {
    ALU_ADD = 4'd0,  // result = a + b
    ALU_SUB = 4'd1,  // result = a - b  (also used for CMP; writeback suppressed)
    ALU_AND = 4'd2,  // result = a & b
    ALU_OR  = 4'd3,  // result = a | b
    ALU_XOR = 4'd4,  // result = a ^ b
    ALU_NOT = 4'd5,  // result = ~b  (unary)
    ALU_SHL = 4'd6,  // result = a << b[4:0]
    ALU_SHR = 4'd7,  // result = a >> b[4:0]  (logical)
    ALU_SAR = 4'd8,  // result = $signed(a) >>> b[4:0]  (arithmetic)
    ALU_MOV = 4'd9   // result = b  (passthrough for register moves)
  } alu_op_e;

endpackage : v810_pkg
