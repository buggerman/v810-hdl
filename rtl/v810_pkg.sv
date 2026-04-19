// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 architectural constants, types, and enumerations shared across the core.
// Opcode values are intentionally NOT declared here yet — they will be added
// in a dedicated `v810_isa_pkg` once docs/ISA.md verification items are cleared.

`timescale 1ns/1ps

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
  localparam int PSW_Z  = 0;
  localparam int PSW_S  = 1;
  localparam int PSW_OV = 2;
  localparam int PSW_CY = 3;
  localparam int PSW_ID = 12;
  localparam int PSW_EP = 14;
  localparam int PSW_NP = 15;

  // ALU operation selector. Internal to the core; the decoder maps from
  // instruction opcodes to these values. See docs/adr/0001-alu-design.md.
  typedef enum logic [3:0] {
    ALU_ADD = 4'd0,
    ALU_SUB = 4'd1,
    ALU_AND = 4'd2,
    ALU_OR  = 4'd3,
    ALU_XOR = 4'd4,
    ALU_NOT = 4'd5,
    ALU_SHL = 4'd6,
    ALU_SHR = 4'd7,
    ALU_SAR = 4'd8,
    ALU_MOV = 4'd9
  } alu_op_e;

endpackage : v810_pkg
