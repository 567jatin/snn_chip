# Synchronous Neuromorphic SNN Core (100 MHz SkyWater 130nm Signoff)

## Status & Overview

This directory contains the fully clocked, synchronous architecture of the 64-neuron, 4096-synapse Spiking Neural Network (SNN) hardware accelerator. Hardened and signed off for silicon fabrication on the **SkyWater 130 nm (`sky130A`)** CMOS technology node, the core achieves clean 100 MHz timing closure, zero DRC violations, and 100% matched Netgen LVS.

Key features:
- **Foundry SRAM Integration:** Synaptic weight memory mapped to eight 1 kB SkyWater 130 dual-port OpenRAM macros (`sky130_sram_1kbyte_1rw1r_32x256_8`).
- **Timing Closure at 100 MHz:** Balanced binary tree priority scanner in the STDP engine yielding positive setup slack (+0.436 ns) and positive hold slack (+0.116 ns).
- **Physical Signoff:** 0 KLayout DRC violations, 0 TritonRoute violations, clean Netgen LVS (80,739 devices and 80,944 nets matched), and static IR drop below 8.5%.

---

## Event and Learning Flow

```text
External AER source ID ──┐
                         ├─► Synchronous AER Router ──► Read W[source, destination]
Local neuron spikes ─────┘                                     │
                                                               └─► Weighted event to each
                                                                   connected destination
Local neuron spikes ─────────────────────────────────────────────► Outgoing AER handshake

External source event ──► Pre-spike queue ──┐
Local neuron spike    ──► Pre & post queues ├─► Balanced Tree Scanner ──► Synchronous STDP FSM
                                            │                              ├─ Trace registers
                                            └──────────────────────────────└─ Weight SRAM Port B
```

1. **AER Event Ingestion & Routing (`aer_interface.v`):**
   - Ingests incoming 6-bit source neuron IDs via request/acknowledge handshakes synchronized to `clk`.
   - Automatically scans destination neurons and reads synaptic weights from SRAM Port A.
   - Suppresses zero-weight synapses to eliminate redundant downstream neuron updates.

2. **Parallel LIF Neuron Array (`neuron_array.v`, `lif_neuron_event.v`):**
   - 64 parallel Leaky Integrate-and-Fire neurons.
   - Performs arithmetic leak ($\Delta V = V / 8$) and integrates synaptic weight current on event acceptance.
   - Emits a single-cycle spike and resets to resting potential when threshold $V_{th} = 15$ is exceeded.

3. **Dual-Trace STDP Learning Engine (`stdp_engine_sync.v`, `priority_encoder.v`):**
   - Event queues buffer incoming pre-synaptic and post-synaptic events with 16-bit timestamps.
   - A balanced binary tree scanner iterates over active pairs.
   - Reads existing weight over SRAM Port B, applies potentiation ($+1$) or depression ($-1$) based on spike timing within learning window $T_{window} = 64$ clock cycles, and writes updated weight back to SRAM.

---

## Weight Memory Organization

Synaptic storage is mapped to eight 1 kB SKY130 OpenRAM dual-port macros:
- **Capacity:** 64 pre-neurons × 64 post-neurons = 4,096 8-bit synaptic weights.
- **Port A:** Read-only access for AER event fanout routing and top-level monitoring/configuration.
- **Port B:** Read-modify-write access for real-time STDP weight updates without contention.

Weights can be pre-loaded through the top-level configuration interface:
- `cfg_w_wr_en`
- `cfg_w_addr` (`{pre_id[5:0], post_id[5:0]}`)
- `cfg_w_data`

---

## RTL & Verification Manifest

| File | Description |
| :--- | :--- |
| `rtl2/neuromorphic_top.v` | Top-level clocked SoC integrating AER, neurons, queues, STDP, and SRAM |
| `rtl2/aer_interface.v` | Synchronous AER router, weight reader, and event dispatcher |
| `rtl2/neuron_array.v` | 64-instance LIF neuron array |
| `rtl2/lif_neuron_event.v` | Individual clocked LIF neuron with arithmetic leak |
| `rtl2/priority_encoder.v` | Balanced recursive binary tree priority encoder for STDP pair scanning |
| `rtl2/weight_sram.v` | 8 kB dual-port SRAM controller managing eight SKY130 macros |
| `rtl2/sky130_sram_macro_blackbox.v` | SKY130 1RW1R OpenRAM macro behavioral blackbox |
| `rtl2/stdp_engine_sync.v` | Synchronous STDP learning engine with pre/post trace registers |
| `rtl2/timestamp_counter.v` | 16-bit global synchronous timestamp counter |
| `rtl2/tb_aer_interface.v` | AER router standalone unit testbench |
| `rtl2/tb_neuromorphic_top.v` | End-to-end SoC testbench verifying weight configuration, firing, and STDP |

---

## Functional Simulation

Simulate the complete synchronous processor:

```bash
cd rtl2

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

**Verification result:**
```text
RESULT: PASS initial_weight=20 trained_weight=21
```

---

## Signoff & Synthesis Deliverables

Refer to [`rtl2/`](file:///home/test/Desktop/snn_chip/snn_chip_synchronus/rtl2/) for:
- **Synthesis Gate Netlists:** `synthesis_netlists/` (`neuromorphic_top.synth.v`, `neuromorphic_top.routed.v`, `neuromorphic_top.pnl.v`)
- **Signoff Reports:** `signoff_reports/` (Timing, LVS, DRC, Antenna, IR-drop, Metrics)
- **Tapeout Production Files:** `final/` (GDSII, DEF, SPEF, LIB, SDF, SPICE)
- **Comprehensive Signoff Documentation:** [`rtl2/PROJECT_SYNCHRONOUS_DESIGN_AND_SYNTHESIS_REPORT.md`](file:///home/test/Desktop/snn_chip/snn_chip_synchronus/rtl2/PROJECT_SYNCHRONOUS_DESIGN_AND_SYNTHESIS_REPORT.md)
