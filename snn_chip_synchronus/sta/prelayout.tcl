read_liberty $::env(SC_LIB)
read_liberty $::env(SRAM_LIB)
read_verilog rtl/build_sky130/neuromorphic_top_sky130.v
link_design neuromorphic_top
read_sdc sta/prelayout.sdc
report_checks -path_delay max -format full_clock_expanded -group_path_count 20
report_checks -path_delay min -format full_clock_expanded -group_path_count 20
report_worst_slack -max
report_worst_slack -min
exit
