#!/usr/bin/env bash
# Decompress Tapeout Deliverables for Local CAD Tools (KLayout, Magic, OpenROAD)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FINAL_DIR="${SCRIPT_DIR}/snn_chip_synchronus/rtl2/final"

echo "=== Decompressing Tapeout Signoff Deliverables ==="

if [ -f "${FINAL_DIR}/klayout_gds/neuromorphic_top.klayout.gds.gz" ]; then
    echo "Decompressing GDSII (143 MB)..."
    gzip -d -k -f "${FINAL_DIR}/klayout_gds/neuromorphic_top.klayout.gds.gz"
fi

if [ -f "${FINAL_DIR}/def/neuromorphic_top.def.gz" ]; then
    echo "Decompressing DEF (139 MB)..."
    gzip -d -k -f "${FINAL_DIR}/def/neuromorphic_top.def.gz"
fi

if [ -f "${FINAL_DIR}/spef/nom/neuromorphic_top.nom.spef.gz" ]; then
    echo "Decompressing Nominal SPEF (120 MB)..."
    gzip -d -k -f "${FINAL_DIR}/spef/nom/neuromorphic_top.nom.spef.gz"
fi

if [ -f "${FINAL_DIR}/spef/min/neuromorphic_top.min.spef.gz" ]; then
    echo "Decompressing Min SPEF..."
    gzip -d -k -f "${FINAL_DIR}/spef/min/neuromorphic_top.min.spef.gz"
fi

if [ -f "${FINAL_DIR}/spef/max/neuromorphic_top.max.spef.gz" ]; then
    echo "Decompressing Max SPEF..."
    gzip -d -k -f "${FINAL_DIR}/spef/max/neuromorphic_top.max.spef.gz"
fi

if [ -f "${FINAL_DIR}/pnl/neuromorphic_top.pnl.v.gz" ]; then
    echo "Decompressing Powered Netlist (81 MB)..."
    gzip -d -k -f "${FINAL_DIR}/pnl/neuromorphic_top.pnl.v.gz"
fi

if [ -f "${FINAL_DIR}/sdf/nom_tt_025C_1v80/neuromorphic_top__nom_tt_025C_1v80.sdf.gz" ]; then
    echo "Decompressing SDF (46 MB)..."
    gzip -d -k -f "${FINAL_DIR}/sdf/nom_tt_025C_1v80/neuromorphic_top__nom_tt_025C_1v80.sdf.gz"
fi

if [ -f "${FINAL_DIR}/spice/neuromorphic_top.spice.gz" ]; then
    echo "Decompressing Extracted SPICE (48 MB)..."
    gzip -d -k -f "${FINAL_DIR}/spice/neuromorphic_top.spice.gz"
fi

echo "=== Decompression Complete ==="
echo "GDS: ${FINAL_DIR}/klayout_gds/neuromorphic_top.klayout.gds"
echo "DEF: ${FINAL_DIR}/def/neuromorphic_top.def"
echo "SPEF: ${FINAL_DIR}/spef/nom/neuromorphic_top.nom.spef"
