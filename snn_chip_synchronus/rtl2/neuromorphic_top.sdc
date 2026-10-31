
create_clock -name core_clk -period 10.000 [get_ports clk]
set_clock_uncertainty -setup 0.700 [get_clocks core_clk]
set_clock_uncertainty -hold  0.150 [get_clocks core_clk]

set_input_delay  3.000 -clock core_clk [get_ports {ext_aer_req ext_aer_neuron_id[*] out_aer_ack}]
set_output_delay 3.000 -clock core_clk [get_ports {ext_aer_ack out_aer_req out_aer_addr[*] out_aer_overflow}]

set_input_delay  1.000 -clock core_clk [get_ports {rst_n cfg_w_wr_en cfg_w_addr[*] cfg_w_data[*] w_mon_rd_en w_mon_addr[*] ext_syn_valid ext_syn_neuron_id[*] ext_syn_current[*]}]
set_output_delay 1.000 -clock core_clk [get_ports {cfg_w_ready w_mon_data[*] w_mon_ready ext_syn_ready neuron_spikes[*] current_timestamp[*] stdp_ready stdp_event_overflow}]

set_input_transition 0.500 [all_inputs -no_clocks]
set_load 0.050 [all_outputs]
