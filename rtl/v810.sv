// Copyright 2026 v810-hdl contributors
// SPDX-License-Identifier: Apache-2.0
//
// V810 CPU top-level module.
//
// Status: SKELETON. All outputs are tied off so the module elaborates and
// passes lint. Sub-modules (decoder, pipeline stages, ALU, FPU, interrupt
// controller) will be instantiated in subsequent phases per docs/ROADMAP.md.

module v810
  import v810_pkg::*;
(
  input  logic              clk,
  input  logic              rst_n,

  // Instruction memory port
  output logic [ALEN-1:0]   imem_addr,
  output logic              imem_req,
  input  logic [XLEN-1:0]   imem_rdata,
  input  logic              imem_ack,

  // Data memory port (byte-enabled)
  output logic [ALEN-1:0]   dmem_addr,
  output logic              dmem_req,
  output logic              dmem_we,
  output logic [3:0]        dmem_be,
  output logic [XLEN-1:0]   dmem_wdata,
  input  logic [XLEN-1:0]   dmem_rdata,
  input  logic              dmem_ack,

  // Interrupts
  input  logic [4:0]        int_level,
  input  logic              nmi,

  // Status
  output logic              halted
);

  // TODO(Phase 1): fetch/decode + register_file + ALU
  // TODO(Phase 3): 5-stage pipeline with forwarding and interlocks
  // TODO(Phase 4): interrupt controller + system registers
  // TODO(Phase 5): FPU

  // Acknowledge inputs to keep the linter quiet while the module is a stub.
  // These references will be replaced as sub-modules are instantiated.
  wire _unused_ok = &{1'b0,
                     imem_rdata, imem_ack,
                     dmem_rdata, dmem_ack,
                     int_level,  nmi,
                     rst_n,
                     1'b0};

  assign imem_addr  = '0;
  assign imem_req   = 1'b0;
  assign dmem_addr  = '0;
  assign dmem_req   = 1'b0;
  assign dmem_we    = 1'b0;
  assign dmem_be    = 4'b0000;
  assign dmem_wdata = '0;
  assign halted     = 1'b1;  // stub: immediately halted

endmodule : v810
