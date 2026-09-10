# Neuromorphic SNN Processor

A 64-neuron, 4096-synapse Spiking Neural Network processor in Verilog featuring a **fully clockless STDP learning engine** and asynchronous AER spike routing.

## Features

- **64 Event-Driven LIF Neurons** — arithmetic leak, zero idle power
- **64×64 All-to-All Crossbar** — 4096-entry dual-port weight SRAM with direct O(1) addressing
- **Clockless STDP Engine** — self-timed 4-phase handshake pipeline, zero switching power between spikes
- **Async AER Protocol** — 4-phase address-event representation with round-robin arbitration
- **On-Chip Learning** — real-time LTP/LTD using multiplierless bit-shift exponential decay

## Architecture

```
                    ┌─────────────────────────────────────────┐
  ext_aer_req ─────►│  AER FSM  ──► Weight SRAM ──► Neuron   │──► spike_out[63:0]
  pre_id / post_id ►│            ◄── (sync port)    Array     │──► v_mem[63:0]
                    │                  │  (async port)         │
                    │  Handshake ──► STDP Engine (clockless)   │
                    │  Controller   ├── Pre Trace (async)      │
                    │               └── Post Trace (async)     │
                    └─────────────────────────────────────────┘
```

## File Structure

| File | Description |
|---|---|
| `lif_neuron_event.v` | Event-driven Leaky Integrate-and-Fire neuron |
| `neuron_array.v` | 64 parallel LIF instances |
| `weight_sram.v` | 4096×16 dual-port synaptic weight memory |
| `trace_mem_async.v` | Clockless trace memory (combinational read) |
| `timestamp_counter.v` | 16-bit global timer |
| `stdp_engine_async.v` | Fully clockless STDP pipeline |
| `aer_encoder.v` | Async AER spike encoder |
| `aer_arbiter.v` | 64-input round-robin arbiter |
| `aer_decoder.v` | AER spike delivery unit |
| `neuromorphic_top.v` | Top-level SoC |
| `tb_neuromorphic_top.v` | End-to-end testbench |



## Parameters

| Parameter | Default | Description |
|---|---|---|
| `NUM_NEURONS` | 64 | Neurons per tile |
| `V_THRESH` | 1000 | LIF firing threshold |
| `LEAK_SHIFT` | 3 | Leak rate (V/8) |
| `A_POS / A_NEG` | 100 / 80 | STDP learning amplitudes |
| `T_WINDOW` | 64 | STDP time window |
| `STAGE_DELAY` | 2ns | Async pipeline delay |


