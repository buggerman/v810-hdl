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
  // Used by the decoder as an intermediate classification between raw opcode
  // and specific operation. Values are internal to this core only.
  typedef enum logic [2:0] {
    FMT_I   = 3'd0,  // reg/reg,         16-bit
    FMT_II  = 3'd1,  // imm5/reg,        16-bit
    FMT_III = 3'd2,  // conditional br,  16-bit
    FMT_IV  = 3'd3,  // JMP/JAL,         32-bit
    FMT_V   = 3'd4,  // imm16/reg,       32-bit
    FMT_VI  = 3'd5,  // ld/st + disp16,  32-bit
    FMT_VII = 3'd6   // FPU / extended,  32-bit
  } fmt_e;

  // PSW flag bit positions. Exact positions to be verified against NEC manual;
  // these parameters exist so that downstream code references symbols rather
  // than magic numbers and can be corrected in one place.
  localparam int PSW_Z  = 0;   // zero
  localparam int PSW_S  = 1;   // sign
  localparam int PSW_OV = 2;   // overflow
  localparam int PSW_CY = 3;   // carry
  localparam int PSW_ID = 12;  // interrupt disable  (TODO: verify)
  localparam int PSW_EP = 14;  // exception pending  (TODO: verify)
  localparam int PSW_NP = 15;  // NMI pending        (TODO: verify)

endpackage : v810_pkg
