// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// Testbench for register_file.
//
// Covers:
//   - Basic write-then-read round trip
//   - r0 write-discard semantics (writes to r0 must not change observable state)
//   - Independent operation of both read ports

`timescale 1ns/1ps

module tb_register_file;
  import v810_pkg::*;

  logic clk   = 1'b0;
  logic rst_n = 1'b0;
  always #5 clk = ~clk;

  logic [GPR_IDX-1:0] ra_addr = '0;
  logic [GPR_IDX-1:0] rb_addr = '0;
  logic [GPR_IDX-1:0] wa_addr = '0;
  logic [XLEN-1:0]    ra_data;
  logic [XLEN-1:0]    rb_data;
  logic [XLEN-1:0]    wa_data = '0;
  logic               we      = 1'b0;

  register_file dut (
    .clk     (clk),
    .rst_n   (rst_n),
    .ra_addr (ra_addr),
    .ra_data (ra_data),
    .rb_addr (rb_addr),
    .rb_data (rb_data),
    .we      (we),
    .wa_addr (wa_addr),
    .wa_data (wa_data)
  );

  int errors = 0;

  task automatic check(string name,
                       logic [XLEN-1:0] got,
                       logic [XLEN-1:0] expected);
    if (got !== expected) begin
      $display("FAIL %s: got %08h, expected %08h", name, got, expected);
      errors++;
    end else begin
      $display("PASS %s: %08h", name, got);
    end
  endtask

  initial begin
    // Release reset after a couple of cycles
    repeat (2) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    // 1. Write 0xDEADBEEF to r5 then read it back on port A
    we      = 1'b1;
    wa_addr = 5'd5;
    wa_data = 32'hDEAD_BEEF;
    @(negedge clk);
    we      = 1'b0;

    ra_addr = 5'd5;
    @(negedge clk);
    check("r5 round-trip", ra_data, 32'hDEAD_BEEF);

    // 2. Attempt to write 0xFFFFFFFF to r0; r0 must still read zero
    we      = 1'b1;
    wa_addr = 5'd0;
    wa_data = 32'hFFFF_FFFF;
    @(negedge clk);
    we      = 1'b0;

    ra_addr = 5'd0;
    @(negedge clk);
    check("r0 write discarded", ra_data, 32'h0000_0000);

    // 3. Independent second read port still sees r5
    rb_addr = 5'd5;
    @(negedge clk);
    check("port B reads r5 independently", rb_data, 32'hDEAD_BEEF);

    // 4. Concurrent same-cycle dual read of different registers
    we      = 1'b1;
    wa_addr = 5'd12;
    wa_data = 32'h1234_5678;
    @(negedge clk);
    we      = 1'b0;

    ra_addr = 5'd12;
    rb_addr = 5'd5;
    @(negedge clk);
    check("port A reads r12", ra_data, 32'h1234_5678);
    check("port B still reads r5", rb_data, 32'hDEAD_BEEF);

    if (errors == 0) begin
      $display("ALL REGISTER FILE TESTS PASSED");
      $finish;
    end else begin
      $display("FAILED: %0d error(s)", errors);
      $fatal(1);
    end
  end

  // Global timeout so CI never hangs
  initial begin
    #10_000;
    $display("TIMEOUT: testbench did not complete in time");
    $fatal(1);
  end

endmodule : tb_register_file
