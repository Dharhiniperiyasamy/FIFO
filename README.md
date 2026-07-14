# Synchronous FIFO Design & Verification (Verilog)

![Verilog](https://img.shields.io/badge/Language-Verilog%20HDL-orange)
![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado%202024.1-blue)
![Status](https://img.shields.io/badge/Verification-16%2F16%20PASS-brightgreen)
![Domain](https://img.shields.io/badge/Domain-VLSI%20%7C%20Digital%20Design-purple)

A parameterized **Synchronous FIFO (First-In-First-Out)** designed in Verilog HDL and verified using a **self-checking testbench**, **reference-model scoreboard**, **boundary-condition testing**, and **fault injection methodology**. Simulated using **Xilinx Vivado 2024.1 (XSIM)**.

---

## Project Highlights

- Parameterized FIFO architecture (configurable depth and data width)
- Single-clock (synchronous) FIFO implementation
- Full, Empty, Almost Full, and Almost Empty status flags
- Self-checking verification environment with automated pass/fail reporting
- Reference-model scoreboard for automatic result comparison
- Boundary-condition and negative testing
- Fault injection to validate testbench effectiveness
- **100% test pass rate** after design correction (16/16 PASS)

---

## Project Objective

FIFO memories are widely used as temporary buffers between hardware blocks operating at different processing rates. This project focuses on both:

1. **RTL Design** — Creating a reliable, parameterized FIFO architecture
2. **Functional Verification** — Building a self-checking verification environment capable of automatically detecting design failures without manual waveform inspection

---

## FIFO Architecture

### Parameters

| Parameter | Value |
|---|---|
| Data Width | 8-bit (Parameterizable) |
| FIFO Depth | 8 Entries (Parameterizable) |
| Clock Domain | Single Clock (Synchronous) |
| Reset Type | Synchronous Reset |
| Flags | Full, Empty, Almost Full, Almost Empty |

### Internal Design

The FIFO uses:
- Memory array for data storage
- Read pointer and Write pointer
- Occupancy tracking logic
- Status flag generation

To correctly distinguish between **Full** and **Empty** states after pointer wrap-around, the design uses an additional **MSB (Most Significant Bit)** in both pointers.

#### Empty Condition
```verilog
assign empty = (wr_ptr == rd_ptr);
```

#### Full Condition
```verilog
assign full = (wr_addr == rd_addr) && (wr_ptr[PTR_W] != rd_ptr[PTR_W]);
```

This technique prevents ambiguity when pointers wrap around FIFO memory boundaries.

---

## Verification Methodology

### Self-Checking Testbench

The verification environment automatically validates DUT behavior without manual checking.

Features:
- Automated pass/fail reporting at each test stage
- Scoreboard-based comparison against reference model
- Error counting and summary reporting
- Boundary-condition verification
- Negative testing (illegal operations)

### Reference Model Scoreboard

A behavioral queue acts as the **golden reference model**.

**Workflow:**
1. Every successful write is pushed into the reference queue
2. Every FIFO read pops the expected value from the queue
3. DUT output is automatically compared against expected value
4. Any mismatch generates a test failure with detailed error message

---

## Test Scenarios & Results

| Test Case | Objective | Result |
|---|---|---|
| Basic Write/Read Verification | Verify FIFO preserves data ordering | ✅ PASS |
| Full Flag Boundary Test | Verify full flag assertion at correct occupancy | ✅ PASS |
| Empty Flag Boundary Test | Verify empty flag assertion after drain | ✅ PASS |
| Illegal Write Protection | Verify writes blocked when FIFO is full | ✅ PASS |
| Illegal Read Protection | Verify reads blocked when FIFO is empty | ✅ PASS |
| Scoreboard Verification | Automatic data integrity check | ✅ PASS |
| Fault Injection Detection | Verify testbench catches real design bugs | ✅ Confirmed |
| **Overall Verification** | **All test cases** | **✅ 16/16 PASS** |

---

## Fault Injection Validation

A critical part of verification is **proving the testbench can detect real bugs**.

### Injected Bug
```verilog
// Incorrect full flag logic (deliberately injected)
assign full = (wr_addr == rd_addr);  // Missing MSB check
```

### Problem Created
Immediately after reset:
- `wr_ptr = 0`, `rd_ptr = 0`
- Therefore `full = 1` — FIFO incorrectly believed it was full from cycle 1
- All writes were blocked, no data entered the FIFO
- Subsequent reads returned invalid data `(00)` instead of expected data `(AA)`

### Verification Results with Bug

| Metric | With Bug | After Fix |
|---|---|---|
| PASS | 5 | **16** |
| FAIL | 11 | **0** |

Scoreboard immediately caught the mismatch:
```
Expected = AA
Received = 00
→ TEST FAILED
```

This confirmed the verification environment successfully detects real design failures.

---

## Simulation Flow (Xilinx Vivado)

```
1. Create new Vivado project
2. Add sync_fifo.v  →  Design Source
3. Add fifo_tb.v    →  Simulation Source
4. Run Behavioral Simulation (XSIM)
5. Observe:
   - Tcl Console: pass/fail summary
   - Waveform viewer: signal behavior
   - Scoreboard output: data comparison
```

---

## Project Structure

```
Synchronous_FIFO/
├── sync_fifo.v        # FIFO RTL Design (parameterized)
├── fifo_tb.v          # Self-checking Testbench with scoreboard
├── waveform.png       # Simulation Waveform (optional)
├── results.png        # PASS/FAIL Results (optional)
└── README.md          # Project documentation
```

---

## Key Learning Outcomes

- RTL design using Verilog HDL
- FIFO architecture and pointer management
- Full/Empty flag generation with MSB technique
- Self-checking verification methodologies
- Scoreboard-based functional verification
- Boundary-condition and negative testing
- Fault injection and debug analysis
- Simulation using Xilinx Vivado XSIM

---

## Future Enhancements

- [ ] Constrained-random verification
- [ ] Functional coverage collection
- [ ] Assertion-based verification (SVA)
- [ ] SystemVerilog testbench migration
- [ ] UVM-based verification environment
- [ ] Dual-clock asynchronous FIFO implementation

---

## Tools & Technologies

| Tool/Technology | Purpose |
|---|---|
| Verilog HDL | RTL Design & Testbench |
| Xilinx Vivado 2024.1 | Synthesis & Simulation |
| XSIM Simulator | Functional Verification |
| Digital Logic Design | FIFO Architecture |

---

## Author

**Dharshini Periyasamy**

Electronics and Communication Engineering (ECE)
VSB Engineering College, Karur, Tamil Nadu

**Areas of Interest:**
- VLSI Design
- FPGA Development
- Digital IC Verification
- ASIC Front-End Design

[![GitHub](https://img.shields.io/badge/GitHub-Dharhiniperiyasamy-black?logo=github)](https://github.com/Dharhiniperiyasamy)
[![ECE Study Hub](https://img.shields.io/badge/Project-ECE%20Study%20Hub-green)](https://dharhiniperiyasamy.github.io/ece-study-hub)

---

⭐ If this project helped you, please give it a star!
