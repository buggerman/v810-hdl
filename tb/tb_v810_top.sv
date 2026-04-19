// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// Top-level integration testbench for the V810 Phase 1 CPU.
//
// This test deliberately avoids any hierarchical-reference preload of the
// DUT's register file. All initial values are constructed by the program
// itself: NOT r0 gives ~0 = 0xFFFFFFFF in any destination register, which
// seeds enough state for meaningful end-state checks.
//
// Program:
//   PC=0:  NOT r0, r1    ; r1 <- ~0        = 0xFFFFFFFF
//   PC=2:  MOV r1, r2    ; r2 <- r1        = 0xFFFFFFFF
//   PC=4:  ADD r1, r2    ; r2 <- r2 + r1   = 0xFFFFFFFE
//   PC=6:  NOP           ; MOV r0, r0      (opcode 0, reg2=0, reg1=0)

`timescale 1ns/1ps

module tb_v810_top;
  import v810_pkg::*;

  logic clk   = 1'b0;
  logic rst_n = 1'b0;
  always #5 clk <= ~clk;

  logic [XLEN-1:0] imem [0:255];

  logic [ALEN-1:0] imem_addr;
  logic            imem_req;
  logic [XLEN-1:0] imem_rdata;

  logic [ALEN-1:0] dmem_addr;
  logic [XLEN-1:0] dmem_wdata;
  logic [XLEN-1:0] dmem_rdata = '0;
  logic            dmem_req;
  logic            dmem_we;
  logic            dmem_ack  = 1'b0;
  logic [3:0]      dmem_be;

  logic [4:0]      int_level = '0;
  logic            nmi       = 1'b0;
  logic            halted;

  assign imem_rdata = imem[imem_addr[9:2]];

  v810 dut (
    .clk        (clk),
    .rst_n      (rst_n),
    .reset_pc   (32'h0000_0000),
    .imem_addr  (imem_addr),
    .imem_req   (imem_req),
    .imem_rdata (imem_rdata),
    .imem_ack   (1'b1),
    .dmem_addr  (dmem_addr),
    .dmem_req   (dmem_req),
    .dmem_we    (dmem_we),
    .dmem_be    (dmem_be),
    .dmem_wdata (dmem_wdata),
    .dmem_rdata (dmem_rdata),
    .dmem_ack   (dmem_ack),
    .int_level  (int_level),
    .nmi        (nmi),
    .halted     (halted)
  );

  // Opcode values must match rtl/v810_decoder.sv placeholders.
  localparam logic [5:0] OP_MOV_REG = 6'b000000;
  localparam logic [5:0] OP_ADD_REG = 6'b000001;
  localparam logic [5:0] OP_NOT_REG = 6'b001111;

  function automatic logic [15:0] fmt1(input logic [5:0] op,
                                       input logic [4:0] reg2,
                                       input logic [4:0] reg1);
    return {op, reg2, reg1};
  endfunction

  function automatic logic [XLEN-1:0] reg_peek(input int idx);
    return dut.u_regs.regs[idx];
  endfunction

  int errors = 0;

  task automatic check(input string name,
                       input logic [XLEN-1:0] got,
                       input logic [XLEN-1:0] expected);
    if (got !== expected) begin
      $display("FAIL %-26s  got %08h  expected %08h", name, got, expected);
      errors++;
    end else begin
      $display("PASS %-26s  %08h", name, got);
    end
  endtask

  initial begin
    // Zero-fill the instruction ROM (zero == MOV r0, r0 == NOP)
    for (int i = 0; i < 256; i++) imem[i] = 32'h0000_0000;

    // Word 0: low half = PC 0 (NOT r0,r1), high half = PC 2 (MOV r1,r2)
    imem[0] = {fmt1(OP_MOV_REG, 5'd2, 5'd1),
               fmt1(OP_NOT_REG, 5'd1, 5'd0)};

    // Word 1: low half = PC 4 (ADD r1,r2), high half = PC 6 (NOP)
    imem[1] = {16'h0000,
               fmt1(OP_ADD_REG, 5'd2, 5'd1)};

    // Release reset
    #20 rst_n = 1'b1;

    // Let the CPU execute at least four instructions with slack
    repeat (8) @(posedge clk);

    check("r0 hardwired zero",    reg_peek(0), 32'h0000_0000);
    check("r1 after NOT r0",      reg_peek(1), 32'hFFFF_FFFF);
    check("r2 after ADD r1 (ov)", reg_peek(2), 32'hFFFF_FFFE);

    if (errors == 0) begin
      $display("ALL TOP-LEVEL INTEGRATION TESTS PASSED");
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

endmodule : tb_v810_top
