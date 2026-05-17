# Copyright (c) 2011-2024 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

#-----------------------------------------------------------
#                         ETHERNET
#-----------------------------------------------------------

set eth_rx_ports [get_ports {erxd[*] erx_dv erx_er erx_col erx_crs}]
set eth_tx_ports [get_ports {etxd[*] etx_en etx_er}]
set eth_mgmt_ports [get_ports {emdio emdc reset_o2}]

# RX Clock
create_clock -period 40.000 [get_ports erx_clk]

set_propagated_clock [get_clocks erx_clk]
set_input_delay -clock [get_clocks erx_clk] 10 $eth_rx_ports

# TX Clock
create_clock -period 40.000 [get_ports etx_clk]
set_propagated_clock [get_clocks etx_clk]
set_output_delay -clock [get_clocks etx_clk] 5 $eth_tx_ports

# MDIO/MDC/reset are not synchronous to the RMII RX/TX clocks.
set_false_path -through $eth_mgmt_ports

# RX/TX paths
# set_max_delay -from [get_clocks -include_generated_clocks etx_clk] -to [get_clocks erx_clk] 40.000
# set_max_delay -from [get_clocks erx_clk] -to [get_clocks -include_generated_clocks etx_clk] 40.000
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks erx_clk] -group [get_clocks -include_generated_clocks etx_clk]

# GRETH samples RX status into the TX clock domain with 2-FF synchronizers.
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -filter {NAME =~ *tx_rmii0.tx0/gmiimode0.r_reg*col* && IS_SEQUENTIAL}]
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -filter {NAME =~ *tx_rmii0.tx0/gmiimode0.r_reg*crs* && IS_SEQUENTIAL}]
set_property ASYNC_REG TRUE [get_cells -quiet -hierarchical -filter {NAME =~ *tx_rmii0.tx0/gmiimode0.r_reg*fullduplex* && IS_SEQUENTIAL}]
set_property SHREG_EXTRACT NO [get_cells -quiet -hierarchical -filter {NAME =~ *tx_rmii0.tx0/gmiimode0.r_reg*col* && IS_SEQUENTIAL}]
set_property SHREG_EXTRACT NO [get_cells -quiet -hierarchical -filter {NAME =~ *tx_rmii0.tx0/gmiimode0.r_reg*crs* && IS_SEQUENTIAL}]
set_property SHREG_EXTRACT NO [get_cells -quiet -hierarchical -filter {NAME =~ *tx_rmii0.tx0/gmiimode0.r_reg*fullduplex* && IS_SEQUENTIAL}]

# Other domains
set clkm_elab [get_clocks -of_objects [get_nets {clkm}]]
set clkm1_elab [get_clocks -of_objects [get_nets clkm_1]]
set clkm2_elab [get_clocks -of_objects [get_nets clkm_2]]
set clkm3_elab [get_clocks -of_objects [get_nets clkm_3]]
set clkm4_elab [get_clocks -of_objects [get_nets clkm_4]]
set clkm5_elab [get_clocks -of_objects [get_nets clkm_5]]
set clkm6_elab [get_clocks -of_objects [get_nets clkm_6]]
#set clkm7_elab [get_clocks -of_objects [get_nets clkm_7]]
set refclk_elab [get_clocks -of_objects [get_nets chip_refclk]]

set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm1_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm3_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm4_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm5_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm6_elab]
#set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm7_elab]
set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $refclk_elab]

set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm1_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm2_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm3_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm4_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm5_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $clkm6_elab]
#set_clock_groups -asynchronous -group [get_clocks erx_clk] -group [get_clocks $clkm7_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks $refclk_elab]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks -include_generated_clocks profpga_clk0_p]
set_clock_groups -asynchronous -group [get_clocks etx_clk] -group [get_clocks {*_sys_clk_p}]

# Cable receive clocks come from remote FPGA d2d_clk_p domains.
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks d2d_clk_p] -group [get_clocks erx_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks c0_rx_clk] -group [get_clocks erx_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks c1_rx_clk] -group [get_clocks erx_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks d2d_clk_p] -group [get_clocks etx_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks c0_rx_clk] -group [get_clocks etx_clk]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks c1_rx_clk] -group [get_clocks etx_clk]
