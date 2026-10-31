# 64-Neuron Clocked Neuromorphic SNN Processor (SKY130A Tapeout Signoff)

An advanced 64-neuron, 4096-synapse Spiking Neural Network (SNN) processor hardened and signed off for silicon fabrication on the SkyWater 130 nm (`sky130A`) CMOS technology node with complete post-route timing closure at 100 MHz, clean Netgen LVS, and zero KLayout DRC violations.

---

## 1. Key Technical Accomplishments & Signoff Status

The synchronous design in `snn_chip_synchronus/rtl2` has completed all 78 physical design, extraction, and signoff stages in OpenLane 2 Classic under nominal conditions (`nom_tt_025C_1v80`, 1.8 V core supply):

| Category | Requirement / Spec | Signoff Result | Status |
| :--- | :--- | :--- | :---: |
| **Foundry DRC** | KLayout DRC (`sky130A.drc`) | **0 violations across all mask layers** | **PASSED ✅** |
| **Netgen LVS** | Device & Net Matching | **80,739 / 80,739 devices (100% exact match)**<br>**80,944 / 80,944 nets (100% exact match)**<br>**133 / 133 top-level I/O pins uniquely matched** | **PASSED ✅**<br>*(Circuits match uniquely)* |
| **Routing DRC** | TritonRoute detailed routing | **0 routing violations** (79,074 nets, 690,459 single-cut vias) | **PASSED ✅** |
| **Setup Timing** | 100 MHz target (10.0 ns clock) | **Setup WNS = +0.4361 ns**, TNS = 0.0000 ns (0 violations)<br>Worst reg-to-reg setup slack = **+0.4361 ns** | **PASSED ✅** |
| **Hold Timing** | Resizer hold margin = 0.5 ns | **Hold WNS = +0.1158 ns**, TNS = 0.0000 ns (0 violations)<br>Worst reg-to-reg hold slack = **+0.4850 ns** | **PASSED ✅** |
| **Power Integrity** | Static IR-Drop analysis (OpenROAD PSM) | Worst voltage = **1.6455 V (8.5% drop)**, Avg drop = **0.105 V**<br>Total power = **0.2266 W** (0 power grid violations) | **PASSED ✅** |
| **Physical Integrity** | OpenROAD / ODB | **0 disconnected pins**, **0 critical pins**, **0 illegal overlaps** | **PASSED ✅** |
| **GDSII Streamout** | KLayout streamout | Valid **143 MB GDS** (`neuromorphic_top.klayout.gds`) with 100% LEF-to-GDS cell matching | **PASSED ✅** |
| **RTL Verification** | Icarus Verilog testbench (`tb_neuromorphic_top.v`) | **100% PASS** (`RESULT: PASS initial_weight=20 trained_weight=21`) | **PASSED ✅** |

---

## 2. Architecture & Design Highlights

```
                                  ┌────────────────────────────────────────────────────────┐
   clk (100 MHz) ────────────────►│              Synchronous Neuromorphic Tile             │
   rst_n         ────────────────►│                                                        │
                                  │  ┌─────────────────┐       ┌────────────────────────┐  │
   ext_aer_req   ────────────────►│  │ Synchronous AER │──────►│ 64 Parallel LIF Neuron │──┼──► out_aer_req
   ext_aer_neuron_id[5:0] ───────►│  │ Router & Queues │       │ Array (Leak & Fire)    │──┼──► out_aer_addr[5:0]
                                  │  └────────┬────────┘       └───────────┬────────────┘  │
                                  │           │                            │               │
                                  │           ▼                            ▼               │
                                  │  ┌─────────────────┐       ┌────────────────────────┐  │
                                  │  │ 8 kB Weight     │◄─────►│ Synchronous STDP       │  │
                                  │  │ SRAM (8 Macros) │       │ Acceleration Engine    │  │
                                  │  └─────────────────┘       │ (Balanced Tree Scanner)│  │
                                  │                            └────────────────────────┘  │
                                  └────────────────────────────────────────────────────────┘
```

1. **Synchronous 64-Neuron Array**:
   - 64 event-driven Leaky Integrate-and-Fire (`lif_neuron_event.v`) processing elements operating with arithmetic leak rate ($\Delta V = V / 8$) and fixed firing threshold.
2. **8 kB Dual-Port Synaptic SRAM Matrix**:
   - Mapped to eight 1 kB SKY130 OpenRAM dual-port macros (`sky130_sram_1kbyte_1rw1r_8x1024_8`), organized into 4 interleaved banks (high/low 8-bit bytes) with registered read return pipelining.
3. **Balanced Tree STDP Scanner**:
   - Hardware STDP pair scanner replaced flat 64-step priority scans with recursive binary tree priority encoder (`priority_encoder.v`), shortening critical paths and securing positive setup timing slack (+0.436 ns).
4. **Synchronous AER Routing**:
   - Non-blocking Address Event Representation (AER) router supporting external event injection, fanout distribution, spike arbitration, and real-time STDP weight updates.

---

## 3. Repository Structure

```
.
├── decompress_signoff.sh                     # Helper script to unpack 143MB GDS & signoff deliverables
├── .gitignore                                # Clean Git ignore avoiding scratch run bloat
├── README.md                                 # Top-level documentation & signoff overview
├── rtl/                                      # Asynchronous reference RTL modules
├── testbench/                                # Asynchronous reference testbench
└── snn_chip_synchronus/
    └── rtl2/                                 # Production Synchronous Tapeout Design
        ├── aer_interface.v                   # Synchronous AER router
        ├── lif_neuron_event.v                # LIF neuron core
        ├── neuron_array.v                    # 64-neuron array top
        ├── priority_encoder.v                # Recursive tree STDP priority encoder
        ├── sky130_sram_macro_blackbox.v      # SKY130 1RW1R SRAM macro blackbox
        ├── stdp_engine_sync.v                # Synchronous STDP engine
        ├── timestamp_counter.v               # Global 16-bit timestamp timer
        ├── weight_sram.v                     # Pipelined dual-port SRAM controller
        ├── neuromorphic_top.v                # Top-level SoC
        ├── tb_neuromorphic_top.v             # End-to-end SoC testbench
        ├── tb_aer_interface.v                # AER router unit testbench
        │
        ├── openlane_config.json              # OpenLane 2 Classic flow configuration
        ├── neuromorphic_top.sdc              # Hardened SDC constraints (100 MHz, CTS uncertainty)
        ├── netgen_setup_custom.tcl           # Netgen LVS setup script (power/pin binding & cell filters)
        ├── vsrc_vpwr.txt / vsrc_vgnd.txt     # OpenROAD PSM power grid source coordinates
        ├── run_signoff_clean.sh              # Standalone OpenLane 2 invocation script
        │
        ├── PROJECT_SYNCHRONOUS_DESIGN_AND_SYNTHESIS_REPORT.md  # Comprehensive engineering report
        ├── PROJECT_FILES_AND_SOFTWARE_MAP.md                  # Complete software & toolchain reference
        ├── LINT_TRIAGE.md                                     # Exhaustive Verilator warning triage
        ├── stdp_summary.txt                                   # STDP microarchitecture timing notes
        │
        ├── synthesis_netlists/               # Newly Generated Synthesis Verilog Netlists
        │   ├── neuromorphic_top.synth.v      # Unpowered gate netlist from Yosys synthesis (8.9 MB)
        │   ├── neuromorphic_top_sky130.v     # SKY130 mapped gate netlist (8.4 MB)
        │   ├── neuromorphic_top.routed.v     # Detailed routed netlist (42 MB)
        │   ├── neuromorphic_top.pnl.v        # Powered gate netlist with hold buffers & fill (81 MB)
        │   └── neuromorphic_top.vh           # Verilog module header declaration
        │
        ├── signoff_reports/                  # Complete Physical Design & Verification Reports
        │   ├── synthesis/                    # Yosys cell statistics & latch check reports
        │   ├── sta_pre_pnr/                  # Pre-PnR OpenROAD STA timing & power reports
        │   ├── sta_post_pnr/                 # Post-Route OpenROAD STA timing (WNS/TNS/WS/Power)
        │   ├── drc_klayout/                  # KLayout DRC XML violation logs (0 errors)
        │   ├── lvs_netgen/                   # Netgen LVS report (Circuits match uniquely, 0 errors)
        │   ├── antenna/                      # OpenROAD antenna violation summaries
        │   ├── irdrop/                       # Static IR drop reports
        │   ├── manufacturability/            # OpenLane manufacturability summary
        │   └── metrics/                      # Comprehensive metrics.json and metrics.csv
        │
        └── final/                            # Production Signoff Deliverables (GitHub-Safe GZ)
            ├── klayout_gds/                  # neuromorphic_top.klayout.gds.gz (17 MB -> 143 MB GDS)
            ├── def/                          # neuromorphic_top.def.gz (16 MB -> 139 MB DEF)
            ├── spef/                         # Extracted parasitics: min, nom, max (nom.spef.gz: 32 MB)
            ├── lib/                          # Timing liberty model: neuromorphic_top__nom_tt_025C_1v80.lib
            ├── sdf/                          # Delay SDF: neuromorphic_top__nom_tt_025C_1v80.sdf.gz
            ├── pnl/                          # Powered netlist: neuromorphic_top.pnl.v.gz
            ├── spice/                        # Extracted SPICE: neuromorphic_top.spice.gz
            └── reports/                      # Core signoff reports archive (LVS, Antenna, Metrics)
```

---

## 4. Quickstart: Verification & Simulation

### Functional RTL Simulation
Simulate the full 64-neuron SoC with external AER stimulus, internal synaptic weight retrieval, neuron spike generation, and online STDP weight potentiation:

```bash
cd snn_chip_synchronus/rtl2
iverilog -g2012 -o tb_sim \
  sky130_sram_macro_blackbox.v \
  priority_encoder.v \
  timestamp_counter.v \
  lif_neuron_event.v \
  neuron_array.v \
  weight_sram.v \
  stdp_engine_sync.v \
  aer_interface.v \
  neuromorphic_top.v \
  tb_neuromorphic_top.v

vvp tb_sim
```
*Expected output: `RESULT: PASS initial_weight=20 trained_weight=21`*

---

## 5. Unpacking Signoff Deliverables

To avoid GitHub's 100 MB per-file push rejection, production deliverables in `snn_chip_synchronus/rtl2/final/` are stored in gzip-compressed form (`.gz`). To decompress them locally for use with KLayout, Magic, or OpenROAD:

```bash
./decompress_signoff.sh
```

This unpacks:
- `neuromorphic_top.klayout.gds` (143 MB streamout GDS)
- `neuromorphic_top.def` (139 MB detailed placement and routing DEF)
- `neuromorphic_top.nom.spef` (120 MB parasitic extraction SPEF)
- `neuromorphic_top.pnl.v` (81 MB powered gate-level netlist)

---

## 6. How to Push to Your GitHub Repository

This directory on your Desktop (`~/Desktop/snn_chip`) is already configured with your repository remote (`origin https://github.com/567jatin/snn_chip.git`) on the `main` branch.

To push these updates to GitHub:

```bash
cd ~/Desktop/snn_chip

# Review staged changes
git status

# Commit the clean tapeout design, synthesis netlists, and reports
git commit -m "Tapeout Signoff: 100 MHz timing closure, 0 DRC, clean Netgen LVS, synthesis netlists & reports"

# Push to GitHub
git push origin main
```
