#!/bin/bash
set -e
export PATH="/nix/store/4pyixb03xfwwy77zxxplrggxrmm9f57y-python3-3.11.9-env/bin:/nix/store/zzypcxbrgw1qink1l7fwgwpbk7fvdwpg-openroad/bin:/nix/store/9r0bh7sp051dpm8km8bqlb028anpd3v3-yosys/bin:/nix/store/kd8jmsgmli7f4wx53gvsmjwpb42igdqc-klayout/bin:/nix/store/kh8imbr9x09a76n3bww3s674l5jxvvxp-magic-vlsi/bin:/nix/store/d55q9bly3qrnbkif0sc6nmmvba3law57-netgen/bin:/nix/store/mky7gdsf8m3da333lxz2mjf2n3n1v1xy-verilator/bin:$PATH"
export PDK_ROOT="/home/test/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af"
export PDK="sky130A"

cd /home/test/snn_chip/snn_chip_synchronus/rtl2

openlane --run-tag balanced_encoder_pnr_20261029 \
         --from Checker.TrDRC \
         openlane_config.json
