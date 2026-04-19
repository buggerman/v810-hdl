// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 instruction fetch unit (Phase 1 baseline).
// See docs/adr/0002-single-cycle-phase1.md.

`timescale 1ns/1ps

module v810_fetch
  import v810_pkg::*;
(
  input  logic              clk,
  input  logic              rst_n,
  input  logic [ALEN-1:0]   reset_pc,

  // Instruction memory port (32-bit wide, 4-byte aligned)
  output logic [ALEN-1:0]   imem_addr,
  output logic              imem_req,
  input  logic [XLEN-1:0]   imem_rdata,
  input  logic              imem_ack,

  // Decoder interface
  output logic [ALEN-1:0]   pc,
  output logic [15:0]       instr_halfword,

  // Commit / redirect from execute stage
  input  logic              advance,
  input  logic [2:0]        advance_by,
  input  logic              branch,
  input  logic [ALEN-1:0]   branch_target
);

  logic [ALEN-1:0] pc_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_q <= reset_pc;
    end else if (branch) begin
      pc_q <= branch_target;
    end else if (advance) begin
      pc_q <= pc_q + {{(ALEN-3){1'b0}}, advance_by};
    end
  end

  assign pc        = pc_q;
  assign imem_addr = {pc_q[ALEN-1:2], 2'b00};
  assign imem_req  = 1'b1;

  assign instr_halfword = pc_q[1] ? imem_rdata[31:16] : imem_rdata[15:0];

  wire _unused_ok = &{1'b0, imem_ack, 1'b0};

endmodule : v810_fetch
