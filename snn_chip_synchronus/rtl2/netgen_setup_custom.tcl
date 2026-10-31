# Custom Netgen setup script for neuromorphic_top on SKY130A
source /home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.tech/netgen/sky130A_setup.tcl

# Unconditionally ignore physical-only fill, decap, tap, and diode cells in both circuits
foreach cell $cells1 {
    if {[regexp {sky130_fd_sc_[^_]+__decap_[[:digit:]]+} $cell match]} {
        ignore class "-circuit1 $cell"
    }
    if {[regexp {sky130_ef_sc_[^_]+__decap_[[:digit:]]+} $cell match]} {
        ignore class "-circuit1 $cell"
    }
    if {[regexp {sky130_fd_sc_[^_]+__fill_[[:digit:]]+} $cell match]} {
        ignore class "-circuit1 $cell"
    }
    if {[regexp {sky130_ef_sc_[^_]+__fill_[[:digit:]]+} $cell match]} {
        ignore class "-circuit1 $cell"
    }
    if {[regexp {sky130_fd_sc_[^_]+__tapvpwrvgnd_[[:digit:]]+} $cell match]} {
        ignore class "-circuit1 $cell"
    }
    if {[regexp {sky130_fd_sc_[^_]+__diode_[[:digit:]]+} $cell match]} {
        ignore class "-circuit1 $cell"
    }
}

foreach cell $cells2 {
    if {[regexp {sky130_fd_sc_[^_]+__decap_[[:digit:]]+} $cell match]} {
        ignore class "-circuit2 $cell"
    }
    if {[regexp {sky130_ef_sc_[^_]+__decap_[[:digit:]]+} $cell match]} {
        ignore class "-circuit2 $cell"
    }
    if {[regexp {sky130_fd_sc_[^_]+__fill_[[:digit:]]+} $cell match]} {
        ignore class "-circuit2 $cell"
    }
    if {[regexp {sky130_ef_sc_[^_]+__fill_[[:digit:]]+} $cell match]} {
        ignore class "-circuit2 $cell"
    }
    if {[regexp {sky130_fd_sc_[^_]+__tapvpwrvgnd_[[:digit:]]+} $cell match]} {
        ignore class "-circuit2 $cell"
    }
    if {[regexp {sky130_fd_sc_[^_]+__diode_[[:digit:]]+} $cell match]} {
        ignore class "-circuit2 $cell"
    }
}

# Equate top-level power, ground, clock, and reset signals
equate signals "-circuit1 neuromorphic_top VPWR" "-circuit2 neuromorphic_top VPWR"
equate signals "-circuit1 neuromorphic_top VGND" "-circuit2 neuromorphic_top VGND"
equate signals "-circuit1 neuromorphic_top clk"  "-circuit2 neuromorphic_top clk"
equate signals "-circuit1 neuromorphic_top rst_n" "-circuit2 neuromorphic_top rst_n"

# Equate all top-level pins
equate pins "-circuit1 neuromorphic_top" "-circuit2 neuromorphic_top"
