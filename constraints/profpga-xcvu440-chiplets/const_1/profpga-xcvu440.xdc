# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#              Bitstream Configuration                     -
#-----------------------------------------------------------
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]

#-----------------------------------------------------------
#              Clock Pins                                  -
#-----------------------------------------------------------

# Reference clocks pins are connected to DDR4 cards and to the DMBI interface


#-----------------------------------------------------------
#              UART                                        -
#-----------------------------------------------------------

# UART_RTS_B
set_property PACKAGE_PIN BD26 [get_ports UART_RTS_B]

# UART_CTS_B
set_property PACKAGE_PIN BF27 [get_ports UART_CTS_B]

# UART_TXD
set_property PACKAGE_PIN BE27 [get_ports UART_TXD]

# UART_RXD
set_property PACKAGE_PIN BE26 [get_ports UART_RXD]

set_property IOSTANDARD LVCMOS18 [get_ports {UART_*}]

#-----------------------------------------------------------
#              LEDs                                        -
#-----------------------------------------------------------

# {LED_RED}
set_property PACKAGE_PIN W43 [get_ports LED_RED]

# {LED_GREEN}
set_property PACKAGE_PIN Y43 [get_ports LED_GREEN]

# {LED_BLUE}
set_property PACKAGE_PIN Y42 [get_ports LED_BLUE]

# {LED_YELLOW}
set_property PACKAGE_PIN Y41 [get_ports LED_YELLOW]

set_property IOSTANDARD LVCMOS18 [get_ports {LED_*}]

#-----------------------------------------------------------
#              Diagnostic LEDs                             -
#-----------------------------------------------------------

# {ta1_eb1_LED_GREEN1}
set_property IOSTANDARD LVCMOS12 [get_ports c0_calib_complete]
set_property DRIVE 8 [get_ports c0_calib_complete]
set_property PACKAGE_PIN AP41 [get_ports c0_calib_complete]

# {ta1_eb1_LED_YELLOW2}
set_property IOSTANDARD LVCMOS12 [get_ports c0_diagnostic_led]
set_property DRIVE 8 [get_ports c0_diagnostic_led]
set_property PACKAGE_PIN AW41 [get_ports c0_diagnostic_led]

#-----------------------------------------------------------
#              Reset                                       -
#-----------------------------------------------------------

# {ta1_eb1_BUTTON3}
set_property IOSTANDARD LVCMOS12 [get_ports reset]
set_property DRIVE 8 [get_ports reset]
set_property PACKAGE_PIN AM41 [get_ports reset]


#-----------------------------------------------------------
#              Clock                                       -
#-----------------------------------------------------------

# {CLK1_N}
set_property IOSTANDARD LVDS [get_ports {esp_clk_n}]
set_property PACKAGE_PIN BC28 [get_ports {esp_clk_n}]

# {CLK1_P}
set_property IOSTANDARD LVDS [get_ports {esp_clk_p}]
set_property PACKAGE_PIN BC27 [get_ports {esp_clk_p}]

# {CLK2_N}
set_property IOSTANDARD LVDS [get_ports {d2d_clk_n}]
set_property PACKAGE_PIN Y48 [get_ports {d2d_clk_n}]

# {CLK2_P}
set_property IOSTANDARD LVDS [get_ports {d2d_clk_p}]
set_property PACKAGE_PIN Y47 [get_ports {d2d_clk_p}]

#-----------------------------------------------------------
#              Timing constraints                          -
#-----------------------------------------------------------

create_clock -period 11.2 [get_ports c0_sys_clk_p]

create_clock -period 12.8 [get_ports esp_clk_p]
create_clock -period 12.8 [get_ports d2d_clk_p]
create_clock -period 12.8 -name c0_rx_clk [get_ports c0_cable_clk_p_rcv] 

create_generated_clock -name c0_tx_fwd_clk -source [get_ports d2d_clk_p] -divide_by 1 [get_ports c0_cable_clk_p]

# Recover elaborated clock name
set clkm_elab [get_clocks -of_objects [get_nets clkm]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set d2d_cable_input_delay_max   0.5
set d2d_cable_input_delay_min  -0.5

set c0_d2d_cable_output_delay_max  1.6
set c0_d2d_cable_output_delay_min  0.8

set c0_cable_io_lower_ports [get_ports {c0_cable_io_data[0] c0_cable_io_data[1] c0_cable_io_data[2] c0_cable_io_data[3] c0_cable_io_data[4] c0_cable_io_data[5] c0_cable_io_data[6] c0_cable_io_data[7] c0_cable_io_data[8] c0_cable_io_data[9] c0_cable_io_data[10] c0_cable_io_data[11] c0_cable_io_data[12] c0_cable_io_data[13] c0_cable_io_data[14] c0_cable_io_data[15] c0_cable_io_data[16] c0_cable_io_data[17] c0_cable_io_data[18] c0_cable_io_data[19] c0_cable_io_data[20] c0_cable_io_data[21] c0_cable_io_data[22] c0_cable_io_data[23] c0_cable_io_data[24] c0_cable_io_data[25] c0_cable_io_data[26] c0_cable_io_data[27] c0_cable_io_data[28] c0_cable_io_data[29] c0_cable_io_data[30] c0_cable_io_data[31] c0_cable_io_data[32] c0_cable_io_data[33] c0_cable_io_data[34] c0_cable_io_data[35] c0_cable_io_data[36] c0_cable_io_data[37] c0_cable_io_data[38] c0_cable_io_data[39] c0_cable_io_data[40] c0_cable_io_data[41] c0_cable_io_data[42] c0_cable_io_data[43] c0_cable_io_data[44] c0_cable_io_data[45] c0_cable_io_data[46] c0_cable_io_data[47] c0_cable_io_data[48] c0_cable_io_data[49] c0_cable_io_data[50] c0_cable_io_data[51] c0_cable_io_data[52] c0_cable_io_data[53] c0_cable_io_data[54] c0_cable_io_data[55] c0_cable_io_data[56] c0_cable_io_data[57] c0_cable_io_data[58] c0_cable_io_data[59] c0_cable_io_data[60] c0_cable_io_data[61] c0_cable_io_data[62] c0_cable_io_data[63] c0_cable_io_data[64] c0_cable_io_data[65] c0_cable_io_data[66] c0_cable_io_data[67]}]
set c0_cable_io_upper_ports [get_ports {c0_cable_io_data[68] c0_cable_io_data[69] c0_cable_io_data[70] c0_cable_io_data[71] c0_cable_io_data[72] c0_cable_io_data[73] c0_cable_io_data[74] c0_cable_io_data[75] c0_cable_io_data[76] c0_cable_io_data[77] c0_cable_io_data[78] c0_cable_io_data[79] c0_cable_io_data[80] c0_cable_io_data[81] c0_cable_io_data[82] c0_cable_io_data[83] c0_cable_io_data[84] c0_cable_io_data[85] c0_cable_io_data[86] c0_cable_io_data[87] c0_cable_io_data[88] c0_cable_io_data[89] c0_cable_io_data[90] c0_cable_io_data[91] c0_cable_io_data[92] c0_cable_io_data[93] c0_cable_io_data[94] c0_cable_io_data[95] c0_cable_io_data[96] c0_cable_io_data[97] c0_cable_io_data[98] c0_cable_io_data[99] c0_cable_io_data[100] c0_cable_io_data[101] c0_cable_io_data[102] c0_cable_io_data[103] c0_cable_io_data[104] c0_cable_io_data[105] c0_cable_io_data[106] c0_cable_io_data[107] c0_cable_io_data[108] c0_cable_io_data[109] c0_cable_io_data[110] c0_cable_io_data[111] c0_cable_io_data[112] c0_cable_io_data[113] c0_cable_io_data[114] c0_cable_io_data[115] c0_cable_io_data[116] c0_cable_io_data[117] c0_cable_io_data[118] c0_cable_io_data[119] c0_cable_io_data[120] c0_cable_io_data[121] c0_cable_io_data[122] c0_cable_io_data[123] c0_cable_io_data[124] c0_cable_io_data[125] c0_cable_io_data[126] c0_cable_io_data[127] c0_cable_io_data[128] c0_cable_io_data[129] c0_cable_io_data[130] c0_cable_io_data[131] c0_cable_io_data[132] c0_cable_io_data[133] c0_cable_io_data[134] c0_cable_io_data[135]}]

# Previous port split kept for reference.
# set c0_cable_rx_ports $c0_cable_io_upper_ports
# set c0_cable_tx_ports $c0_cable_io_lower_ports
#
# BOARD_NUM=1/3 RTL drives TX on c0_cable_io_data[0:67] and samples RX on [68:135].
set c0_cable_rx_ports $c0_cable_io_upper_ports
set c0_cable_tx_ports $c0_cable_io_lower_ports

set_output_delay -clock [get_clocks c0_tx_fwd_clk] -max $c0_d2d_cable_output_delay_max $c0_cable_tx_ports
set_output_delay -clock [get_clocks c0_tx_fwd_clk] -min $c0_d2d_cable_output_delay_min $c0_cable_tx_ports

set_input_delay -clock [get_clocks c0_rx_clk] -max $d2d_cable_input_delay_max $c0_cable_rx_ports
set_input_delay -clock [get_clocks c0_rx_clk] -min $d2d_cable_input_delay_min $c0_cable_rx_ports

set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {NAME =~ *evt_gray_ff1* && IS_SEQUENTIAL}]
set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {NAME =~ *evt_gray_ff2* && IS_SEQUENTIAL}]
set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {NAME =~ *d2d_ack_evt_gray_meta* && IS_SEQUENTIAL}]
set_property ASYNC_REG TRUE [get_cells -hierarchical -filter {NAME =~ *d2d_ack_evt_gray_sync* && IS_SEQUENTIAL}]

set_property SHREG_EXTRACT NO [get_cells -hierarchical -filter {NAME =~ *evt_gray_ff1* && IS_SEQUENTIAL}]
set_property SHREG_EXTRACT NO [get_cells -hierarchical -filter {NAME =~ *evt_gray_ff2* && IS_SEQUENTIAL}]
set_property SHREG_EXTRACT NO [get_cells -hierarchical -filter {NAME =~ *d2d_ack_evt_gray_meta* && IS_SEQUENTIAL}]
set_property SHREG_EXTRACT NO [get_cells -hierarchical -filter {NAME =~ *d2d_ack_evt_gray_sync* && IS_SEQUENTIAL}]


# Both memory controllers impose their user clock. Make them asynchronous
set_clock_groups -asynchronous \
    -group [get_clocks $refclk_elab] \
    -group [get_clocks $clkm_elab]   \
    -group [get_clocks -include_generated_clocks d2d_clk_p] \
    -group [get_clocks -include_generated_clocks c0_rx_clk]
#-----------------------------------------------------------
#              False Paths                                 -
#-----------------------------------------------------------
set_false_path -from [get_ports reset]
set_false_path -to [get_ports LED_YELLOW]
set_false_path -to [get_ports LED_BLUE]
set_false_path -to [get_ports LED_GREEN]
set_false_path -to [get_ports LED_RED]
