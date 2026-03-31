# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

set eth_rx_ports [get_ports {erxd[*] erx_dv erx_er erx_col erx_crs}]
set eth_tx_ports [get_ports {etxd[*] etx_en etx_er}]
set eth_mgmt_ports [get_ports {emdio emdc}]

# RX Clock
create_clock -period 40.000 [get_ports erx_clk]

set_propagated_clock [get_clocks erx_clk]
# Previous broad board-level input delay kept for reference.
# set_input_delay -clock [get_clocks erx_clk] 10 [all_inputs]
set_input_delay -clock [get_clocks erx_clk] 10 $eth_rx_ports

# TX Clock
create_clock -period 40.000 [get_ports etx_clk]
set_propagated_clock [get_clocks etx_clk]
# Previous broad board-level output/input delays kept for reference.
# set_output_delay -clock [get_clocks etx_clk] 5 [all_outputs]
# set_input_delay  -clock [get_clocks etx_clk] 10 [all_inputs]
set_output_delay -clock [get_clocks etx_clk] 5 $eth_tx_ports

# MDIO/MDC are management/status pins, not synchronous to the RMII TX/RX clocks.
set_false_path -through $eth_mgmt_ports

# RX/TX paths
set_max_delay -from [get_clocks -include_generated_clocks etx_clk] -to [get_clocks erx_clk] 40.000
set_max_delay -from [get_clocks erx_clk] -to [get_clocks -include_generated_clocks etx_clk] 40.000

# Other domains
set clkm_elab [get_clocks -of_objects [get_nets {clkm}]]
set clkm1_elab [get_clocks -of_objects [get_nets clkm_1]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set clkm3_elab [get_clocks -of_objects [get_nets clkm_3]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm1_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm3_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $refclk_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks -include_generated_clocks c0_rx_clk]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks -include_generated_clocks d2d_clk_p]

set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm1_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm3_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $refclk_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks -include_generated_clocks profpga_clk0_p]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks {*_sys_clk_p}]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks -include_generated_clocks c0_rx_clk]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks -include_generated_clocks d2d_clk_p]
