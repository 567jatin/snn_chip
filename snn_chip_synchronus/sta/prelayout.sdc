create_clock -name core_clk -period 10.000 [get_ports clk]
set_input_delay  0.000 -clock core_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.000 -clock core_clk [all_outputs]
