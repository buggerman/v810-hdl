// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// Top-level integration testbench for the V810 Phase 1 CPU.
//
// Program under test:
//
//   preload:  r1 = 10, r2 = 20
//
//   PC=0:  ADD r1, r2   ; r2 <- r2 + r1   = 30
//   PC=2:  MOV r2, r3   ; r3 <- r2        = 30
//   PC=4:  SUB r3, r4   ; r4 <- r4 - r3   = -30 (0xFFFFFFE2)
//   PC=6:  NOP          ; MOV r0, r0      (pad)
//
// The program is stored in a combinational ROM (packed two 16-bit
// instructions per 32-bit word, little-endian halfword ordering). The
// testbench preloads r1 and r2 via hierarchical reference into the DUT's
// register file — a standard debug-load trick, acceptable for Phase 1
// where Formats II/V (immediate loads) are not yet implemented.

`timescale 1ns/1ps

module tb_v810_top;
  import v810_pkg::*;

  logic clk   = 1'b0;
  logic rst_n = 1'b0;
  always #5 clk = ~clk;

  // Combinational instruction ROM, 256 x 32-bit (1 KiB code space)
  logic [XLEN-1:0] imem [0:255];

  // DUT ports
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

  // Combinational instruction-memory model.
  // imem_addr is byte address aligned to 4; index via [ALEN-1:2].
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

  // Format I halfword builder (keeps this file self-contained; opcode values
  // match rtl/v810_decoder.sv placeholders).
  localparam logic [5:0] OP_MOV_REG = 6'b000000;
  localparam logic [5:0] OP_ADD_REG = 6'b000001;
  localparam logic [5:0] OP_SUB_REG = 6'b000010;

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
      $display("FAIL %-24s  got %08h  expected %08h", name, got, expected);
      errors++;
    end else begin
      $display("PASS %-24s  %08h", name, got);
    end
  endtask

  initial begin
    // Fill memory with zeros (zero is MOV r0,r0 i.e. NOP)
    for (int i = 0; i < 256; i++) imem[i] = 32'h0000_0000;

    // Word 0: low = PC 0 (ADD r1,r2), high = PC 2 (MOV r2,r3)
    imem[0] = {fmt1(OP_MOV_REG, 5'd3, 5'd2),
               fmt1(OP_ADD_REG, 5'd2, 5'd1)};

    // Word 1: low = PC 4 (SUB r3,r4), high = PC 6 (NOP)
    imem[1] = {16'h0000,
               fmt1(OP_SUB_REG, 5'd4, 5'd3)};

    // Release reset
    #20 rst_n = 1'b1;

    // Preload register file (Phase 1 debug trick; real loads come in Phase 2)
    dut.u_regs.regs[1] = 32'd10;
    dut.u_regs.regs[2] = 32'd20;

    // Let the CPU execute at least four instructions (plus a couple of slack)
    repeat (6) @(posedge clk);

    // Verify resulting register state
    check("r1 unchanged",   reg_peek(1), 32'd10);
    check("r2 after ADD",   reg_peek(2), 32'd30);
    check("r3 after MOV",   reg_peek(3), 32'd30);
    check("r4 after SUB",   reg_peek(4), 32'hFFFF_FFE2);
    check("r0 hardwired 0", reg_peek(0), 32'd0);

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
