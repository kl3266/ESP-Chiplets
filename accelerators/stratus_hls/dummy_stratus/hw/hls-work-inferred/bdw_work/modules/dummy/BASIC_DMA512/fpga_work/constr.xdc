create_clock -name {clk} [get_ports {clk}]  -period 10.0
set_max_delay -datapath_only -from [all_inputs] -to [all_clocks] 9.24
set_max_delay -datapath_only -to [all_outputs] -from [all_clocks] 9.463
