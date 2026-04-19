// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 instruction decoder (Phase 1 baseline).
//
// Scope: Format I register-register arithmetic, logical, shift, and move ops.
//
// WARNING: OPCODE HEX VALUES ARE PLACEHOLDERS. See file header prose in the
// previous revision and docs/ISA.md verification checklist.

`timescale 1ns/1ps

module v810_decoder
  import v810_pkg::*;
(
  input  logic [15:0]        instr_halfword,

  output logic               valid,
  output fmt_e               fmt,
  output alu_op_e            alu_op,
  output logic [GPR_IDX-1:0] rs_a_addr,
  output logic [GPR_IDX-1:0] rs_b_addr,
  output logic [GPR_IDX-1:0] rd_addr,
  output logic               rd_we,
  output logic [2:0]         instr_len
);

  localparam logic [5:0] OP_MOV_REG = 6'b000000;
  localparam logic [5:0] OP_ADD_REG = 6'b000001;
  localparam logic [5:0] OP_SUB_REG = 6'b000010;
  localparam logic [5:0] OP_CMP_REG = 6'b000011;
  localparam logic [5:0] OP_SHL_REG = 6'b000100;
  localparam logic [5:0] OP_SHR_REG = 6'b000101;
  localparam logic [5:0] OP_SAR_REG = 6'b000111;
  localparam logic [5:0] OP_OR_REG  = 6'b001100;
  localparam logic [5:0] OP_AND_REG = 6'b001101;
  localparam logic [5:0] OP_XOR_REG = 6'b001110;
  localparam logic [5:0] OP_NOT_REG = 6'b001111;

  logic [5:0] opcode;
  logic [4:0] reg2_field;
  logic [4:0] reg1_field;

  assign opcode     = instr_halfword[15:10];
  assign reg2_field = instr_halfword[9:5];
  assign reg1_field = instr_halfword[4:0];

  always_comb begin
    valid     = 1'b1;
    fmt       = FMT_I;
    alu_op    = ALU_ADD;
    rs_a_addr = reg2_field;
    rs_b_addr = reg1_field;
    rd_addr   = reg2_field;
    rd_we     = 1'b1;
    instr_len = 3'd2;

    unique case (opcode)
      OP_MOV_REG: alu_op = ALU_MOV;
      OP_ADD_REG: alu_op = ALU_ADD;
      OP_SUB_REG: alu_op = ALU_SUB;
      OP_CMP_REG: begin alu_op = ALU_SUB; rd_we = 1'b0; end
      OP_SHL_REG: alu_op = ALU_SHL;
      OP_SHR_REG: alu_op = ALU_SHR;
      OP_SAR_REG: alu_op = ALU_SAR;
      OP_OR_REG : alu_op = ALU_OR;
      OP_AND_REG: alu_op = ALU_AND;
      OP_XOR_REG: alu_op = ALU_XOR;
      OP_NOT_REG: alu_op = ALU_NOT;
      default: begin
        valid = 1'b0;
        rd_we = 1'b0;
      end
    endcase
  end

endmodule : v810_decoder
