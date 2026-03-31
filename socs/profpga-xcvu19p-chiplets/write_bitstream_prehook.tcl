# Downgrade unconstrained-I/O DRCs for satellite boards that intentionally
# leave unused DDR/UART/ETH top-level ports unconstrained.
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
