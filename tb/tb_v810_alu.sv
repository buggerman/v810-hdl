// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// Testbench for v810_alu.
//
// Covers arithmetic, logical, shift, and move operations, with explicit
// checks for zero/sign/overflow/carry flag semantics and edge cases
// (signed overflow, unsigned carry, shift masking to 5 bits).

`timescale 1ns/1ps

module tb_v810_alu;
  import v810_pkg::*;

  alu_op_e         op;
  logic [XLEN-1:0] a;
  logic [XLEN-1:0] b;
  logic [XLEN-1:0] result;
  logic            flag_z;
  logic            flag_s;
  logic            flag_ov;
  logic            flag_cy;

  v810_alu dut (
    .op      (op),
    .a       (a),
    .b       (b),
    .result  (result),
    .flag_z  (flag_z),
    .flag_s  (flag_s),
    .flag_ov (flag_ov),
    .flag_cy (flag_cy)
  );

  int errors = 0;

  task automatic check(string              name,
                       logic [XLEN-1:0]    exp_r,
                       logic               exp_z,
                       logic               exp_s,
                       logic               exp_ov,
                       logic               exp_cy);
    logic ok;
    ok = (result  === exp_r)  &&
         (flag_z  === exp_z)  &&
         (flag_s  === exp_s)  &&
         (flag_ov === exp_ov) &&
         (flag_cy === exp_cy);
    if (ok) begin
      $display("PASS %-34s  r=%08h z=%b s=%b ov=%b cy=%b",
               name, result, flag_z, flag_s, flag_ov, flag_cy);
    end else begin
      $display("FAIL %-34s  got r=%08h z=%b s=%b ov=%b cy=%b   exp r=%08h z=%b s=%b ov=%b cy=%b",
               name,
               result, flag_z, flag_s, flag_ov, flag_cy,
               exp_r,  exp_z,  exp_s,  exp_ov,  exp_cy);
      errors++;
    end
  endtask

  initial begin
    // --- ADD ---
    op = ALU_ADD; a = 32'd1;           b = 32'd1;           #1;
    check("ADD 1+1",                   32'd2,           0, 0, 0, 0);

    op = ALU_ADD; a = 32'h7FFF_FFFF;   b = 32'd1;           #1;
    check("ADD MAXPOS+1 signed OV",    32'h8000_0000,   0, 1, 1, 0);

    op = ALU_ADD; a = 32'hFFFF_FFFF;   b = 32'd1;           #1;
    check("ADD -1+1 carry, zero",      32'h0000_0000,   1, 0, 0, 1);

    op = ALU_ADD; a = 32'h8000_0000;   b = 32'h8000_0000;   #1;
    check("ADD MINNEG+MINNEG",         32'h0000_0000,   1, 0, 1, 1);

    // --- SUB ---
    op = ALU_SUB; a = 32'd5;           b = 32'd3;           #1;
    check("SUB 5-3",                   32'd2,           0, 0, 0, 0);

    op = ALU_SUB; a = 32'd3;           b = 32'd5;           #1;
    check("SUB 3-5 borrow",            32'hFFFF_FFFE,   0, 1, 0, 1);

    op = ALU_SUB; a = 32'd5;           b = 32'd5;           #1;
    check("SUB 5-5 zero",              32'd0,           1, 0, 0, 0);

    op = ALU_SUB; a = 32'h8000_0000;   b = 32'd1;           #1;
    check("SUB MINNEG-1 signed OV",    32'h7FFF_FFFF,   0, 0, 1, 0);

    // --- AND / OR / XOR / NOT ---
    op = ALU_AND; a = 32'hFF00_FF00;   b = 32'h0F0F_0F0F;   #1;
    check("AND",                       32'h0F00_0F00,   0, 0, 0, 0);

    op = ALU_OR;  a = 32'hFF00_0000;   b = 32'h0000_00FF;   #1;
    check("OR",                        32'hFF00_00FF,   0, 1, 0, 0);

    op = ALU_XOR; a = 32'hAAAA_AAAA;   b = 32'hFFFF_FFFF;   #1;
    check("XOR",                       32'h5555_5555,   0, 0, 0, 0);

    op = ALU_NOT; a = 32'd0;           b = 32'h0000_FFFF;   #1;
    check("NOT",                       32'hFFFF_0000,   0, 1, 0, 0);

    // --- Shifts ---
    op = ALU_SHL; a = 32'h0000_0001;   b = 32'd4;           #1;
    check("SHL by 4",                  32'h0000_0010,   0, 0, 0, 0);

    op = ALU_SHL; a = 32'h0000_0001;   b = 32'd31;          #1;
    check("SHL by 31",                 32'h8000_0000,   0, 1, 0, 0);

    op = ALU_SHR; a = 32'h8000_0000;   b = 32'd4;           #1;
    check("SHR logical",               32'h0800_0000,   0, 0, 0, 0);

    op = ALU_SAR; a = 32'h8000_0000;   b = 32'd4;           #1;
    check("SAR arithmetic",            32'hF800_0000,   0, 1, 0, 0);

    op = ALU_SAR; a = 32'hFFFF_FFFF;   b = 32'd8;           #1;
    check("SAR all-ones preserved",    32'hFFFF_FFFF,   0, 1, 0, 0);

    // Shift amount must be masked to 5 bits: 0x24 = 36 -> 4
    op = ALU_SHL; a = 32'h0000_0001;   b = 32'h0000_0024;   #1;
    check("SHL masks to 5 bits",       32'h0000_0010,   0, 0, 0, 0);

    // --- MOV ---
    op = ALU_MOV; a = 32'hDEAD_BEEF;   b = 32'h1234_5678;   #1;
    check("MOV passes b",              32'h1234_5678,   0, 0, 0, 0);

    op = ALU_MOV; a = 32'hFFFF_FFFF;   b = 32'd0;           #1;
    check("MOV zero sets Z",           32'd0,           1, 0, 0, 0);

    if (errors == 0) begin
      $display("ALL ALU TESTS PASSED");
      $finish;
    end else begin
      $display("FAILED: %0d error(s)", errors);
      $fatal(1);
    end
  end

  initial begin
    #10_000;
    $display("TIMEOUT");
    $fatal(1);
  end

endmodule : tb_v810_alu
