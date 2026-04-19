# v810-hdl local simulation runner
#
# Requires Verilator 5.x (for --binary + --timing).
#
# Usage:
#   make <testname>       e.g. make register_file
#   make lint             lint all RTL
#   make clean            remove build artifacts

VERILATOR ?= verilator
RTL_DIR   := ../rtl
TB_DIR    := .
BUILD_DIR := obj_dir

VFLAGS_COMMON := --binary --timing -Wall -Wno-UNUSED
RTL_SRCS      := $(RTL_DIR)/v810_pkg.sv $(RTL_DIR)/register_file.sv $(RTL_DIR)/v810.sv

.PHONY: register_file lint clean

register_file:
	$(VERILATOR) $(VFLAGS_COMMON) \
	    $(RTL_DIR)/v810_pkg.sv \
	    $(RTL_DIR)/register_file.sv \
	    $(TB_DIR)/tb_register_file.sv \
	    --top-module tb_register_file
	./$(BUILD_DIR)/Vtb_register_file

lint:
	$(VERILATOR) --lint-only -Wall -Wno-UNUSED $(RTL_SRCS)

clean:
	rm -rf $(BUILD_DIR)
