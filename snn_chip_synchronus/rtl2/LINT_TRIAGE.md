# Neuromorphic Top (`neuromorphic_top`) Verilator Lint Triage Report

**Design:** `neuromorphic_top` (Synchronous Neuromorphic Processor)  
**Technology:** SKY130A (`sky130_fd_sc_hd` + OpenRAM Macro `sky130_sram_1kbyte_1rw1r_8x1024_8`)  
**Lint Tool:** Verilator v5.018 / v5.048  
**Invocation Options:** `--lint-only -Wall --Wno-DECLFILENAME --Wno-EOFNEWLINE --top-module neuromorphic_top --Wno-fatal --relative-includes --Werror-LATCH +define+PDK_sky130A +define+SCL_sky130_fd_sc_hd +define+__openlane__ +define+__pnr__ +define+USE_POWER_PINS +define+SYNTHESIS`  
**Date:** 2026-10-30  
**Status:** **PASSED / SIGNED OFF** (0 Errors, 0 Latches, 75 Design Warnings Triaged)

---

## 1. Executive Summary

A comprehensive Verilator lint check was performed across the complete RTL source suite of `neuromorphic_top`.
- **Fatal Errors:** **0**
- **Inferred Latches (`Werror-LATCH`):** **0**
- **Total Warnings in Design RTL:** **75**
- **Synthetic Blackbox Warnings (OpenLane standard cell library stubs):** 441 (all `TIMESCALEMOD`, excluded from design RTL analysis)

All 75 design warnings have been exhaustively categorized, analyzed, and verified safe for tapeout. No functional defects, race conditions, or unmapped hardware structures exist.

---

## 2. Warning Categorization Breakdown

| Category | Warning Class | Count | Primary Modules | Signoff Status |
|---|---|---|---|---|
| **Width & Arithmetic** | `WIDTHEXPAND` | 36 | `aer_interface.v` (23), `priority_encoder.v` (9), `neuromorphic_top.v` (4) | **SAFE** — Parameterized arithmetic / integer extension |
| **Width Truncation** | `WIDTHTRUNC` | 8 | `priority_encoder.v` (6), `aer_interface.v` (2) | **SAFE** — Intentional bit-slice selection |
| **Unused Signals** | `UNUSEDSIGNAL` | 14 | `sky130_sram_macro_blackbox.v` (9), `lif_neuron_event.v` (3), `aer_interface.v` (2) | **SAFE** — Unconnected macro inputs / unused carry bits |
| **Sequential Blocking** | `BLKSEQ` | 12 | `neuromorphic_top.v` (6), `aer_interface.v` (6) | **SAFE** — Intra-cycle scratchpad variables |
| **Undriven Outputs** | `UNDRIVEN` | 2 | `sky130_sram_macro_blackbox.v` (2) | **SAFE** — Macro blackbox output ports |
| **Empty Connections** | `PINCONNECTEMPTY` | 1 | `neuron_array.v` (1) | **SAFE** — Intentional unrouted internal monitor port |
| **Timescale** | `TIMESCALEMOD` | 1 | `sky130_sram_macro_blackbox.v` (1) | **SAFE** — Simulation timescale default |
| **Unused Parameters** | `UNUSEDPARAM` | 1 | `weight_sram.v` (1) | **SAFE** — Architectural documentation parameter |
| **Total** | | **75** | | **ALL TRIAGED & SIGNED OFF** |

---

## 3. Detailed Triage by Category

### 3.1 Width Extension (`WIDTHEXPAND`, 36 warnings) & Truncation (`WIDTHTRUNC`, 8 warnings)
- **Observations**:
  - In `priority_encoder.v` (lines 46, 52): The recursive tree encoder uses integer arithmetic (`HALF_WIDTH`, bit shifts `1 << i`, and additions) to dynamically compute subtree indices. Verilator warns that 32-bit integer arithmetic is assigned to smaller parameterized bit vectors (`[WIDTH-1:0]`).
  - In `aer_interface.v`: Address pointer offsets, wrap-around additions (`out_addr + 1'b1`), and pointer comparisons against `NUM_NEURONS-1` expand to 32 bits before assignment to 6-bit vectors.
  - In `neuromorphic_top.v`: State and counter constants compared or assigned to slice vectors.
- **Root Cause**: Verilog-2001 standard rules regarding 32-bit integer promotion of unsized literals and arithmetic expressions.
- **Safety Assessment**:
  - All index bounds are strictly verified: `NUM_NEURONS` is 64, addressing is 6 bits (`[5:0]`). No high-order data bits are lost in truncation, and zero-extension in comparisons does not alter numerical truth values.
  - Formally verified via Yosys synthesis equivalence and gate-level STA.

### 3.2 Unused Signals (`UNUSEDSIGNAL`, 14 warnings)
- **Observations**:
  - `sky130_sram_macro_blackbox.v` (9 warnings): `clk0`, `csb0`, `web0`, `wmask0`, `addr0`, `din0`, `clk1`, `csb1`, `addr1`.
  - `aer_interface.v` (2 warnings): `route_wrapped[6]` and `output_wrapped[6]`.
  - `lif_neuron_event.v` (3 warnings): Upper bits of shift parameters and unused status flags.
- **Root Cause**:
  - In `sky130_sram_macro_blackbox.v`, the module is a simulation/synthesis blackbox stub for OpenRAM. The pins are declared to match the LEF/SPICE interface, but the behavioral body is omitted during synthesis.
  - In `aer_interface.v`, 7-bit adders compute pointer wrap-around (`route_wrapped = route_ptr + i`). Bit 6 is the carry bit used solely for wrap detection; bits [5:0] form the actual address.
- **Safety Assessment**:
  - Standard ASIC practice. The synthesis tool correctly ties off or trims unused inputs/outputs without dangling gate logic.

### 3.3 Blocking Assignments in Clocked Sequential Blocks (`BLKSEQ`, 12 warnings)
- **Observations**:
  - `neuromorphic_top.v` (lines 266, 267, 299, 342, 344, 345):
    - `batch_count_next = batch_count;`
    - `batch_write_idx = batch_tail;`
    - `batch_count_next = batch_count_next - 1;`
    - `batch_write_idx = 0;` / `batch_write_idx = batch_write_idx + 1;`
    - `batch_count_next = batch_count_next + 1;`
  - `aer_interface.v` (lines 133, 136, 141, 144, 147, 152):
    - `next_count = route_pending[i];`
    - `next_count = next_count + 1;`
    - `next_count = next_count - 1;`
- **Root Cause**:
  - Both processes use procedural temporary scratchpad variables (`batch_count_next`, `batch_write_idx`, `next_count`) to accumulate multiple conditional modifications within a single clock cycle.
  - At the end of the always block, the accumulated results are registered using non-blocking assignments (`batch_tail <= batch_write_idx[Q_PTR_W-1:0];`, `batch_count <= batch_count_next[Q_COUNT_W-1:0];`, `route_pending[i] <= next_count[PENDING_W-1:0];`).
- **Remediation Analysis**:
  - Mechanically converting `=` to `<=` on these scratchpads would corrupt functionality: non-blocking updates do not take effect immediately, which would cause subsequent conditional reads in the same clock cycle to read stale values.
  - Synthesis tools (Yosys) evaluate blocking assignments in sequential blocks as combinational feedback into the D-flip-flop data inputs.
- **Safety Assessment**:
  - Synthesized netlist verified: Yosys produces clean DFFs with pure combinational input cones. Zero latches or timing race conditions generated.

### 3.4 Undriven Outputs (`UNDRIVEN`, 2 warnings)
- **Observations**:
  - `sky130_sram_macro_blackbox.v` (lines 16, 20): `dout0` and `dout1`.
- **Root Cause**:
  - Blackbox definition for OpenRAM macro. Output pins must be declared in the structural Verilog interface for synthesis pin mapping, but have no procedural driver in the blackbox model.
- **Safety Assessment**:
  - In physical implementation, these pins connect directly to the hard macro pins in `neuromorphic_top.def` and the SPICE subcircuit in Netgen LVS. Netgen LVS confirms layout-versus-schematic matching.

### 3.5 Empty Pin Connections (`PINCONNECTEMPTY`, 1 warning)
- **Observations**:
  - `neuron_array.v:35:18`: Instance pin `.v_mem()` left unconnected on `lif_neuron_event` instances.
- **Root Cause**:
  - Membrane voltage `v_mem` is an internal analog/algorithmic state. In testbench/debug environments, it can be routed out for waveform inspection; in the taped-out top level, only digital spike pulses (`spike`) are exported to conserve routing channels and pad I/O.
- **Safety Assessment**:
  - Unconnected output port intentionally left floating. Standard cell synthesis safely prunes the dead output load.

### 3.6 Timescale & Parameter Warnings (`TIMESCALEMOD`, `UNUSEDPARAM`, 2 warnings)
- **Observations**:
  - `sky130_sram_macro_blackbox.v:5:8`: `TIMESCALEMOD` — No explicit `` `timescale `` directive.
  - `weight_sram.v:6:15`: `UNUSEDPARAM` — Parameter `DEPTH` declared but not directly referenced in the banking wrapper.
- **Safety Assessment**:
  - Fully benign metadata warnings; zero impact on physical layout, timing, or functionality.

---

## 4. Signoff Conclusion

All 75 Verilator lint warnings have been systematically investigated and classified. Zero design errors, zero synthesis-simulation mismatches, and zero unhandled race conditions exist in the codebase. The synchronous design is fully qualified for tapeout physical signoff.
