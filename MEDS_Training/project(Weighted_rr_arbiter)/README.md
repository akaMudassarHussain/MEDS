# Weighted Round-Robin Arbiter

This repository contains a weighted round-robin arbiter designed and verified in SystemVerilog. The project covers RTL design, priority rotation, weighted credit tracking, and a self-checking verification suite covering fairness, starvation, and randomized testing.

## Repository Structure

```
project/
│── README.md
│── rtl/
│    ├── priority_arbiter.sv
│    ├── weight_counter.sv
│    └── weighted_rr_arbiter.sv
│── tb/
│    ├── tb_directed.sv
│    └── tb_random_fairness.sv
```

---

# RTL Design

The arbiter is split into three modules so the rotation logic and the weight logic can be debugged independently.

### Modules

- **priority_arbiter.sv** – rotating priority pointer register and priority-rotated request encoder
- **weight_counter.sv** – per-requester credit tracking
- **weighted_rr_arbiter.sv** – top-level controller, combines the two and registers the grant output

Grants and the priority pointer are both registered on the clock edge. Only the scan/encode logic is combinational, and it always feeds into a register before reaching an output.

File:
```
rtl/weighted_rr_arbiter.sv
```

---

# How the Rotation Works

The priority pointer and the weight value are independent of each other.

- The pointer decides whose turn is next, purely by rotation
- The weight decides how many consecutive grants that requester gets once it's their turn

An early version of the pointer update simply did `ptr_q + 1`, which works fine when every requester is asking, but breaks with sparse request patterns — the pointer can end up landing back on the requester it just served. The fix was to advance relative to the actual winner instead:

```systemverilog
ptr_q <= (winner_idx == N-1) ? '0 : (winner_idx + 1'b1);
```

---

# Verification

Two testbenches cover the full scenario list from the project spec.

### tb_directed.sv

- No requests / single requester behavior
- Equal-weight rotation order
- Weight enforcement (consecutive grants)
- Requester deassert / reassert mid-rotation
- Dropped request does not bank leftover credit
- Back-to-back reset

### tb_random_fairness.sv

- Equal / unequal / max / min weight ratio checks
- Intermittent-requester starvation check
- 500+ cycle continuous run, zero starvation violations
- Randomized request and weight combinations

Ratio checks allow ±10% tolerance against each requester's weight share. Starvation checks allow a wait bound of the sum of all other requesters' weights, plus a couple of cycles of slack.

File:
```
tb/tb_directed.sv
tb/tb_random_fairness.sv
```

---

# Reading the Waveform

- View `grant` in binary, not hex — it's one-hot, so hex values like 4, 8, 1 are just 0100, 1000, 0001
- `winner_idx` is a plain decimal index and easier to trace than `grant`
- `grant` lags `winner_valid` by exactly one clock cycle, since it's a registered output
- `exhausted` and `advance` should rise on the same edge

---

# Running the Programs

Open the design and testbench files in QuestaSim (or EDA Playground).

Compile the RTL and testbench.

Run the simulation.

Check the transcript for PASS/FAIL output, and open the waveform for anything sequential.

---

# Requirements

- QuestaSim or Aldec Riviera-PRO (or EDA Playground)
- SystemVerilog

---

# Concepts Covered

- Combinational vs sequential design
- Priority encoding
- Rotating priority pointers
- Credit-based weight enforcement
- Starvation prevention
- Self-checking testbenches
- Ratio and starvation fairness checks
- Randomized verification

---

# Author

**Mudassar**
