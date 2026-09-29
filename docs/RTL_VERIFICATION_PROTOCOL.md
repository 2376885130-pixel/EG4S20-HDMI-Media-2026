# RTL Verification Protocol

## Status

Repository-wide verification policy.

Current project evidence level:

PRE-OFFICIAL-BASELINE

The official RTL and custom RTL have not yet been imported.

---

## 1. Verification Philosophy

Specification is the highest authority.

The goal of verification is not merely to make a testbench report PASS.

Verification must determine whether the RTL satisfies:

- competition specification
- protocol requirements
- module interface definitions
- timing requirements
- system design constraints

To obtain a PASS result, it is forbidden to:

- modify correct test expectations
- delete failing tests
- weaken assertions
- reduce random-test coverage without evidence
- ignore warnings or errors
- bypass corner cases
- change the real meaning of the specification
- modify a top-level interface without a documented basis

Specification > Verification > PASS count.

---

## 2. Verification Environment

Open-source verification should run primarily under WSL Ubuntu.

Main tools and responsibilities:

| Tool | Responsibility |
|---|---|
| Verilator | Strict lint, RTL simulation, regression |
| Icarus Verilog | Independent cross-simulation |
| Python | Golden Reference Model, random-vector generation, result comparison |
| Yosys | Independent synthesis sanity check |
| GTKWave | Failure waveform investigation |
| TangDynasty | Vendor synthesis, Place & Route, utilization, Static Timing Analysis, bitstream |

Yosys cannot replace TangDynasty.

TangDynasty is the authority for final EG4S20 FPGA implementation results.

---

## 3. Stage A — Environment Check

Before verification, record the actual output of:

```text
verilator --version
iverilog -V
vvp -V
yosys -V
python3 --version
```

If a tool is unavailable, report it as unavailable or NOT VERIFIED.

Never claim that an unavailable stage executed successfully.

---

## 4. Stage B — RTL Lint

Run strict Verilator lint on the affected RTL and the applicable integration scope.

Analyze at least:

- syntax
- width mismatch
- unused signals
- undriven signals
- multiple drivers
- inferred latches
- combinational loops
- blocking / non-blocking misuse
- clock and reset problems
- FSM problems
- counter boundary problems

Every warning must be understood and classified.

Do not disable a warning merely to obtain a clean result.

Any justified waiver must record the warning, reason, affected scope, and residual risk.

---

## 5. Stage C — Directed Simulation

Run the existing testbenches applicable to the changed behavior.

Directed testing should consider:

- normal case
- reset
- boundary conditions
- continuous input
- back-to-back operations
- minimum value
- maximum value
- invalid input
- error handling
- recovery
- timing boundaries
- critical FSM transitions

Preserve a failing case before modifying RTL or testbench code.

---

## 6. Stage D — Cross-Simulator Verification

Run critical tests with both:

- Verilator
- Icarus Verilog

If results differ, record:

CROSS-SIM FAIL

Do not declare the module verified.

Investigate simulator semantic differences, RTL defects, testbench defects, initialization assumptions, race conditions, and unsupported constructs.

---

## 7. Stage E — Random Regression

Modules suitable for randomized testing must run a reproducible random regression.

Record:

- random seed
- number of tests
- PASS count
- FAIL count
- first failing case

Every failing seed must be reproducible.

Do not shrink the random range only to hide a failure.

---

## 8. Stage F — Golden Reference

Algorithmic and protocol modules should use an independent Python Golden Reference Model when applicable.

Examples include:

- parsers
- encoders and decoders
- checksums or CRC, if introduced
- mathematical or algorithmic modules, if introduced

Comparison flow:

```text
Random Input
    |
    +----> RTL DUT
    |
    +----> Python Golden Model
    |
    +----> Compare Result
```

The Golden Model must be independently derived from the specification.

Do not translate the RTL line by line, because this can reproduce the same design error in both implementations.

---

## 9. Stage G — Yosys Synthesis Sanity

Use Yosys, where supported by the RTL and IP boundary, to check:

- synthesis success
- inferred latches
- undriven logic
- unexpected optimization
- FSM recognition
- unexpected register removal

Encrypted or vendor-specific IP may require black-box handling or may prevent this stage.

In that case, report the exact limitation.

Yosys PASS != FPGA implementation PASS.

---

## 10. Stage H — TangDynasty

Final FPGA implementation must use Anlogic TangDynasty for the HX4S20C / EG4S20 target.

Check:

- Synthesis
- Place & Route
- Resource Utilization
- Timing Constraints
- Static Timing Analysis
- Critical Path
- Setup / Hold
- Bitstream generation

If TangDynasty cannot be run in the current environment, record:

VENDOR IMPLEMENTATION NOT VERIFIED

Never claim TangDynasty PASS without actual tool output.

---

## 11. Stage I — Hardware Verification

Always distinguish:

- RTL Simulation
- FPGA Implementation
- Hardware Verification

Only an actual programmed HX4S20C board test may be marked:

HARDWARE PASS

Code inspection, simulation, synthesis, Place & Route, and bitstream generation are not hardware verification.

---

## 12. PASS Levels

Use these levels exactly and independently:

- COMPILE PASS
- LINT PASS
- SIMULATION PASS
- CROSS-SIM PASS
- RANDOM REGRESSION PASS
- GOLDEN MODEL PASS
- SYNTHESIS SANITY PASS
- VENDOR SYNTHESIS PASS
- TIMING PASS
- BITSTREAM PASS
- HARDWARE PASS

Do not describe SIMULATION PASS as FULL DESIGN VERIFIED.

Any stage that was not actually executed must be marked NOT VERIFIED.

---

## 13. Bug-Fix Workflow

When a problem is found:

1. Preserve the failing case.
2. Identify the root cause.
3. Classify it as RTL, Testbench, Specification, or Tool Compatibility.
4. Apply the minimum necessary change.
5. Re-run the failing test.
6. Re-run related tests.
7. Run the full applicable regression.
8. Check that no regression was introduced.
9. Report the results and unverified stages.

Correct testbench expectations must not be modified to accommodate incorrect RTL.

---

## 14. Change Scope

One Change -> Verify -> Commit

Each fix should address one root cause whenever practical.

Avoid unrelated refactoring, formatting churn, interface changes, or high-risk subsystem changes.

Preserve a rollback path.

---

## 15. Project-Specific Verification Guidance

The repository is currently PRE-OFFICIAL-BASELINE.

The following guidance is based on documented architecture and must be updated after the official RTL is imported and inspected.

### TF / SD / SPI Path

Verify card initialization, command timeout, sector boundaries, continuous reads, interrupted transfers, invalid responses, reset recovery, and back-to-back requests.

### BMP Parser and Image Path

The documented project includes a BMP parser.

Use independent Python-generated BMP data and expected pixel output where practical.

Test valid headers, invalid headers, truncated files, dimensions, row padding, pixel ordering, color conversion, first/last pixel, first/last row, and end-of-image behavior.

### FIFO / CDC / SDRAM Framebuffer

Verify independent clock relationships, reset behavior, overflow, underflow, full/empty boundaries, event transfer, frame completion semantics, address boundaries, and sustained throughput.

Specifically distinguish:

- source_done
- fifo_empty
- sdram_write_done
- frame_ready
- frame_committed
- display_buffer
- write_buffer

Verify the invariant:

```text
write_buffer != display_buffer
```

### Video Timing and HDMI Media Pipeline

Verify DE, HSYNC, VSYNC, active-area boundaries, frame and line lengths, RGB/control alignment, pipeline latency, blanking behavior, AXI-Stream handshakes if present, reset, continuous frames, and backpressure behavior if supported.

Vendor HDMI TX and PHY blocks must not be treated as verified merely because surrounding RTL simulates.

Final HDMI behavior requires TangDynasty implementation and board/display evidence.

### Audio Path

The documented baseline includes test tone, I2S, PCM, and HDMI audio.

Verify sample rate, channel ordering, word alignment, valid timing, reset, continuous samples, video/audio coexistence, and hardware output.

### Control and Planned UART Diagnostics

Verify manual switching, automatic playback, repeated commands, debounce assumptions, busy-state behavior, timeout, reset, error recovery, and long-run operation.

UART is currently a planned diagnostic extension rather than a code-confirmed module.

If UART RTL is introduced, add baud-tolerance testing, sampling-phase sweep, back-to-back bytes, framing errors, invalid stop bits, reset during receive, random bytes, and variable idle intervals.

### Not Currently Present

CRC, Huffman, and expression-calculator RTL are not currently documented or tracked in this repository.

Do not claim that their verification exists.

If such modules are later added, extend this protocol based on their actual interfaces and specifications.

---

## 16. Required Verification Report

Every RTL verification report must include at least:

```text
Verification Target:
Specification Reference:
Files Changed:
Files Intentionally Unchanged:
Root Cause:
Tool Versions:
Verilator Lint:
Verilator Simulation:
Icarus Simulation:
Directed Tests:
Boundary Tests:
Random Regression:
Random Seeds:
Golden Reference:
Yosys Synthesis:
TangDynasty Status:
Timing Status:
Hardware Status:
Known Risks:
Not Verified Items:
Final Conclusion:
```

Use PASS only for stages supported by actual execution evidence.

Use NOT VERIFIED for all stages not executed.
