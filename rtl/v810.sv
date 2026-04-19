// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 CPU top-level module (Phase 1 single-cycle, Format I only).
//
// One instruction retires per clock. Combinational path each cycle:
//   fetch -> decode -> regfile-read -> ALU -> writeback
// Synchronous at posedge clk: regfile write + PC advance.
//
// Data-memory and interrupt paths are stubbed until Phase 2 / Phase 4.

module v810
  import v810_pkg::*;
(
  input  logic              clk,
  input  logic              rst_n,
  input  logic [ALEN-1:0]   reset_pc,

  // Instruction memory port
  output logic [ALEN-1:0]   imem_addr,
  output logic              imem_req,
  input  logic [XLEN-1:0]   imem_rdata,
  input  logic              imem_ack,

  // Data memory port (stubbed)
  output logic [ALEN-1:0]   dmem_addr,
  output logic              dmem_req,
  output logic              dmem_we,
  output logic [3:0]        dmem_be,
  output logic [XLEN-1:0]   dmem_wdata,
  input  logic [XLEN-1:0]   dmem_rdata,
  input  logic              dmem_ack,

  // Interrupts (stubbed)
  input  logic [4:0]        int_level,
  input  logic              nmi,

  // Status
  output logic              halted
);

  // -------- Fetch --------
  logic [ALEN-1:0] pc;
  logic [15:0]     instr_halfword;
  logic            fetch_advance;
  logic [2:0]      fetch_advance_by;
  logic            fetch_branch;
  logic [ALEN-1:0] fetch_branch_target;

  v810_fetch u_fetch (
    .clk            (clk),
    .rst_n          (rst_n),
    .reset_pc       (reset_pc),
    .imem_addr      (imem_addr),
    .imem_req       (imem_req),
    .imem_rdata     (imem_rdata),
    .imem_ack       (imem_ack),
    .pc             (pc),
    .instr_halfword (instr_halfword),
    .advance        (fetch_advance),
    .advance_by     (fetch_advance_by),
    .branch         (fetch_branch),
    .branch_target  (fetch_branch_target)
  );

  // -------- Decode --------
  logic               dec_valid;
  fmt_e               dec_fmt;
  alu_op_e            dec_alu_op;
  logic [GPR_IDX-1:0] dec_rs_a_addr;
  logic [GPR_IDX-1:0] dec_rs_b_addr;
  logic [GPR_IDX-1:0] dec_rd_addr;
  logic               dec_rd_we;
  logic [2:0]         dec_instr_len;

  v810_decoder u_decode (
    .instr_halfword (instr_halfword),
    .valid          (dec_valid),
    .fmt            (dec_fmt),
    .alu_op         (dec_alu_op),
    .rs_a_addr      (dec_rs_a_addr),
    .rs_b_addr      (dec_rs_b_addr),
    .rd_addr        (dec_rd_addr),
    .rd_we          (dec_rd_we),
    .instr_len      (dec_instr_len)
  );

  // -------- Register file --------
  logic [XLEN-1:0] rs_a_data;
  logic [XLEN-1:0] rs_b_data;

  register_file u_regs (
    .clk     (clk),
    .rst_n   (rst_n),
    .ra_addr (dec_rs_a_addr),
    .ra_data (rs_a_data),
    .rb_addr (dec_rs_b_addr),
    .rb_data (rs_b_data),
    .we      (dec_valid & dec_rd_we),
    .wa_addr (dec_rd_addr),
    .wa_data (alu_result)
  );

  // -------- ALU --------
  logic [XLEN-1:0] alu_result;
  logic            alu_flag_z;
  logic            alu_flag_s;
  logic            alu_flag_ov;
  logic            alu_flag_cy;

  v810_alu u_alu (
    .op      (dec_alu_op),
    .a       (rs_a_data),
    .b       (rs_b_data),
    .result  (alu_result),
    .flag_z  (alu_flag_z),
    .flag_s  (alu_flag_s),
    .flag_ov (alu_flag_ov),
    .flag_cy (alu_flag_cy)
  );

  // -------- PC control --------
  // Phase 1: advance on every valid instruction; no branches yet.
  assign fetch_advance        = dec_valid;
  assign fetch_advance_by     = dec_instr_len;
  assign fetch_branch         = 1'b0;
  assign fetch_branch_target  = '0;

  // -------- Stubs for unused ports --------
  assign dmem_addr  = '0;
  assign dmem_req   = 1'b0;
  assign dmem_we    = 1'b0;
  assign dmem_be    = 4'b0000;
  assign dmem_wdata = '0;

  assign halted = ~dec_valid;

  // Silence Verilator for Phase 1-unused signals
  wire _unused_ok = &{1'b0,
                      dmem_rdata, dmem_ack,
                      int_level,  nmi,
                      alu_flag_z, alu_flag_s, alu_flag_ov, alu_flag_cy,
                      dec_fmt,
                      pc,
                      1'b0};

endmodule : v810
