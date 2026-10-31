# Synchronous Neuromorphic SNN RTL

## Current status

This project is an experimental, clocked RTL model of a 64-neuron spiking neural network. External AER source events and local neuron spikes enter a shared on-chip router. The router reads the source neuron's weight row and sends weighted events to connected destination neurons. Local spikes can also be forwarded to an external AER receiver.

The LIF neurons, AER router, timestamp counter, top-level control, STDP engine, and weight-memory interfaces use `clk`. AER pins use request/acknowledge handshakes, but transactions are managed synchronously. Functional simulations pass; foundry mapping, physical timing, and signoff have not been done.

## Event and learning flow

```text
External AER source ID ─┐
                        ├─> synchronous AER router ─> read W[source,destination]
Local neuron spikes ────┘                                │
                                                         └─> weighted event to each
                                                             connected destination
Local neuron spikes ────────────────────────────────────────> outgoing AER handshake

External source event ─> pre-spike queue ─┐
Local neuron spike ────> pre and post queues├─> pair scanner ─> synchronous STDP FSM
                                            │                    ├─ trace registers
                                            └────────────────────└─ weight SRAM port B
```

An incoming AER event carries one source neuron ID. For each source event, `aer_interface` scans destination IDs and reads `W[source,destination]`. It asserts the target's `syn_valid` only for nonzero weights. Local neuron spikes use the same internal routing path and are also offered on the outgoing AER interface.

The top queues each external event as a pre-spike. Each local neuron spike becomes both a pre-spike and a post-spike with its timestamp. The pair scanner expands each event across all partner neurons and sends one pair at a time to `stdp_engine_sync`.

For a post event with a recent pre trace, STDP potentiates the pair. For a pre event with a recent post trace, STDP depresses the pair. Updates are limited by `T_WINDOW`, `W_MIN`, and `W_MAX`; the decay amount is approximated with shifts.

## Initializing weights

Initial weights are loaded through the top-level configuration write interface:

- `cfg_w_wr_en`
- `cfg_w_addr`
- `cfg_w_data`

An external ROM/controller can drive these signals before spike traffic starts. No ROM is instantiated in this RTL. The behavioral weight memory is uninitialized; a physical SRAM also has no reset, so initialize every weight used by the network before running events. The `w_mon_*` ports provide a read/monitor path.

The default address is `{pre_id, post_id}`. Six-bit IDs address a 64 by 64 matrix of 4096 weights.

## RTL files

| File | Role |
|---|---|
| `rtl/neuromorphic_top.v` | Integrates configuration, AER routing, neurons, event queue, pair scanning, and STDP. |
| `rtl/aer_interface.v` | Synchronous source-event fanout, weight reads, neuron event delivery, and outgoing AER handshake. |
| `rtl/neuron_array.v` | Instantiates one LIF block per neuron. |
| `rtl/lif_neuron_event.v` | Clocked LIF integration, leak, threshold, reset, and spike output; latches current on event acceptance. |
| `rtl/weight_sram.v` | Behavioral synchronous dual-port weight memory. Port A serves config/monitor/router; port B serves STDP. Replace the model with a compatible foundry macro. |
| `rtl/stdp_engine_sync.v` | Clocked STDP FSM with pre/post trace arrays and synchronous weight read/write. |
| `rtl/timestamp_counter.v` | Clocked global timestamp source. |
| `rtl/tb_aer_interface.v` | Tests external and local fanout, zero-weight suppression, and outgoing AER handshakes. |
| `rtl/tb_neuromorphic_top.v` | End-to-end test of weight loading, routed neuron firing, and STDP potentiation. |

The former standalone encoder, arbiter, decoder, asynchronous trace-memory, and delay-based STDP files are no longer used.

## Simulation

With Icarus Verilog installed, run the router test:

```sh
iverilog -g2012 -s aer_interface_tb -o /tmp/aer_interface.vvp \
  rtl/aer_interface.v rtl/tb_aer_interface.v
vvp /tmp/aer_interface.vvp
```

Run the end-to-end learning test:

```sh
iverilog -g2012 -s tb_neuromorphic_top -o /tmp/neuromorphic_test.vvp \
  rtl/aer_interface.v rtl/lif_neuron_event.v rtl/neuron_array.v \
  rtl/neuromorphic_top.v rtl/stdp_engine_sync.v rtl/timestamp_counter.v \
  rtl/weight_sram.v rtl/tb_neuromorphic_top.v
vvp /tmp/neuromorphic_test.vvp
```

Both tests pass. The end-to-end case loads `W[0,1]=20`, routes an external source event to neuron 1, observes a neuron spike, and verifies STDP changes the weight to 21. The testbenches create VCD files under `/tmp` for GTKWave.

## Next implementation work

- Map the behavioral dual-port weight memory to a foundry SRAM macro and confirm its read/write timing.
- Add process-specific constraints, synthesize against the selected standard-cell library, then run STA and area analysis.
- Review routing throughput and queue sizing at the intended neuron count and event rate.

This repository does not contain a selected foundry PDK, placed-and-routed layout, timing signoff, or fabrication-ready chip.
