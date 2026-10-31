# 64-Neuron Neuromorphic SNN Processor (SkyWater 130nm Tapeout Signoff)

[![Foundry PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm%20(sky130A)-blue.svg)](https://github.com/google/skywater-pdk)
[![Clock Frequency](https://img.shields.io/badge/Clock-100%20MHz%20(10.0%20ns)-green.svg)]()
[![Setup Slack](https://img.shields.io/badge/Setup%20WNS-%2B0.436%20ns-brightgreen.svg)]()
[![Hold Slack](https://img.shields.io/badge/Hold%20WNS-%2B0.116%20ns-brightgreen.svg)]()
[![KLayout DRC](https://img.shields.io/badge/KLayout%20DRC-0%20Violations%20(Clean)-brightgreen.svg)]()
[![Netgen LVS](https://img.shields.io/badge/Netgen%20LVS-100%25%20Match%20(0%20Errors)-brightgreen.svg)]()
[![TritonRoute DRC](https://img.shields.io/badge/Routing%20DRC-0%20Violations-brightgreen.svg)]()

A complete, production-grade 64-neuron, 4096-synapse Spiking Neural Network (SNN) hardware accelerator hardened and fully signed off for silicon fabrication on the open-source **SkyWater 130 nm (`sky130A`) CMOS** node using **OpenLane 2** and **OpenROAD**.

The design features on-chip dual-port SRAM synaptic storage (8 kB across 8 macros), 64 parallel Leaky Integrate-and-Fire (LIF) neurons, an online Spike-Timing-Dependent Plasticity (STDP) learning engine with a balanced binary tree priority scanner, and Address-Event Representation (AER) protocol routing.

---

## 1. Key Tapeout Specifications & Signoff Metrics

The tapeout signoff run (`balanced_encoder_pnr_20261029`) executed all 78 stages of physical design, parasitics extraction, and verification in OpenLane 2 Classic under the nominal manufacturing corner (`nom_tt_025C_1v80`, 1.80 V, 25 °C):

| Metric / Check | Tool / Engine | Target / Limit | Signoff Value | Signoff Status |
| :--- | :--- | :--- | :--- | :---: |
| **Manufacturing DRC** | KLayout (`sky130A.drc`) | 0 violations | **0 violations across all mask layers** | **PASSED ✅** |
| **Layout vs. Schematic (LVS)** | Netgen LVS | Exact netlist match | **80,739 / 80,739 devices (100% match)**<br>**80,944 / 80,944 nets (100% match)**<br>**133 / 133 top-level I/O pins matched** | **PASSED ✅**<br>*(Circuits match uniquely)* |
| **Detailed Routing DRC** | TritonRoute | 0 violations | **0 routing DRC violations**<br>(79,074 nets, 690,459 vias) | **PASSED ✅** |
| **Setup Timing (STA)** | OpenROAD STA | Clock $T \ge 10.0\text{ ns}$ (100 MHz) | **Setup WNS = +0.4361 ns**, TNS = 0.000 ns<br>Worst Reg-to-Reg Slack = **+0.4361 ns** | **PASSED ✅** |
| **Hold Timing (STA)** | OpenROAD STA | Hold WNS $\ge 0.000\text{ ns}$ | **Hold WNS = +0.1158 ns**, TNS = 0.000 ns<br>Worst Reg-to-Reg Slack = **+0.4850 ns** | **PASSED ✅** |
| **Static IR Drop** | OpenROAD PSM | IR Drop $\le 10\%$ ($< 0.180\text{ V}$) | **Worst Voltage = 1.6455 V (8.5% drop)**<br>Average Drop = **0.105 V** (0 grid errors) | **PASSED ✅** |
| **Die & Core Geometry** | OpenROAD Floorplan | Fixed die outline | **Die: $2859.525 \times 2870.245\ \mu\text{m}$ ($8.21\text{ mm}^2$)**<br>Core Area: $8.11\text{ mm}^2$ | **PASSED ✅** |
| **Instance Count** | OpenROAD Database | - | **234,702 total instances**<br>(234,694 standard cells, 8 SRAM macros) | **PASSED ✅** |
| **Total Power Consumption** | OpenROAD STA Power | Nominal corner | **226.63 mW** total<br>(148.86 mW internal, 77.62 mW switching) | **PASSED ✅** |
| **Physical Integrity** | OpenROAD / ODB | 0 disconnections | **0 disconnected pins**, **0 illegal overlaps** | **PASSED ✅** |
| **GDSII Streamout** | KLayout Streamout | Foundry-valid GDSII | **143 MB GDS** (`neuromorphic_top.klayout.gds`)<br>100% LEF-to-GDS cell resolution | **PASSED ✅** |
| **End-to-End Simulation** | Icarus Verilog | Weight update verification | **100% PASS** (`PASS initial_weight=20 trained_weight=21`) | **PASSED ✅** |

---

## 2. Microarchitecture Overview

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

The processor comprises five primary subsystems:

1. **64 Parallel LIF Neuron Array (`lif_neuron_event.v`, `neuron_array.v`)**:
   - 64 event-driven Leaky Integrate-and-Fire neurons.
   - Clocked membrane integration with exponential/arithmetic leak ($\Delta V = V / 8$).
   - Configurable firing threshold ($V_{th} = 15$) and refractory reset state.

2. **8 kB Dual-Port Synaptic SRAM Matrix (`weight_sram.v`, `sky130_sram_macro_blackbox.v`)**:
   - Hardened with eight 1 kB SKY130 OpenRAM dual-port macros (`sky130_sram_1kbyte_1rw1r_32x256_8`).
   - Organized into 4 interleaved banks (even/odd addresses with high/low byte lanes).
   - Independent dual ports: **Port A** serves inference reads and configuration, **Port B** serves real-time STDP weight read-modify-write updates without pipeline stalling.

3. **Balanced Binary Tree STDP Acceleration Engine (`stdp_engine_sync.v`, `priority_encoder.v`)**:
   - Implements hardware-accelerated Spike-Timing-Dependent Plasticity learning rule.
   - Replaced flat priority scans with recursive 6-level balanced binary tree encoders to close 100 MHz timing.
   - Pipelined trace memory captures pre-synaptic and post-synaptic spike timestamps with an exponential learning window ($T_{window} = 64$ clock cycles).

4. **Synchronous AER Routing Interface (`aer_interface.v`)**:
   - Bidirectional Address-Event Representation (AER) transceiver.
   - Handles external spike event injection, zero-weight packet suppression, destination fanout sequencing, and internal spike arbitration.

5. **Global Timestamp Counter (`timestamp_counter.v`)**:
   - High-precision 16-bit synchronous counter providing global event timing across neurons and learning engines.

---

## 3. Project Architecture & Evolution

This repository preserves both design phases of the SNN processor:

| Component | Asynchronous Prototype (`rtl/`) | Synchronous Hardened Signoff (`snn_chip_synchronus/rtl2/`) |
| :--- | :--- | :--- |
| **Clocking** | Clockless / Asynchronous Handshakes | Fully Synchronous 100 MHz Single Clock Domain |
| **Synaptic Storage** | Behavioral flip-flop array | 8 kB Hard SRAM (8× SKY130 1 kB OpenRAM Dual-Port Macros) |
| **STDP Scanner** | Linear delay-chain scan | Balanced recursive binary tree priority scanner |
| **Physical Hardening** | Unhardened conceptual RTL | **Tapeout Signoff in SkyWater 130nm** (GDSII, DEF, SPEF, LVS, DRC) |
| **Timing Closure** | Unconstrained | **Setup: +0.436 ns, Hold: +0.116 ns** |

---

## 4. Repository Structure

```
.
├── decompress_signoff.sh                     # Shell script to decompress 143 MB GDS, DEF, SPEF deliverables
├── .gitignore                                # Optimized gitignore excluding large intermediate run caches
├── README.md                                 # Top-level comprehensive documentation
│
├── rtl/                                      # Reference Asynchronous RTL Architecture
│   ├── aer_arbiter.v                         # Asynchronous 4-phase AER arbiter
│   ├── aer_decoder.v                         # AER address decoder
│   ├── aer_encoder.v                         # AER priority encoder
│   ├── lif_neuron_event.v                    # Asynchronous event LIF neuron
│   ├── neuromorphic_top.v                    # Top-level asynchronous SoC
│   ├── neuron_array.v                        # Asynchronous neuron array
│   ├── stdp_engine_async.v                   # Delay-chain STDP learning engine
│   ├── timestamp_counter.v                   # Free-running timestamp source
│   ├── trace_mem_async.v                     # Asynchronous spike trace memory
│   └── weight_sram.v                         # Behavioral register-based weight memory
│
├── testbench/                                # Reference Asynchronous Testbench
│   └── tb_neuromorphic_top.v                 # Testbench for asynchronous prototype
│
└── snn_chip_synchronus/
    ├── README.md                             # Synchronous core implementation summary
    ├── sta/                                  # Pre-layout STA constraint templates
    ├── testbench/                            # Standalone testbenches
    │
    └── rtl2/                                 # PRODUCTION SYNCHRONOUS SILICON SIGNOFF
        ├── aer_interface.v                   # Synchronous AER router & fanout controller
        ├── lif_neuron_event.v                # Synchronous LIF neuron with arithmetic leak
        ├── neuron_array.v                    # 64-neuron clocked parallel array
        ├── priority_encoder.v                # Balanced tree STDP priority encoder
        ├── sky130_sram_macro_blackbox.v      # SKY130 1RW1R OpenRAM macro blackbox
        ├── stdp_engine_sync.v                # Synchronous dual-trace STDP engine
        ├── timestamp_counter.v               # Global 16-bit synchronous timestamp timer
        ├── weight_sram.v                     # 8 kB dual-port SRAM controller (8 macros)
        ├── neuromorphic_top.v                # Hardened 100 MHz SoC top-level module
        ├── tb_neuromorphic_top.v             # End-to-end SoC verification testbench
        ├── tb_aer_interface.v                # AER router unit verification testbench
        │
        ├── openlane_config.json              # OpenLane 2 Classic physical design configuration
        ├── neuromorphic_top.sdc              # Production SDC constraints (100 MHz, CTS uncertainties)
        ├── netgen_setup_custom.tcl           # Netgen LVS custom setup (SRAM blackbox & pin rules)
        ├── vsrc_vpwr.txt / vsrc_vgnd.txt     # OpenROAD PSM power grid voltage coordinates
        ├── run_signoff_clean.sh              # OpenLane 2 single-command invocation script
        │
        ├── PROJECT_SYNCHRONOUS_DESIGN_AND_SYNTHESIS_REPORT.md  # 50+ page engineering & signoff report
        ├── PROJECT_FILES_AND_SOFTWARE_MAP.md                  # Comprehensive toolchain & software guide
        ├── LINT_TRIAGE.md                                     # Exhaustive Verilator warning triage
        ├── stdp_summary.txt                                   # STDP microarchitecture timing breakdown
        │
        ├── synthesis_netlists/               # Newly Generated Synthesis Verilog Netlists
        │   ├── neuromorphic_top.synth.v      # Unpowered gate-level netlist from Yosys (8.9 MB)
        │   ├── neuromorphic_top_sky130.v     # SkyWater 130nm mapped gate-level netlist (8.4 MB)
        │   ├── neuromorphic_top.routed.v     # Detailed routed netlist from TritonRoute (42 MB)
        │   ├── neuromorphic_top.pnl.v        # Powered netlist with hold buffers & fill (81 MB)
        │   └── neuromorphic_top.vh           # Verilog module header declaration
        │
        ├── signoff_reports/                  # Full Physical Design & Verification Reports
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
        └── final/                            # Hardened Signoff Deliverables (GitHub-Safe GZ)
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

## 5. Verification & Simulation

### 5.1 Simulating the Hardened Synchronous SoC (`snn_chip_synchronus/rtl2/`)

The end-to-end testbench verifies configuration write, external AER spike routing, membrane integration, neuron firing, and STDP weight potentiation:

```bash
cd snn_chip_synchronus/rtl2

# Compile with Icarus Verilog
iverilog -g2012 -o sim_sync \
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

# Run the simulation
vvp sim_sync
```

**Expected verification output:**
```text
[TIME=155000] Loading initial weight W[0,1] = 20
[TIME=255000] Injecting external AER spike for neuron 0...
[TIME=375000] Neuron 1 fired!
[TIME=495000] STDP update applied: W[0,1] updated from 20 -> 21
RESULT: PASS initial_weight=20 trained_weight=21
```

### 5.2 Simulating the AER Router Unit Testbench

```bash
cd snn_chip_synchronus/rtl2

iverilog -g2012 -o sim_aer \
  aer_interface.v \
  tb_aer_interface.v

vvp sim_aer
```

### 5.3 Simulating the Asynchronous Prototype (`rtl/`)

```bash
cd rtl

iverilog -g2005-sv -o sim_async \
  lif_neuron_event.v \
  neuron_array.v \
  weight_sram.v \
  trace_mem_async.v \
  timestamp_counter.v \
  stdp_engine_async.v \
  aer_decoder.v \
  aer_encoder.v \
  aer_arbiter.v \
  neuromorphic_top.v \
  ../testbench/tb_neuromorphic_top.v

vvp sim_async
```

### 5.4 Viewing Waveforms

All testbenches generate standard VCD waveform files. Inspect signal transactions in GTKWave:

```bash
gtkwave tb_neuromorphic_top.vcd
```

---

## 6. Accessing Silicon Signoff Deliverables

To comply with GitHub's 100 MB per-file push limit, production deliverables in `snn_chip_synchronus/rtl2/final/` are compressed with gzip (`.gz`). 

To unpack the full uncompressed foundry files for physical inspection in KLayout, Magic, or OpenROAD:

```bash
./decompress_signoff.sh
```

This restores the full-size tapeout artifacts:
- `snn_chip_synchronus/rtl2/final/klayout_gds/neuromorphic_top.klayout.gds` (143 MB streamout GDS)
- `snn_chip_synchronus/rtl2/final/def/neuromorphic_top.def` (139 MB detailed placement and routing DEF)
- `snn_chip_synchronus/rtl2/final/spef/nom/neuromorphic_top.nom.spef` (120 MB parasitic extraction SPEF)
- `snn_chip_synchronus/rtl2/final/pnl/neuromorphic_top.pnl.v` (81 MB powered gate-level netlist)

---

## 7. Open-Source EDA Toolchain

The physical implementation was performed entirely with open-source silicon EDA tools:

| Tool | Role | Version / Commit |
| :--- | :--- | :--- |
| **Yosys** | RTL synthesis & technology mapping | 0.46+ |
| **OpenROAD** | Floorplanning, PDN, placement, CTS, detailed routing, STA, IR-drop | 2.0+ |
| **TritonRoute** | Multi-threaded detailed routing engine | Built-in OpenROAD |
| **Magic VLSI** | GDS layout extraction & SPICE netlist generation | 8.3.480+ |
| **Netgen** | Transistor-level Layout-Versus-Schematic (LVS) comparison | 1.5.275+ |
| **KLayout** | Foundry DRC verification & high-density GDSII streamout | 0.29.8+ |
| **OpenLane 2** | Automated physical design flow orchestration | 2.1+ |
| **Icarus Verilog** | IEEE-1364/1800 RTL & gate-level simulation | 12.0+ |
| **GTKWave** | Electronic design automation waveform visualizer | 3.3+ |

---

## 8. Authors & Acknowledgments

- **Architecture & Hardening:** Neuromorphic SNN Chip Design Team
- **Technology Node:** SkyWater Technology 130 nm CMOS (`sky130A`) via Google/Efabless open silicon initiative.
