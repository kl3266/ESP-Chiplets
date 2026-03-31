# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#              Bitstream Configuration                     -
#-----------------------------------------------------------
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
# BOARD_NUM is set in Vivado project setup via VIVADO_GENERIC.

#-----------------------------------------------------------
#              Clock Pins                                  -
#-----------------------------------------------------------

# Reference clocks pins are connected to DDR4 cards and to the DMBI interface


#-----------------------------------------------------------
#              LEDs                                        -
#-----------------------------------------------------------

# {LED_RED}
set_property PACKAGE_PIN BF34 [get_ports LED_RED]

# {LED_GREEN}
set_property PACKAGE_PIN BE34 [get_ports LED_GREEN]

# {LED_BLUE}
set_property PACKAGE_PIN BE29 [get_ports LED_BLUE]

# {LED_YELLOW}
set_property PACKAGE_PIN BE30 [get_ports LED_YELLOW]

set_property IOSTANDARD LVCMOS18 [get_ports {LED_*}]

#-----------------------------------------------------------
#              Diagnostic LEDs                             -
#-----------------------------------------------------------
# Keep calib/diagnostic pins constrained on satellite boards for the same
# reason as UART (shared top-level I/O list across all BOARD_NUM values).
# {ta1_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c0_calib_complete]
set_property DRIVE 8 [get_ports c0_calib_complete]
set_property PACKAGE_PIN T34 [get_ports {c0_calib_complete}]

# {ta1_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c0_diagnostic_led]
set_property DRIVE 8 [get_ports c0_diagnostic_led]
set_property PACKAGE_PIN F39 [get_ports {c0_diagnostic_led}]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# `const_1` is BOARD_NUM=1 on module FB1. The generated
# chiplets_cable_connected project does not expose a reset button on this
# slot, and the RTL now ignores the external reset input for satellites.
# Park the shared port on unused K28.
set_property IOSTANDARD LVCMOS12 [get_ports reset]
set_property DRIVE 8 [get_ports reset]
set_property PACKAGE_PIN K28 [get_ports reset]


#-----------------------------------------------------------
#              Clock                                       -
#-----------------------------------------------------------

# {CLK1_N}
set_property IOSTANDARD LVDS [get_ports {esp_clk_n}]
set_property PACKAGE_PIN CA40 [get_ports {esp_clk_n}]

# {CLK1_P}
set_property IOSTANDARD LVDS [get_ports {esp_clk_p}]
set_property PACKAGE_PIN CA39 [get_ports {esp_clk_p}]

set_property IOSTANDARD LVDS [get_ports {d2d_clk_n}]
set_property PACKAGE_PIN BM32 [get_ports {d2d_clk_n}]

set_property IOSTANDARD LVDS [get_ports {d2d_clk_p}]
set_property PACKAGE_PIN BL32 [get_ports {d2d_clk_p}]


#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------

# create_clock -period 11.2 [get_ports c0_sys_clk_p]

set d2d_clk_period 6.25
set clkm_elab [get_clocks -of_objects [get_nets {clkm}]]
# set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]
# set esp_clk_elab [get_clocks -of_objects [get_nets esp_clk]]

create_clock -period 10.0 -name esp_clk_p [get_ports esp_clk_p]
create_clock -period $d2d_clk_period -name d2d_clk_p [get_ports d2d_clk_p]
create_clock -period $d2d_clk_period -name c0_rx_clk [get_ports c0_cable_clk_p_rcv]
create_clock -period $d2d_clk_period -name c1_rx_clk [get_ports c1_cable_clk_p_rcv]

create_generated_clock -name c0_tx_fwd_clk -source [get_pins {c0_cable_frontend_i/inst_oddr_clk_fwd/C}] -divide_by 1 [get_ports c0_cable_clk_p]
create_generated_clock -name c1_tx_fwd_clk -source [get_pins {c1_cable_frontend_i/inst_oddr_clk_fwd/C}] -divide_by 1 [get_ports c1_cable_clk_p]

set d2d_cable_input_delay_max   0.64
set d2d_cable_input_delay_min  -0.64
set c0_d2d_cable_output_delay_max  0.64
set c0_d2d_cable_output_delay_min -0.64
set c1_d2d_cable_output_delay_max  0.64
set c1_d2d_cable_output_delay_min -0.64

set c0_cable_io_lower_ports [get_ports {c0_cable_io_data[0] c0_cable_io_data[1] c0_cable_io_data[2] c0_cable_io_data[3] c0_cable_io_data[4] c0_cable_io_data[5] c0_cable_io_data[6] c0_cable_io_data[7] c0_cable_io_data[8] c0_cable_io_data[9] c0_cable_io_data[10] c0_cable_io_data[11] c0_cable_io_data[12] c0_cable_io_data[13] c0_cable_io_data[14] c0_cable_io_data[15] c0_cable_io_data[16] c0_cable_io_data[17] c0_cable_io_data[18] c0_cable_io_data[19] c0_cable_io_data[20] c0_cable_io_data[21] c0_cable_io_data[22] c0_cable_io_data[23] c0_cable_io_data[24] c0_cable_io_data[25] c0_cable_io_data[26] c0_cable_io_data[27] c0_cable_io_data[28] c0_cable_io_data[29] c0_cable_io_data[30] c0_cable_io_data[31] c0_cable_io_data[32] c0_cable_io_data[33] c0_cable_io_data[34] c0_cable_io_data[35] c0_cable_io_data[36] c0_cable_io_data[37] c0_cable_io_data[38] c0_cable_io_data[39] c0_cable_io_data[40] c0_cable_io_data[41] c0_cable_io_data[42] c0_cable_io_data[43] c0_cable_io_data[44] c0_cable_io_data[45] c0_cable_io_data[46] c0_cable_io_data[47] c0_cable_io_data[48] c0_cable_io_data[49] c0_cable_io_data[50] c0_cable_io_data[51] c0_cable_io_data[52] c0_cable_io_data[53] c0_cable_io_data[54] c0_cable_io_data[55] c0_cable_io_data[56] c0_cable_io_data[57] c0_cable_io_data[58] c0_cable_io_data[59] c0_cable_io_data[60] c0_cable_io_data[61] c0_cable_io_data[62] c0_cable_io_data[63] c0_cable_io_data[64] c0_cable_io_data[65] c0_cable_io_data[66] c0_cable_io_data[67]}]
set c0_cable_io_upper_ports [get_ports {c0_cable_io_data[68] c0_cable_io_data[69] c0_cable_io_data[70] c0_cable_io_data[71] c0_cable_io_data[72] c0_cable_io_data[73] c0_cable_io_data[74] c0_cable_io_data[75] c0_cable_io_data[76] c0_cable_io_data[77] c0_cable_io_data[78] c0_cable_io_data[79] c0_cable_io_data[80] c0_cable_io_data[81] c0_cable_io_data[82] c0_cable_io_data[83] c0_cable_io_data[84] c0_cable_io_data[85] c0_cable_io_data[86] c0_cable_io_data[87] c0_cable_io_data[88] c0_cable_io_data[89] c0_cable_io_data[90] c0_cable_io_data[91] c0_cable_io_data[92] c0_cable_io_data[93] c0_cable_io_data[94] c0_cable_io_data[95] c0_cable_io_data[96] c0_cable_io_data[97] c0_cable_io_data[98] c0_cable_io_data[99] c0_cable_io_data[100] c0_cable_io_data[101] c0_cable_io_data[102] c0_cable_io_data[103] c0_cable_io_data[104] c0_cable_io_data[105] c0_cable_io_data[106] c0_cable_io_data[107] c0_cable_io_data[108] c0_cable_io_data[109] c0_cable_io_data[110] c0_cable_io_data[111] c0_cable_io_data[112] c0_cable_io_data[113] c0_cable_io_data[114] c0_cable_io_data[115] c0_cable_io_data[116] c0_cable_io_data[117] c0_cable_io_data[118] c0_cable_io_data[119] c0_cable_io_data[120] c0_cable_io_data[121] c0_cable_io_data[122] c0_cable_io_data[123] c0_cable_io_data[124] c0_cable_io_data[125] c0_cable_io_data[126] c0_cable_io_data[127] c0_cable_io_data[128] c0_cable_io_data[129] c0_cable_io_data[130] c0_cable_io_data[131] c0_cable_io_data[132] c0_cable_io_data[133] c0_cable_io_data[134] c0_cable_io_data[135]}]
set c1_cable_io_lower_ports [get_ports {c1_cable_io_data[0] c1_cable_io_data[1] c1_cable_io_data[2] c1_cable_io_data[3] c1_cable_io_data[4] c1_cable_io_data[5] c1_cable_io_data[6] c1_cable_io_data[7] c1_cable_io_data[8] c1_cable_io_data[9] c1_cable_io_data[10] c1_cable_io_data[11] c1_cable_io_data[12] c1_cable_io_data[13] c1_cable_io_data[14] c1_cable_io_data[15] c1_cable_io_data[16] c1_cable_io_data[17] c1_cable_io_data[18] c1_cable_io_data[19] c1_cable_io_data[20] c1_cable_io_data[21] c1_cable_io_data[22] c1_cable_io_data[23] c1_cable_io_data[24] c1_cable_io_data[25] c1_cable_io_data[26] c1_cable_io_data[27] c1_cable_io_data[28] c1_cable_io_data[29] c1_cable_io_data[30] c1_cable_io_data[31] c1_cable_io_data[32] c1_cable_io_data[33] c1_cable_io_data[34] c1_cable_io_data[35] c1_cable_io_data[36] c1_cable_io_data[37] c1_cable_io_data[38] c1_cable_io_data[39] c1_cable_io_data[40] c1_cable_io_data[41] c1_cable_io_data[42] c1_cable_io_data[43] c1_cable_io_data[44] c1_cable_io_data[45] c1_cable_io_data[46] c1_cable_io_data[47] c1_cable_io_data[48] c1_cable_io_data[49] c1_cable_io_data[50] c1_cable_io_data[51] c1_cable_io_data[52] c1_cable_io_data[53] c1_cable_io_data[54] c1_cable_io_data[55] c1_cable_io_data[56] c1_cable_io_data[57] c1_cable_io_data[58] c1_cable_io_data[59] c1_cable_io_data[60] c1_cable_io_data[61] c1_cable_io_data[62] c1_cable_io_data[63] c1_cable_io_data[64] c1_cable_io_data[65] c1_cable_io_data[66] c1_cable_io_data[67]}]
set c1_cable_io_upper_ports [get_ports {c1_cable_io_data[68] c1_cable_io_data[69] c1_cable_io_data[70] c1_cable_io_data[71] c1_cable_io_data[72] c1_cable_io_data[73] c1_cable_io_data[74] c1_cable_io_data[75] c1_cable_io_data[76] c1_cable_io_data[77] c1_cable_io_data[78] c1_cable_io_data[79] c1_cable_io_data[80] c1_cable_io_data[81] c1_cable_io_data[82] c1_cable_io_data[83] c1_cable_io_data[84] c1_cable_io_data[85] c1_cable_io_data[86] c1_cable_io_data[87] c1_cable_io_data[88] c1_cable_io_data[89] c1_cable_io_data[90] c1_cable_io_data[91] c1_cable_io_data[92] c1_cable_io_data[93] c1_cable_io_data[94] c1_cable_io_data[95] c1_cable_io_data[96] c1_cable_io_data[97] c1_cable_io_data[98] c1_cable_io_data[99] c1_cable_io_data[100] c1_cable_io_data[101] c1_cable_io_data[102] c1_cable_io_data[103] c1_cable_io_data[104] c1_cable_io_data[105] c1_cable_io_data[106] c1_cable_io_data[107] c1_cable_io_data[108] c1_cable_io_data[109] c1_cable_io_data[110] c1_cable_io_data[111] c1_cable_io_data[112] c1_cable_io_data[113] c1_cable_io_data[114] c1_cable_io_data[115] c1_cable_io_data[116] c1_cable_io_data[117] c1_cable_io_data[118] c1_cable_io_data[119] c1_cable_io_data[120] c1_cable_io_data[121] c1_cable_io_data[122] c1_cable_io_data[123] c1_cable_io_data[124] c1_cable_io_data[125] c1_cable_io_data[126] c1_cable_io_data[127] c1_cable_io_data[128] c1_cable_io_data[129] c1_cable_io_data[130] c1_cable_io_data[131] c1_cable_io_data[132] c1_cable_io_data[133] c1_cable_io_data[134] c1_cable_io_data[135]}]

# BOARD_NUM = 1: c0 uses lower TX / upper RX, c1 uses lower RX / upper TX.
set c0_cable_rx_ports $c0_cable_io_lower_ports
set c0_cable_tx_ports $c0_cable_io_upper_ports
set c1_cable_tx_ports $c1_cable_io_lower_ports
set c1_cable_rx_ports $c1_cable_io_upper_ports

set_output_delay -clock [get_clocks c0_tx_fwd_clk] -max $c0_d2d_cable_output_delay_max $c0_cable_tx_ports
set_output_delay -clock [get_clocks c0_tx_fwd_clk] -min $c0_d2d_cable_output_delay_min $c0_cable_tx_ports

set_output_delay -clock [get_clocks c1_tx_fwd_clk] -max $c1_d2d_cable_output_delay_max $c1_cable_tx_ports
set_output_delay -clock [get_clocks c1_tx_fwd_clk] -min $c1_d2d_cable_output_delay_min $c1_cable_tx_ports

# The forwarded RX clocks are generated with ODDRE1 + IS_C_INVERTED, so the
# transmitter launches data on the falling edge of the forwarded clock and the
# receiver samples on the next rising edge in the middle of the data eye.
set_input_delay -clock [get_clocks c0_rx_clk] -clock_fall -max $d2d_cable_input_delay_max $c0_cable_rx_ports
set_input_delay -clock [get_clocks c0_rx_clk] -clock_fall -min $d2d_cable_input_delay_min $c0_cable_rx_ports

set_input_delay -clock [get_clocks c1_rx_clk] -clock_fall -max $d2d_cable_input_delay_max $c1_cable_rx_ports
set_input_delay -clock [get_clocks c1_rx_clk] -clock_fall -min $d2d_cable_input_delay_min $c1_cable_rx_ports

# # --- CDC constraints by mechanism ---
# # # 1) Async FIFO CDCs: bound Gray-pointer CDC routing into stage-1 synchronizers.
# # min of d2d_clk_period and clkm period
# set_max_delay -datapath_only \
#     -from [get_cells -hierarchical -filter {NAME =~ *u_async_fifo*rcb*gray* && NAME !~ *gray_x* && IS_SEQUENTIAL}] \
#     -to   [get_cells -hierarchical -filter {NAME =~ *u_async_fifo*rcb_gray_xm* && IS_SEQUENTIAL}] \
#     $d2d_clk_period
# set_max_delay -datapath_only \
#     -from [get_cells -hierarchical -filter {NAME =~ *u_async_fifo*wcb*gray* && NAME !~ *gray_x* && IS_SEQUENTIAL}] \
#     -to   [get_cells -hierarchical -filter {NAME =~ *u_async_fifo*wcb_gray_xm* && IS_SEQUENTIAL}] \
#     $d2d_clk_period


# # 2) Async FIFO Data Payload CDCs
# # Applying datapath_only to the RAM arrays ignores the impossible hold checks
# # 2) Async FIFO Data Payload CDCs
# # Provide the source clocks as the -from startpoints to satisfy -datapath_only, 
# # while using -through to target the distributed RAM array.
# set_max_delay -datapath_only -from [get_clocks -include_generated_clocks c0_rx_clk] -through [get_cells -hierarchical -filter {NAME =~ *u_async_fifo*mem_reg*}] -to [get_clocks -include_generated_clocks $clkm_elab] $d2d_clk_period
# set_max_delay -datapath_only -from [get_clocks -include_generated_clocks c1_rx_clk] -through [get_cells -hierarchical -filter {NAME =~ *u_async_fifo*mem_reg*}] -to [get_clocks -include_generated_clocks $clkm_elab] $d2d_clk_period
# set_max_delay -datapath_only -from [get_clocks -include_generated_clocks $clkm_elab] -through [get_cells -hierarchical -filter {NAME =~ *u_async_fifo*mem_reg*}] -to [get_clocks -include_generated_clocks $clkm_elab] $d2d_clk_period

# set_max_delay -datapath_only \
#     -from [get_cells -hierarchical -filter {NAME =~ *c0_credit_in_evt_gray_src_reg* && IS_SEQUENTIAL}] \
#     -to   [get_cells -hierarchical -filter {NAME =~ *c0_credit_in_evt_gray_ff1* && IS_SEQUENTIAL}] \
#     $d2d_clk_period
# set_max_delay -datapath_only \
#     -from [get_cells -hierarchical -filter {NAME =~ *c1_credit_in_evt_gray_src_reg* && IS_SEQUENTIAL}] \
#     -to   [get_cells -hierarchical -filter {NAME =~ *c1_credit_in_evt_gray_ff1* && IS_SEQUENTIAL}] \
#     $d2d_clk_period

# set_max_delay -datapath_only \
#     -from [get_cells -hierarchical -filter {NAME =~ *chiplet_credit_out*_evt_gray_src_reg* && IS_SEQUENTIAL}] \
#     -to   [get_cells -hierarchical -filter {NAME =~ *chiplet_credit_out*_evt_gray_ff1* && IS_SEQUENTIAL}] \
#     $d2d_clk_period

# set_max_delay -datapath_only \
#     -from [get_cells -hierarchical -filter {NAME =~ *d2d_ack_evt_gray_src_reg* && IS_SEQUENTIAL}] \
#     -to   [get_cells -hierarchical -filter {NAME =~ *d2d_ack_evt_gray_meta* && IS_SEQUENTIAL}] \
#     $d2d_clk_period

# # 4) Cross-Domain Reset Isolation (Recovery/Removal ignores)
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *rst0/*rstout* && IS_SEQUENTIAL}] -to [get_clocks -include_generated_clocks c0_rx_clk]
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *rst0/*rstout* && IS_SEQUENTIAL}] -to [get_clocks -include_generated_clocks c1_rx_clk]
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *rst1/*rstout* && IS_SEQUENTIAL}] -to [get_clocks -include_generated_clocks c0_rx_clk]
# set_false_path -from [get_cells -hierarchical -filter {NAME =~ *rst1/*rstout* && IS_SEQUENTIAL}] -to [get_clocks -include_generated_clocks c1_rx_clk]
# set_false_path -to [get_cells -hierarchical -filter {NAME =~ *d2d_ready_sync*reg*}]

# set_clock_groups -asynchronous \
#     -group [get_clocks -include_generated_clocks c0_rx_clk] \
#     -group [get_clocks -include_generated_clocks c1_rx_clk] \
#     -group [get_clocks -include_generated_clocks esp_clk_p]

# set_clock_groups -asynchronous \
#     -group [get_clocks -include_generated_clocks esp_clk_p] \
#     -group [get_clocks -include_generated_clocks $clkm_elab]
    
set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks c0_rx_clk] \
    -group [get_clocks -include_generated_clocks c1_rx_clk] \
    -group [get_clocks -include_generated_clocks esp_clk_p] \
    -group [get_clocks -include_generated_clocks d2d_clk_p] \
    -group [get_clocks $clkm_elab]

# Cable-data banks from vivado_1/top_satellite_io_placed.rpt
set_property INTERNAL_VREF {0.90} [get_iobanks 31]
set_property INTERNAL_VREF {0.90} [get_iobanks 26]
set_property INTERNAL_VREF {0.90} [get_iobanks 27]
set_property INTERNAL_VREF {0.90} [get_iobanks 28]
set_property INTERNAL_VREF {0.90} [get_iobanks 32]
set_property INTERNAL_VREF {0.90} [get_iobanks 33]
# In top_satellite, only clkm is live from the c0 MIG. clkm_1..6 are legacy
# internal declarations with no active clock source.
#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]
set_false_path -to [get_ports c0_diagnostic_led]
