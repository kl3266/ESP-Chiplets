# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0
##########################
### ESP Local Makefile ###
##########################

all: help

### Global design variables ###
DESIGN_PATH = $(PWD)
ESP_ROOT = $(realpath ../../)
TECHLIB  = virtexu
BOARD    = profpga-xcvu440
BOARD_NUM ?= 0
CONSTRAINTS_DIR ?= profpga-xcvu440-chiplets/const_$(BOARD_NUM)
CONSTRAINTS_BASE ?= profpga-xcvu440
VIVADO_GENERIC ?= BOARD_NUM=$(BOARD_NUM)
INCLUDE_MIG_IP ?= 1
#ifeq ($(BOARD_NUM),0)
#VIVADO_SYNTH_STRATEGY ?= Flow_PerfOptimized_high
#VIVADO_IMPL_STRATEGY ?= Performance_Explore
#endif
ALLOW_UNCONSTRAINED_IO := 0
WRITE_BITSTREAM_PREHOOK ?= $(ESP_ROOT)/socs/profpga-xcvu440-chiplets/write_bitstream_prehook.tcl
DESIGN   = esp-$(BOARD)
SMP = 0
BASE_FREQ_MHZ ?= 78
LEON3_STACK ?= 0x5bfffff0
USE_OPENSBI = 1
VIVADO_TOP ?= $(if $(filter 0,$(BOARD_NUM)),$(TOP),top_satellite)

### Design top level and testbench ###
TOP    = top
SIMTOP = testbench


### Modelsim Simulation Options ###

# Compile flags
VCOMOPT +=
VLOGOPT +=

XCOMOPT +=
XLOGOPT +=

VSIMOPT +=


### Additional design files ###
TOP_VHDL_RTL_PKGS +=
TOP_VHDL_RTL_SRCS +=
TOP_VLOG_RTL_SRCS +=
TOP_VHDL_SIM_PKGS +=
TOP_VHDL_SIM_SRCS += $(DESIGN_PATH)/top_satellite.vhd
TOP_VHDL_SIM_SRCS +=
TOP_VLOG_SIM_SRCS +=


### Xilinx Vivado hw_server ###
FPGA_HOST ?= localhost
XIL_HW_SERVER_PORT ?= 3121


# IP address or host name of the host connected to the FPGA
UART_IP ?=
UART_PORT ?=

# SSH IP address or host name of the ESP Linux instance or gateway
SSH_IP ?=
SSH_PORT ?= 22

# ESPLink IP address or gateway (DO NOT USE HOST NAME)
ESPLINK_IP ?=
ESPLINK_PORT ?= 46392

# MAC address for Linux if using IP address reservation (e.g. 00aabb33cc77)
# LINUX_MAC ?=

vivado-syn-board0:
	$(QUIET_CLEAN)$(RM) -r vivado_0 logs/vivado_0
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=0 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-distclean
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=0 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-syn
	$(QUIET_MKDIR)mkdir -p mb_1_TA1
	$(QUIET_RUN)cp -f top.bit mb_1_TA1/top_fpga.bit
	$(QUIET_RUN)mv vivado vivado_0
	@if test -d logs/vivado; then mv logs/vivado logs/vivado_0; fi

vivado-syn-board1:
	$(QUIET_CLEAN)$(RM) -r vivado_1 logs/vivado_1
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=1 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-distclean
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=1 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-syn
	$(QUIET_MKDIR)mkdir -p mb_1_TC1
	$(QUIET_RUN)cp -f top_satellite.bit mb_1_TC1/top_fpga.bit
	$(QUIET_RUN)mv vivado vivado_1
	@if test -d logs/vivado; then mv logs/vivado logs/vivado_1; fi

vivado-syn-board2:
	$(QUIET_CLEAN)$(RM) -r vivado_2 logs/vivado_2
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=2 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-distclean
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=2 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-syn
	$(QUIET_MKDIR)mkdir -p mb_1_TA3
	$(QUIET_RUN)cp -f top_satellite.bit mb_1_TA3/top_fpga.bit
	$(QUIET_RUN)mv vivado vivado_2
	@if test -d logs/vivado; then mv logs/vivado logs/vivado_2; fi

vivado-syn-board3:
	$(QUIET_CLEAN)$(RM) -r vivado_3 logs/vivado_3
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=3 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-distclean
	$(QUIET_MAKE)$(MAKE) --no-print-directory BOARD_NUM=3 INCLUDE_MIG_IP=1 ALLOW_UNCONSTRAINED_IO=0 vivado-syn
	$(QUIET_MKDIR)mkdir -p mb_1_TC3
	$(QUIET_RUN)cp -f top_satellite.bit mb_1_TC3/top_fpga.bit
	$(QUIET_RUN)mv vivado vivado_3
	@if test -d logs/vivado; then mv logs/vivado logs/vivado_3; fi

vivado-syn-4boards:
	$(QUIET_MAKE)$(MAKE) --no-print-directory vivado-syn-board0
	$(QUIET_MAKE)$(MAKE) --no-print-directory vivado-syn-board1
	$(QUIET_MAKE)$(MAKE) --no-print-directory vivado-syn-board2
	$(QUIET_MAKE)$(MAKE) --no-print-directory vivado-syn-board3

.NOTPARALLEL: vivado-syn-board0 vivado-syn-board1 vivado-syn-board2 vivado-syn-board3 vivado-syn-4boards

.PHONY: vivado-syn-board0 vivado-syn-board1 vivado-syn-board2 vivado-syn-board3 vivado-syn-4boards

### Include global Makefile ###
include $(ESP_ROOT)/utils/Makefile

# Compile the satellite top after the main FPGA top in RTL/Vivado flows.
# Simulation picks it up from TOP_VHDL_SIM_SRCS above because Modelsim expands
# its compile list while processing the shared makefiles.
TOP_VHDL_RTL_SRCS += $(DESIGN_PATH)/top_satellite.vhd
