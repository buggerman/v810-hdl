// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 general-purpose register file.
//   - 32 registers x 32 bits
//   - r0 hardwired to zero (writes discarded, reads return zero)
//   - Two asynchronous read ports (ra, rb)
//   - One synchronous write port (wa)

`timescale 1ns/1ps

module register_file
  import v810_pkg::*;
(
  input  logic                 clk,
  input  logic                 rst_n,

  input  logic [GPR_IDX-1:0]   ra_addr,
  output logic [XLEN-1:0]      ra_data,

  input  logic [GPR_IDX-1:0]   rb_addr,
  output logic [XLEN-1:0]      rb_data,

  input  logic                 we,
  input  logic [GPR_IDX-1:0]   wa_addr,
  input  logic [XLEN-1:0]      wa_data
);

  logic [XLEN-1:0] regs [NGPR];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < NGPR; i++) regs[i] <= '0;
    end else if (we && (wa_addr != '0)) begin
      regs[wa_addr] <= wa_data;
    end
  end

  assign ra_data = (ra_addr == '0) ? '0 : regs[ra_addr];
  assign rb_data = (rb_addr == '0) ? '0 : regs[rb_addr];

endmodule : register_file
