set ::env(STEP_ID) OpenROAD.STAPostPNR
set ::env(TECH_LEF) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
set ::env(MACRO_LEFS) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef
set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd
set ::env(VDD_PIN) VPWR
set ::env(VDD_PIN_VOLTAGE) 1.80
set ::env(GND_PIN) VGND
set ::env(TECH_LEFS) "\"nom_*\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef \"min_*\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__min.tlef \"max_*\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__max.tlef"
set ::env(GPIO_PADS_LEF) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_io/lef/sky130_fd_io.lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_io/lef/sky130_ef_io.lef"
set ::env(GPIO_PADS_LEF_CORE_SIDE) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/custom_cells/lef/sky130_fd_io_core.lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/custom_cells/lef/sky130_ef_io_core.lef"
set ::env(GPIO_PADS_VERILOG) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_io/verilog/sky130_ef_io.v
set ::env(GPIO_PAD_CELLS) "\"sky130_fd_io*\" \"sky130_ef_io*\""
set ::env(PRIMARY_GDSII_STREAMOUT_TOOL) klayout
set ::env(DEFAULT_CORNER) nom_tt_025C_1v80
set ::env(STA_CORNERS) nom_tt_025C_1v80
set ::env(FP_TRACKS_INFO) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/sky130_fd_sc_hd/tracks.info
set ::env(FP_TAPCELL_DIST) 13
set ::env(FP_IO_HLAYER) met3
set ::env(FP_IO_VLAYER) met2
set ::env(RT_MIN_LAYER) met1
set ::env(RT_MAX_LAYER) met5
set ::env(SCL_GROUND_PINS) "VGND VNB"
set ::env(SCL_POWER_PINS) "VPWR VPB"
set ::env(TRISTATE_CELLS) "\"sky130_fd_sc_hd__ebuf*\""
set ::env(FILL_CELL) "\"sky130_fd_sc_hd__fill*\""
set ::env(DECAP_CELL) "sky130_ef_sc_hd__decap_12 sky130_fd_sc_hd__decap_8 sky130_fd_sc_hd__decap_6 sky130_fd_sc_hd__decap_4 sky130_fd_sc_hd__decap_3"
set ::env(LIB) "\"*_tt_025C_1v80\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib \"*_ss_100C_1v60\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib \"*_ff_n40C_1v95\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib"
set ::env(CELL_LEFS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_ef_sc_hd.lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set ::env(CELL_GDS) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds
set ::env(CELL_VERILOG_MODELS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
set ::env(CELL_BB_VERILOG_MODELS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd__blackbox.v /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd__blackbox_pp.v"
set ::env(CELL_SPICE_MODELS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__decap_12.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_12.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_4.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_8.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice"
set ::env(SYNTH_EXCLUDED_CELL_FILE) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/sky130_fd_sc_hd/no_synth.cells
set ::env(PNR_EXCLUDED_CELL_FILE) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/sky130_fd_sc_hd/drc_exclude.cells
set ::env(OUTPUT_CAP_LOAD) 33.442
set ::env(MAX_FANOUT_CONSTRAINT) 10
set ::env(MAX_TRANSITION_CONSTRAINT) 0.75
set ::env(MAX_CAPACITANCE_CONSTRAINT) 0.2
set ::env(CLOCK_UNCERTAINTY_CONSTRAINT) 0.25
set ::env(CLOCK_TRANSITION_CONSTRAINT) 0.1499999999999999944488848768742172978818416595458984375
set ::env(TIME_DERATING_CONSTRAINT) 5
set ::env(IO_DELAY_CONSTRAINT) 20
set ::env(SYNTH_DRIVING_CELL) sky130_fd_sc_hd__inv_2/Y
set ::env(SYNTH_TIEHI_CELL) sky130_fd_sc_hd__conb_1/HI
set ::env(SYNTH_TIELO_CELL) sky130_fd_sc_hd__conb_1/LO
set ::env(SYNTH_BUFFER_CELL) sky130_fd_sc_hd__buf_2/A/X
set ::env(WELLTAP_CELL) sky130_fd_sc_hd__tapvpwrvgnd_1
set ::env(ENDCAP_CELL) sky130_fd_sc_hd__decap_3
set ::env(PLACE_SITE) unithd
set ::env(CELL_PAD_EXCLUDE) "\"sky130_fd_sc_hd__tap*\" \"sky130_fd_sc_hd__decap*\" \"sky130_ef_sc_hd__decap*\" \"sky130_fd_sc_hd__fill*\""
set ::env(DIODE_CELL) sky130_fd_sc_hd__diode_2/DIODE
set ::env(DESIGN_NAME) neuromorphic_top
set ::env(CLOCK_PERIOD) 10.0
set ::env(CLOCK_PORT) clk
set ::env(MACROS) "sky130_sram_1kbyte_1rw1r_8x1024_8 \"gds /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_8x1024_8.gds lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef instances \\\"\\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[0].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"100 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[0].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"580 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[1].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1110 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[1].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1590 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[2].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"100 620\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[2].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"580 620\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[3].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1110 620\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[3].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1590 620\\\\\\\\\\\\\\\" orientation N\\\\\\\"\\\" vh ./sky130_sram_macro_blackbox.v nl \\\"\\\" pnl \\\"\\\" spef \\\"\\\" lib \\\"\\\\\\\"*_tt_025C_1v80\\\\\\\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_8x1024_8_TT_1p8V_25C.lib\\\" spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/spice/sky130_sram_1kbyte_1rw1r_8x1024_8.spice sdf \\\"\\\" json_h None\""
set ::env(EXTRA_SPICE_MODELS) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/spice/sky130_sram_1kbyte_1rw1r_8x1024_8.spice
set ::env(FALLBACK_SDC_FILE) /nix/store/4pyixb03xfwwy77zxxplrggxrmm9f57y-python3-3.11.9-env/lib/python3.11/site-packages/openlane/scripts/base.sdc
set ::env(PDN_CONNECT_MACROS_TO_GRID) 1
set ::env(PDN_MACRO_CONNECTIONS) "\"u_weight_sram.*u_lo VPWR VGND vccd1 vssd1\" \"u_weight_sram.*u_hi VPWR VGND vccd1 vssd1\""
set ::env(PDN_ENABLE_GLOBAL_CONNECTIONS) 1
set ::env(PNR_SDC_FILE) ./neuromorphic_top.sdc
set ::env(STA_MACRO_PRIORITIZE_NL) 1
set ::env(SIGNOFF_SDC_FILE) ./neuromorphic_top.sdc
set ::env(CURRENT_NETLIST) /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/53-openroad-fillinsertion/neuromorphic_top.nl.v
set ::env(CURRENT_SPEF) "\"nom_*\" /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/55-openroad-rcx/nom/neuromorphic_top.nom.spef \"min_*\" /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/55-openroad-rcx/min/neuromorphic_top.min.spef \"max_*\" /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/55-openroad-rcx/max/neuromorphic_top.max.spef"
set ::env(CURRENT_ODB) /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/54-odb-cellfrequencytables/neuromorphic_top.odb
set ::env(SAVE_SDC) /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/56-openroad-stapostpnr/neuromorphic_top.sdc
set ::env(OPENLANE_SDC_IDEAL_CLOCKS) 0
set ::env(STEP_ID) OpenROAD.STAPostPNR
set ::env(TECH_LEF) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
set ::env(MACRO_LEFS) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef
set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd
set ::env(VDD_PIN) VPWR
set ::env(VDD_PIN_VOLTAGE) 1.80
set ::env(GND_PIN) VGND
set ::env(TECH_LEFS) "\"nom_*\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef \"min_*\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__min.tlef \"max_*\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__max.tlef"
set ::env(GPIO_PADS_LEF) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_io/lef/sky130_fd_io.lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_io/lef/sky130_ef_io.lef"
set ::env(GPIO_PADS_LEF_CORE_SIDE) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/custom_cells/lef/sky130_fd_io_core.lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/custom_cells/lef/sky130_ef_io_core.lef"
set ::env(GPIO_PADS_VERILOG) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_io/verilog/sky130_ef_io.v
set ::env(GPIO_PAD_CELLS) "\"sky130_fd_io*\" \"sky130_ef_io*\""
set ::env(PRIMARY_GDSII_STREAMOUT_TOOL) klayout
set ::env(DEFAULT_CORNER) nom_tt_025C_1v80
set ::env(STA_CORNERS) nom_tt_025C_1v80
set ::env(FP_TRACKS_INFO) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/sky130_fd_sc_hd/tracks.info
set ::env(FP_TAPCELL_DIST) 13
set ::env(FP_IO_HLAYER) met3
set ::env(FP_IO_VLAYER) met2
set ::env(RT_MIN_LAYER) met1
set ::env(RT_MAX_LAYER) met5
set ::env(SCL_GROUND_PINS) "VGND VNB"
set ::env(SCL_POWER_PINS) "VPWR VPB"
set ::env(TRISTATE_CELLS) "\"sky130_fd_sc_hd__ebuf*\""
set ::env(FILL_CELL) "\"sky130_fd_sc_hd__fill*\""
set ::env(DECAP_CELL) "sky130_ef_sc_hd__decap_12 sky130_fd_sc_hd__decap_8 sky130_fd_sc_hd__decap_6 sky130_fd_sc_hd__decap_4 sky130_fd_sc_hd__decap_3"
set ::env(LIB) "\"*_tt_025C_1v80\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib \"*_ss_100C_1v60\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ss_100C_1v60.lib \"*_ff_n40C_1v95\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib"
set ::env(CELL_LEFS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_ef_sc_hd.lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef"
set ::env(CELL_GDS) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/gds/sky130_fd_sc_hd.gds
set ::env(CELL_VERILOG_MODELS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
set ::env(CELL_BB_VERILOG_MODELS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd__blackbox.v /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd__blackbox_pp.v"
set ::env(CELL_SPICE_MODELS) "/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__decap_12.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_12.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_4.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_ef_sc_hd__fill_8.spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice"
set ::env(SYNTH_EXCLUDED_CELL_FILE) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/sky130_fd_sc_hd/no_synth.cells
set ::env(PNR_EXCLUDED_CELL_FILE) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/openlane/sky130_fd_sc_hd/drc_exclude.cells
set ::env(OUTPUT_CAP_LOAD) 33.442
set ::env(MAX_FANOUT_CONSTRAINT) 10
set ::env(MAX_TRANSITION_CONSTRAINT) 0.75
set ::env(MAX_CAPACITANCE_CONSTRAINT) 0.2
set ::env(CLOCK_UNCERTAINTY_CONSTRAINT) 0.25
set ::env(CLOCK_TRANSITION_CONSTRAINT) 0.1499999999999999944488848768742172978818416595458984375
set ::env(TIME_DERATING_CONSTRAINT) 5
set ::env(IO_DELAY_CONSTRAINT) 20
set ::env(SYNTH_DRIVING_CELL) sky130_fd_sc_hd__inv_2/Y
set ::env(SYNTH_TIEHI_CELL) sky130_fd_sc_hd__conb_1/HI
set ::env(SYNTH_TIELO_CELL) sky130_fd_sc_hd__conb_1/LO
set ::env(SYNTH_BUFFER_CELL) sky130_fd_sc_hd__buf_2/A/X
set ::env(WELLTAP_CELL) sky130_fd_sc_hd__tapvpwrvgnd_1
set ::env(ENDCAP_CELL) sky130_fd_sc_hd__decap_3
set ::env(PLACE_SITE) unithd
set ::env(CELL_PAD_EXCLUDE) "\"sky130_fd_sc_hd__tap*\" \"sky130_fd_sc_hd__decap*\" \"sky130_ef_sc_hd__decap*\" \"sky130_fd_sc_hd__fill*\""
set ::env(DIODE_CELL) sky130_fd_sc_hd__diode_2/DIODE
set ::env(DESIGN_NAME) neuromorphic_top
set ::env(CLOCK_PERIOD) 10.0
set ::env(CLOCK_PORT) clk
set ::env(MACROS) "sky130_sram_1kbyte_1rw1r_8x1024_8 \"gds /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_8x1024_8.gds lef /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_8x1024_8.lef instances \\\"\\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[0].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"100 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[0].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"580 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[1].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1110 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[1].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1590 100\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[2].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"100 620\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[2].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"580 620\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[3].u_lo\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1110 620\\\\\\\\\\\\\\\" orientation N\\\\\\\" \\\\\\\"u_weight_sram.g_bank\\\\\\\\\\\\\\\[3].u_hi\\\\\\\" \\\\\\\"location \\\\\\\\\\\\\\\"1590 620\\\\\\\\\\\\\\\" orientation N\\\\\\\"\\\" vh ./sky130_sram_macro_blackbox.v nl \\\"\\\" pnl \\\"\\\" spef \\\"\\\" lib \\\"\\\\\\\"*_tt_025C_1v80\\\\\\\" /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/lib/sky130_sram_1kbyte_1rw1r_8x1024_8_TT_1p8V_25C.lib\\\" spice /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/spice/sky130_sram_1kbyte_1rw1r_8x1024_8.spice sdf \\\"\\\" json_h None\""
set ::env(EXTRA_SPICE_MODELS) /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_sram_macros/spice/sky130_sram_1kbyte_1rw1r_8x1024_8.spice
set ::env(FALLBACK_SDC_FILE) /nix/store/4pyixb03xfwwy77zxxplrggxrmm9f57y-python3-3.11.9-env/lib/python3.11/site-packages/openlane/scripts/base.sdc
set ::env(PDN_CONNECT_MACROS_TO_GRID) 1
set ::env(PDN_MACRO_CONNECTIONS) "\"u_weight_sram.*u_lo VPWR VGND vccd1 vssd1\" \"u_weight_sram.*u_hi VPWR VGND vccd1 vssd1\""
set ::env(PDN_ENABLE_GLOBAL_CONNECTIONS) 1
set ::env(PNR_SDC_FILE) ./neuromorphic_top.sdc
set ::env(STA_MACRO_PRIORITIZE_NL) 1
set ::env(SIGNOFF_SDC_FILE) ./neuromorphic_top.sdc
set ::env(CURRENT_NETLIST) /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/53-openroad-fillinsertion/neuromorphic_top.nl.v
set ::env(CURRENT_SPEF) "\"nom_*\" /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/55-openroad-rcx/nom/neuromorphic_top.nom.spef \"min_*\" /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/55-openroad-rcx/min/neuromorphic_top.min.spef \"max_*\" /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/55-openroad-rcx/max/neuromorphic_top.max.spef"
set ::env(CURRENT_ODB) /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/54-odb-cellfrequencytables/neuromorphic_top.odb
set ::env(SAVE_SDC) /home/test/snn_chip/snn_chip_synchronus/rtl2/runs/signoff_clean_20261030/56-openroad-stapostpnr/neuromorphic_top.sdc
set ::env(OPENLANE_SDC_IDEAL_CLOCKS) 0
