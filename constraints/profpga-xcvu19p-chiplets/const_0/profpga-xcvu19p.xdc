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
#              UART                                        -
#-----------------------------------------------------------

# {ba1_eb1_UART1_CTSN}
set_property PACKAGE_PIN M26 [get_ports uart_rtsn]

# {ba1_eb1_UART1_RTSN}
set_property PACKAGE_PIN M22 [get_ports uart_ctsn]

# {ba1_eb1_UART1_RXD}
set_property PACKAGE_PIN L22 [get_ports uart_txd]

# {ba1_eb1_UART1_TXD}
set_property PACKAGE_PIN L25 [get_ports uart_rxd]

set_property IOSTANDARD LVCMOS18 [get_ports {uart_*}]

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
# {ta0_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c0_calib_complete]
set_property DRIVE 8 [get_ports c0_calib_complete]
set_property PACKAGE_PIN C9 [get_ports {c0_calib_complete}]

# {ta0_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c0_diagnostic_led]
set_property DRIVE 8 [get_ports c0_diagnostic_led]
set_property PACKAGE_PIN B13 [get_ports {c0_diagnostic_led}]

# {ta1_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c1_calib_complete]
set_property DRIVE 8 [get_ports c1_calib_complete]
set_property PACKAGE_PIN T34 [get_ports {c1_calib_complete}]

# {ta1_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c1_diagnostic_led]
set_property DRIVE 8 [get_ports c1_diagnostic_led]
set_property PACKAGE_PIN F39 [get_ports {c1_diagnostic_led}]

# {ta2_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c2_calib_complete]
set_property DRIVE 8 [get_ports c2_calib_complete]
set_property PACKAGE_PIN A54 [get_ports {c2_calib_complete}]

# {ta2_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c2_diagnostic_led]
set_property DRIVE 8 [get_ports c2_diagnostic_led]
set_property PACKAGE_PIN E63 [get_ports {c2_diagnostic_led}]

# {tb0_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c3_calib_complete]
set_property DRIVE 8 [get_ports c3_calib_complete]
set_property PACKAGE_PIN BH15 [get_ports {c3_calib_complete}]

# {tb0_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c3_diagnostic_led]
set_property DRIVE 8 [get_ports c3_diagnostic_led]
set_property PACKAGE_PIN BY14 [get_ports {c3_diagnostic_led}]

# {tb1_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c4_calib_complete]
set_property DRIVE 8 [get_ports c4_calib_complete]
set_property PACKAGE_PIN BU51 [get_ports {c4_calib_complete}]

# {tb1_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c4_diagnostic_led]
set_property DRIVE 8 [get_ports c4_diagnostic_led]
set_property PACKAGE_PIN BH41 [get_ports {c4_diagnostic_led}]

# {tb2_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c5_calib_complete]
set_property DRIVE 8 [get_ports c5_calib_complete]
set_property PACKAGE_PIN AR44 [get_ports {c5_calib_complete}]

# {tb2_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c5_diagnostic_led]
set_property DRIVE 8 [get_ports c5_diagnostic_led]
set_property PACKAGE_PIN AY55 [get_ports {c5_diagnostic_led}]

# {ba2_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c6_calib_complete]
set_property DRIVE 8 [get_ports c6_calib_complete]
set_property PACKAGE_PIN AA45 [get_ports {c6_calib_complete}]

# {ba2_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c6_diagnostic_led]
set_property DRIVE 8 [get_ports c6_diagnostic_led]
set_property PACKAGE_PIN W58 [get_ports {c6_diagnostic_led}]

## {ba0_eb1_LED_GREEN1}
#set_property IOSTANDARD LVCMOS12 [get_ports c7_calib_complete]
#set_property DRIVE 8 [get_ports c7_calib_complete]
#set_property PACKAGE_PIN E22 [get_ports {c7_calib_complete}]
#
## {ba0_eb1_LED_YELLOW2}
#set_property IOSTANDARD LVCMOS12 [get_ports c7_diagnostic_led]
#set_property DRIVE 8 [get_ports c7_diagnostic_led]
#set_property PACKAGE_PIN K44 [get_ports {c7_diagnostic_led}]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# `const_0` is BOARD_NUM=0 on module FA1. In the generated
# chiplets_cable_connected project, K28 is FA1_TA1 BUTTON3.
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

set_property IOSTANDARD LVDS [get_ports {d2d_delay_refclk_n}]
set_property PACKAGE_PIN BK32 [get_ports {d2d_delay_refclk_n}]

set_property IOSTANDARD LVDS [get_ports {d2d_delay_refclk_p}]
set_property PACKAGE_PIN BJ32 [get_ports {d2d_delay_refclk_p}]


#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------
set d2d_clk_period 6.25
set d2d_delay_refclk_period 2.5
set d2d_half       [expr {$d2d_clk_period / 2.0}] ;# 3.125
set d2d_quarter    [expr {$d2d_clk_period / 4.0}] ;# 1.5625
set d2d_skew       [expr {$d2d_clk_period / 4.0 * 0.1}]

create_clock -period 10.0 -name esp_clk_p [get_ports esp_clk_p]
create_clock -period $d2d_clk_period -name d2d_clk_p [get_ports d2d_clk_p]
create_clock -period $d2d_delay_refclk_period -name d2d_delay_refclk_p [get_ports d2d_delay_refclk_p]
# create_clock -period $d2d_clk_period \
#     -waveform [list $d2d_quarter [expr {$d2d_quarter + $d2d_half}]] \
#     -name c0_rx_clk_virt_shifted
# create_clock -period $d2d_clk_period \
#     -waveform [list $d2d_quarter [expr {$d2d_quarter + $d2d_half}]] \
#     -name c1_rx_clk_virt_shifted

create_clock -period $d2d_clk_period -name c0_rx_clk [get_ports c0_cable_clk_p_rcv]
create_clock -period $d2d_clk_period -name c1_rx_clk [get_ports c1_cable_clk_p_rcv]

# Recover elaborated clock name
set clkm_elab [get_clocks -of_objects [get_nets {clkm}]]
set clkm1_elab [get_clocks -of_objects [get_nets clkm_1]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set clkm3_elab [get_clocks -of_objects [get_nets clkm_3]]
set clkm4_elab [get_clocks -of_objects [get_nets clkm_4]]
set clkm5_elab [get_clocks -of_objects [get_nets clkm_5]]
set clkm6_elab [get_clocks -of_objects [get_nets clkm_6]]
# set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]
set c0_rx    [get_clocks c0_rx_clk]
set c1_rx    [get_clocks c1_rx_clk]

create_generated_clock -name c0_tx_fwd_clk -source [get_pins {c0_cable_frontend_i/inst_oddr_clk_fwd/C}] -divide_by 1 [get_ports c0_cable_clk_p]
create_generated_clock -name c1_tx_fwd_clk -source [get_pins {c1_cable_frontend_i/inst_oddr_clk_fwd/C}] -divide_by 1 [get_ports c1_cable_clk_p]

# create_generated_clock -name c0_tx_fwd_clk -source [get_ports d2d_clk_p] -divide_by 1 [get_ports c0_cable_clk_p]
# create_generated_clock -name c1_tx_fwd_clk -source [get_ports d2d_clk_p] -divide_by 1 [get_ports c1_cable_clk_p]

# $d2d_clk_period/4 +/- 0.15625
# For outputs: when does the other FPGA sample relative to the forwarded clock?
# For inputs: when does the other FPGA change the data relative to the received clock?
# set_output_delay:
# “At the other end, when does the receiver need my data to be valid relative to the forwarded clock?”
# set_input_delay:
# “At my end, when does the other transmitter put data onto the link so that it arrives at my pin relative to the received clock?”
# set d2d_cable_input_delay_max       1.40625
# set d2d_cable_input_delay_min       1.71875
# set c0_d2d_cable_output_delay_max   0.15625
# set c0_d2d_cable_output_delay_min   -0.15625
# set c1_d2d_cable_output_delay_max   0.15625
# set c1_d2d_cable_output_delay_min   -0.15625
set d2d_cable_input_delay_max     [expr {$d2d_skew}]
set d2d_cable_input_delay_min     [expr {-$d2d_skew}]
set c0_d2d_cable_output_delay_min [expr {$d2d_quarter - $d2d_skew}] ;# 1.40625
set c0_d2d_cable_output_delay_max [expr {$d2d_quarter + $d2d_skew}] ;# 1.71875
set c1_d2d_cable_output_delay_min [expr {$d2d_quarter - $d2d_skew}] ;# 1.40625
set c1_d2d_cable_output_delay_max [expr {$d2d_quarter + $d2d_skew}] ;# 1.71875

set c0_cable_io_lower_ports [get_ports {c0_cable_io_data[0] c0_cable_io_data[1] c0_cable_io_data[2] c0_cable_io_data[3] c0_cable_io_data[4] c0_cable_io_data[5] c0_cable_io_data[6] c0_cable_io_data[7] c0_cable_io_data[8] c0_cable_io_data[9] c0_cable_io_data[10] c0_cable_io_data[11] c0_cable_io_data[12] c0_cable_io_data[13] c0_cable_io_data[14] c0_cable_io_data[15] c0_cable_io_data[16] c0_cable_io_data[17] c0_cable_io_data[18] c0_cable_io_data[19] c0_cable_io_data[20] c0_cable_io_data[21] c0_cable_io_data[22] c0_cable_io_data[23] c0_cable_io_data[24] c0_cable_io_data[25] c0_cable_io_data[26] c0_cable_io_data[27] c0_cable_io_data[28] c0_cable_io_data[29] c0_cable_io_data[30] c0_cable_io_data[31] c0_cable_io_data[32] c0_cable_io_data[33] c0_cable_io_data[34] c0_cable_io_data[35] c0_cable_io_data[36] c0_cable_io_data[37] c0_cable_io_data[38] c0_cable_io_data[39] c0_cable_io_data[40] c0_cable_io_data[41] c0_cable_io_data[42] c0_cable_io_data[43] c0_cable_io_data[44] c0_cable_io_data[45] c0_cable_io_data[46] c0_cable_io_data[47] c0_cable_io_data[48] c0_cable_io_data[49] c0_cable_io_data[50] c0_cable_io_data[51] c0_cable_io_data[52] c0_cable_io_data[53] c0_cable_io_data[54] c0_cable_io_data[55] c0_cable_io_data[56] c0_cable_io_data[57] c0_cable_io_data[58] c0_cable_io_data[59] c0_cable_io_data[60] c0_cable_io_data[61] c0_cable_io_data[62] c0_cable_io_data[63] c0_cable_io_data[64] c0_cable_io_data[65] c0_cable_io_data[66] c0_cable_io_data[67]}]
set c0_cable_io_upper_ports [get_ports {c0_cable_io_data[68] c0_cable_io_data[69] c0_cable_io_data[70] c0_cable_io_data[71] c0_cable_io_data[72] c0_cable_io_data[73] c0_cable_io_data[74] c0_cable_io_data[75] c0_cable_io_data[76] c0_cable_io_data[77] c0_cable_io_data[78] c0_cable_io_data[79] c0_cable_io_data[80] c0_cable_io_data[81] c0_cable_io_data[82] c0_cable_io_data[83] c0_cable_io_data[84] c0_cable_io_data[85] c0_cable_io_data[86] c0_cable_io_data[87] c0_cable_io_data[88] c0_cable_io_data[89] c0_cable_io_data[90] c0_cable_io_data[91] c0_cable_io_data[92] c0_cable_io_data[93] c0_cable_io_data[94] c0_cable_io_data[95] c0_cable_io_data[96] c0_cable_io_data[97] c0_cable_io_data[98] c0_cable_io_data[99] c0_cable_io_data[100] c0_cable_io_data[101] c0_cable_io_data[102] c0_cable_io_data[103] c0_cable_io_data[104] c0_cable_io_data[105] c0_cable_io_data[106] c0_cable_io_data[107] c0_cable_io_data[108] c0_cable_io_data[109] c0_cable_io_data[110] c0_cable_io_data[111] c0_cable_io_data[112] c0_cable_io_data[113] c0_cable_io_data[114] c0_cable_io_data[115] c0_cable_io_data[116] c0_cable_io_data[117] c0_cable_io_data[118] c0_cable_io_data[119] c0_cable_io_data[120] c0_cable_io_data[121] c0_cable_io_data[122] c0_cable_io_data[123] c0_cable_io_data[124] c0_cable_io_data[125] c0_cable_io_data[126] c0_cable_io_data[127] c0_cable_io_data[128] c0_cable_io_data[129] c0_cable_io_data[130] c0_cable_io_data[131] c0_cable_io_data[132] c0_cable_io_data[133] c0_cable_io_data[134] c0_cable_io_data[135]}]
set c1_cable_io_lower_ports [get_ports {c1_cable_io_data[0] c1_cable_io_data[1] c1_cable_io_data[2] c1_cable_io_data[3] c1_cable_io_data[4] c1_cable_io_data[5] c1_cable_io_data[6] c1_cable_io_data[7] c1_cable_io_data[8] c1_cable_io_data[9] c1_cable_io_data[10] c1_cable_io_data[11] c1_cable_io_data[12] c1_cable_io_data[13] c1_cable_io_data[14] c1_cable_io_data[15] c1_cable_io_data[16] c1_cable_io_data[17] c1_cable_io_data[18] c1_cable_io_data[19] c1_cable_io_data[20] c1_cable_io_data[21] c1_cable_io_data[22] c1_cable_io_data[23] c1_cable_io_data[24] c1_cable_io_data[25] c1_cable_io_data[26] c1_cable_io_data[27] c1_cable_io_data[28] c1_cable_io_data[29] c1_cable_io_data[30] c1_cable_io_data[31] c1_cable_io_data[32] c1_cable_io_data[33] c1_cable_io_data[34] c1_cable_io_data[35] c1_cable_io_data[36] c1_cable_io_data[37] c1_cable_io_data[38] c1_cable_io_data[39] c1_cable_io_data[40] c1_cable_io_data[41] c1_cable_io_data[42] c1_cable_io_data[43] c1_cable_io_data[44] c1_cable_io_data[45] c1_cable_io_data[46] c1_cable_io_data[47] c1_cable_io_data[48] c1_cable_io_data[49] c1_cable_io_data[50] c1_cable_io_data[51] c1_cable_io_data[52] c1_cable_io_data[53] c1_cable_io_data[54] c1_cable_io_data[55] c1_cable_io_data[56] c1_cable_io_data[57] c1_cable_io_data[58] c1_cable_io_data[59] c1_cable_io_data[60] c1_cable_io_data[61] c1_cable_io_data[62] c1_cable_io_data[63] c1_cable_io_data[64] c1_cable_io_data[65] c1_cable_io_data[66] c1_cable_io_data[67]}]
set c1_cable_io_upper_ports [get_ports {c1_cable_io_data[68] c1_cable_io_data[69] c1_cable_io_data[70] c1_cable_io_data[71] c1_cable_io_data[72] c1_cable_io_data[73] c1_cable_io_data[74] c1_cable_io_data[75] c1_cable_io_data[76] c1_cable_io_data[77] c1_cable_io_data[78] c1_cable_io_data[79] c1_cable_io_data[80] c1_cable_io_data[81] c1_cable_io_data[82] c1_cable_io_data[83] c1_cable_io_data[84] c1_cable_io_data[85] c1_cable_io_data[86] c1_cable_io_data[87] c1_cable_io_data[88] c1_cable_io_data[89] c1_cable_io_data[90] c1_cable_io_data[91] c1_cable_io_data[92] c1_cable_io_data[93] c1_cable_io_data[94] c1_cable_io_data[95] c1_cable_io_data[96] c1_cable_io_data[97] c1_cable_io_data[98] c1_cable_io_data[99] c1_cable_io_data[100] c1_cable_io_data[101] c1_cable_io_data[102] c1_cable_io_data[103] c1_cable_io_data[104] c1_cable_io_data[105] c1_cable_io_data[106] c1_cable_io_data[107] c1_cable_io_data[108] c1_cable_io_data[109] c1_cable_io_data[110] c1_cable_io_data[111] c1_cable_io_data[112] c1_cable_io_data[113] c1_cable_io_data[114] c1_cable_io_data[115] c1_cable_io_data[116] c1_cable_io_data[117] c1_cable_io_data[118] c1_cable_io_data[119] c1_cable_io_data[120] c1_cable_io_data[121] c1_cable_io_data[122] c1_cable_io_data[123] c1_cable_io_data[124] c1_cable_io_data[125] c1_cable_io_data[126] c1_cable_io_data[127] c1_cable_io_data[128] c1_cable_io_data[129] c1_cable_io_data[130] c1_cable_io_data[131] c1_cable_io_data[132] c1_cable_io_data[133] c1_cable_io_data[134] c1_cable_io_data[135]}]

# BOARD_NUM = 0: lower half receives, upper half transmits.
set c0_cable_rx_ports $c0_cable_io_lower_ports
set c0_cable_tx_ports $c0_cable_io_upper_ports
set c1_cable_rx_ports $c1_cable_io_lower_ports
set c1_cable_tx_ports $c1_cable_io_upper_ports

# These calibrated BITSLICE locations are unavailable during BISC and only
# become usable after IDELAYCTRL/ODELAYCTRL RDY asserts.
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports {
  c0_cable_io_data[38] c0_cable_io_data[62] c0_cable_io_data[64]
  c1_cable_io_data[38] c1_cable_io_data[62] c1_cable_io_data[64]
}]

# D2D TX needs the strongest supported output edge on the forwarded-data half.
set_property SLEW FAST $c0_cable_tx_ports
set_property SLEW FAST $c1_cable_tx_ports

# DDR TX: D1 launched at rising edge, D2 at falling edge of c*_tx_fwd_clk.
set_output_delay -clock [get_clocks c0_tx_fwd_clk]            -max $c0_d2d_cable_output_delay_max $c0_cable_tx_ports
set_output_delay -clock [get_clocks c0_tx_fwd_clk]            -min $c0_d2d_cable_output_delay_min $c0_cable_tx_ports
set_output_delay -clock [get_clocks c0_tx_fwd_clk] -clock_fall -max $c0_d2d_cable_output_delay_max $c0_cable_tx_ports -add_delay
set_output_delay -clock [get_clocks c0_tx_fwd_clk] -clock_fall -min $c0_d2d_cable_output_delay_min $c0_cable_tx_ports -add_delay

set_output_delay -clock [get_clocks c1_tx_fwd_clk]            -max $c1_d2d_cable_output_delay_max $c1_cable_tx_ports
set_output_delay -clock [get_clocks c1_tx_fwd_clk]            -min $c1_d2d_cable_output_delay_min $c1_cable_tx_ports
set_output_delay -clock [get_clocks c1_tx_fwd_clk] -clock_fall -max $c1_d2d_cable_output_delay_max $c1_cable_tx_ports -add_delay
set_output_delay -clock [get_clocks c1_tx_fwd_clk] -clock_fall -min $c1_d2d_cable_output_delay_min $c1_cable_tx_ports -add_delay

# DDR RX: IDDRE1 captures Q1 at rising edge and Q2 at falling edge of the
# MMCM-shifted receive clock. Delay values are cable skew (±0.64 ns) referenced
# to the primary forwarded clock at the board pin; the MMCM centering phase shift
# is accounted for by Vivado's internal clock-topology model — do not add T/4.
set_input_delay -clock [get_clocks c0_rx_clk]            -max $d2d_cable_input_delay_max $c0_cable_rx_ports
set_input_delay -clock [get_clocks c0_rx_clk]            -min $d2d_cable_input_delay_min $c0_cable_rx_ports
set_input_delay -clock [get_clocks c0_rx_clk] -clock_fall -max $d2d_cable_input_delay_max $c0_cable_rx_ports -add_delay
set_input_delay -clock [get_clocks c0_rx_clk] -clock_fall -min $d2d_cable_input_delay_min $c0_cable_rx_ports -add_delay

set_input_delay -clock [get_clocks c1_rx_clk]            -max $d2d_cable_input_delay_max $c1_cable_rx_ports
set_input_delay -clock [get_clocks c1_rx_clk]            -min $d2d_cable_input_delay_min $c1_cable_rx_ports
set_input_delay -clock [get_clocks c1_rx_clk] -clock_fall -max $d2d_cable_input_delay_max $c1_cable_rx_ports -add_delay
set_input_delay -clock [get_clocks c1_rx_clk] -clock_fall -min $d2d_cable_input_delay_min $c1_cable_rx_ports -add_delay

set_false_path \
  -from [get_cells -quiet -hierarchical -filter {IS_SEQUENTIAL && (NAME =~ *rst0/*rstout* || NAME =~ *rst1/*rstout* || NAME =~ *rst_c0/*rstout* || NAME =~ *rst_c1/*rstout*)}] \
  -to [get_cells -quiet -hierarchical -filter {IS_SEQUENTIAL && (NAME =~ *fifo_rst_clk_sync_ff1* || NAME =~ *fifo_rst_d2d_pos_sync_ff1* || NAME =~ *fifo_rst_d2d_neg_sync_ff1*)}]
set_false_path \
  -from [get_cells -quiet -hierarchical -filter {IS_SEQUENTIAL && NAME =~ *fifo_rst*_sync_ff2*}] \
  -to [get_cells -quiet -hierarchical -filter {IS_SEQUENTIAL && (NAME =~ *d2d_tx_impl_i* || NAME =~ *d2d_rx_impl_i*)}]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks c0_rx_clk] \
    -group [get_clocks -include_generated_clocks c1_rx_clk] \
    -group [get_clocks -include_generated_clocks esp_clk_p] \
    -group [get_clocks -include_generated_clocks d2d_clk_p] \
    -group [get_clocks -include_generated_clocks d2d_delay_refclk_p] \
    -group [get_clocks $clkm_elab]   \
    -group [get_clocks $clkm1_elab]  \
    -group [get_clocks $clkm2_elab]  \
    -group [get_clocks $clkm3_elab]  \
    -group [get_clocks $clkm4_elab]  \
    -group [get_clocks $clkm5_elab]  \
    -group [get_clocks $clkm6_elab]

set_property INTERNAL_VREF {0.90} [get_iobanks 19]
set_property INTERNAL_VREF {0.90} [get_iobanks 74]
set_property INTERNAL_VREF {0.90} [get_iobanks 75]
set_property INTERNAL_VREF {0.90} [get_iobanks 38]
set_property INTERNAL_VREF {0.90} [get_iobanks 62]
set_property INTERNAL_VREF {0.90} [get_iobanks 63]

#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]
set_false_path -to [get_ports {c0_diagnostic_led c1_diagnostic_led c2_diagnostic_led c3_diagnostic_led c4_diagnostic_led c5_diagnostic_led c6_diagnostic_led}]
set_false_path -to [get_ports {c0_calib_complete c1_calib_complete c2_calib_complete c3_calib_complete c4_calib_complete c5_calib_complete c6_calib_complete}]
