# v810-hdl local simulation runner
#
# Requires Verilator 5.x (for --binary + --timing).
#
# Usage:
#   make all              build and run every testbench
#   make register_file    run the register file testbench
#   make v810_alu         run the ALU testbench
#   make v810_top         run the top-level integration testbench
#   make lint             lint all RTL
#   make clean            remove build artifacts

VERILATOR ?= verilator
RTL_DIR   := ../rtl
TB_DIR    := .

VFLAGS_COMMON := --binary --timing -Wall -Wno-UNUSED

RTL_SRCS := $(RTL_DIR)/v810_pkg.sv \
            $(RTL_DIR)/v810_alu.sv \
            $(RTL_DIR)/register_file.sv \
            $(RTL_DIR)/v810_fetch.sv \
            $(RTL_DIR)/v810_decoder.sv \
            $(RTL_DIR)/v810.sv

.PHONY: all register_file v810_alu v810_top lint clean

all: register_file v810_alu v810_top

register_file:
	$(VERILATOR) $(VFLAGS_COMMON) \
	    $(RTL_DIR)/v810_pkg.sv \
	    $(RTL_DIR)/register_file.sv \
	    $(TB_DIR)/tb_register_file.sv \
	    --top-module tb_register_file \
	    -Mdir obj_dir_regfile
	./obj_dir_regfile/Vtb_register_file

v810_alu:
	$(VERILATOR) $(VFLAGS_COMMON) \
	    $(RTL_DIR)/v810_pkg.sv \
	    $(RTL_DIR)/v810_alu.sv \
	    $(TB_DIR)/tb_v810_alu.sv \
	    --top-module tb_v810_alu \
	    -Mdir obj_dir_alu
	./obj_dir_alu/Vtb_v810_alu

v810_top:
	$(VERILATOR) $(VFLAGS_COMMON) \
	    $(RTL_SRCS) \
	    $(TB_DIR)/tb_v810_top.sv \
	    --top-module tb_v810_top \
	    -Mdir obj_dir_top
	./obj_dir_top/Vtb_v810_top

lint:
	$(VERILATOR) --lint-only -Wall -Wno-UNUSED $(RTL_SRCS)

clean:
	rm -rf obj_dir obj_dir_regfile obj_dir_alu obj_dir_top
