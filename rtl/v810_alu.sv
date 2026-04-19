// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 single-cycle combinational ALU. See docs/adr/0001-alu-design.md.

`timescale 1ns/1ps

module v810_alu
  import v810_pkg::*;
(
  input  alu_op_e          op,
  input  logic [XLEN-1:0]  a,
  input  logic [XLEN-1:0]  b,
  output logic [XLEN-1:0]  result,
  output logic             flag_z,
  output logic             flag_s,
  output logic             flag_ov,
  output logic             flag_cy
);

  logic [XLEN:0] add_ext;
  logic [XLEN:0] sub_ext;

  assign add_ext = {1'b0, a} + {1'b0, b};
  assign sub_ext = {1'b0, a} - {1'b0, b};

  always_comb begin
    unique case (op)
      ALU_ADD: result = add_ext[XLEN-1:0];
      ALU_SUB: result = sub_ext[XLEN-1:0];
      ALU_AND: result = a & b;
      ALU_OR : result = a | b;
      ALU_XOR: result = a ^ b;
      ALU_NOT: result = ~b;
      ALU_SHL: result = a <<  b[4:0];
      ALU_SHR: result = a >>  b[4:0];
      ALU_SAR: result = $signed(a) >>> b[4:0];
      ALU_MOV: result = b;
      default: result = '0;
    endcase
  end

  assign flag_z = (result == '0);
  assign flag_s = result[XLEN-1];

  logic add_signed_ov;
  logic sub_signed_ov;

  assign add_signed_ov = (a[XLEN-1] == b[XLEN-1]) &&
                         (add_ext[XLEN-1] != a[XLEN-1]);

  assign sub_signed_ov = (a[XLEN-1] != b[XLEN-1]) &&
                         (sub_ext[XLEN-1] != a[XLEN-1]);

  always_comb begin
    flag_ov = 1'b0;
    flag_cy = 1'b0;
    unique case (op)
      ALU_ADD: begin
        flag_ov = add_signed_ov;
        flag_cy = add_ext[XLEN];
      end
      ALU_SUB: begin
        flag_ov = sub_signed_ov;
        flag_cy = sub_ext[XLEN];
      end
      default: begin
        flag_ov = 1'b0;
        flag_cy = 1'b0;
      end
    endcase
  end

endmodule : v810_alu
