# CS3520 Lab 3 — Processor Simulation and Tracing (Part A)
# trace-classes.s — completed trace tables (Steps 3, 4 and 5)

Program under test: `labs/2026/lab-3-processor-tracing/trace-classes.s`
Processor: **RISC-V Single Cycle Processor** (`RV32_SS`), **Extended** layout,
with *View → Show processor signal values* enabled.
Method: predict from the Week 6/7 datapath first, then read each port
off the simulator with the Clock button and reconcile the two.

Signal encodings used below (from the implementation's enumerated selects):

| Signal | Values |
|---|---|
| `alu_op1_src.select` (AluSrc1) | `0 = REG1`, `1 = PC` |
| `alu_op2_src.select` (AluSrc2) | `0 = REG2`, `1 = IMM` |
| `reg_wr_src.select` (RegWrSrc) | `0 = MEMREAD`, `1 = ALURES`, `2 = PC4` |
| `pc_src.select` (PcSrc) | `0 = PC4`, `1 = ALU` |

---

## Step 3 — One instruction traced completely

Instruction: **`add t2, t0, t1`**, executing at **PC = 0x00000008**.
State at this point: `t0 (x5) = 12`, `t1 (x6) = 5`.
Given entries (`pc_reg.out`, `instr_mem.data_out`, `wr_reg_idx = 7`,
`r1_out/r2_out = 12/5`) were used to confirm the correct ports were being read.

| Element | Port | Value |
|---|---|---|
| `pc_reg` | `out` | `0x00000008` *(given)* |
| `pc_4` | `out` | `0x0000000C` |
| `instr_mem` | `data_out` | `0x006283B3` *(given)* |
| `decode` | `r1_reg_idx` / `r2_reg_idx` | `5` / `6` |
| `decode` | `wr_reg_idx` | `7` *(given)* |
| `control` | `reg_do_write_ctrl` | `1` (asserted — ADD writes x7) |
| `control` | `alu_op2_ctrl` | `0` (AluSrc2::REG2 — operand 2 is a register) |
| `registerFile` | `r1_out` / `r2_out` | `12` / `5` *(given)* |
| `alu_op1_src` | `out` (select) | `12` (`REG1`, select = 0) |
| `alu_op2_src` | `out` (select) | `5` (`REG2`, select = 0) |
| `alu` | `res` | `17` (`0x00000011`) |
| `data_mem` | `wr_en` | `0` (not a store) |
| `reg_wr_src` | `select` / `out` | `1` (`ALURES`) / `17` |
| `pc_src` | `select` / `out` | `0` (`PC4`) / `0x0000000C` |

**Prediction check:** predicted result `17`, write-back source `ALURES`,
PC source `PC4` (no redirect). Simulator agreed on every port.

### Think (Step 3) — `data_mem.addr` on an instruction that ignores memory
`data_mem.addr` is wired directly to `alu.res`, so on this `add` it carries the
ALU sum, **17 (`0x00000011`)**. It is harmless because `mem_do_write_ctrl = 0`
and `mem_do_read_ctrl = 0` for an R-type instruction, so the memory neither
writes nor drives the write-back path (`reg_wr_src` selects `ALURES` anyway).
It still costs the machine: in a single-cycle design the clock period must fit
the *longest* path of *any* instruction, and that longest path is a load
(PC → instr memory → decode → register file → ALU → **data memory** →
write-back). Because that path contains the data memory, `Tc` is stretched for
every instruction — the `add` pays the memory's delay even though it never
uses the result.

---

## Step 4 — One row per instruction class

Program addresses (read from the Instruction memory panel, 4 bytes each; the
`la` on source line 27 expands to two real instructions, so 17 source
instruction lines become **18** machine instructions):

```
0x00 addi  t0, zero, 12      0x24 sw    t2, 4(a0)
0x04 addi  t1, zero, 5       0x28 beq   t0, t1, skip
0x08 add   t2, t0, t1        0x2C bne   t0, t1, target
0x0C sub   t3, t0, t1        0x30 addi  a2, zero, 99   <- never executed
0x10 lui   t4, 0x2B          0x34 jal   ra, report
0x14 auipc t5, 0x0           0x38 addi  a7, zero, 10
0x18 auipc a0, 0x10000  (la) 0x3C ecall
0x1C addi  a0, a0, -24  (la) 0x40 addi  a2, zero, 7
0x20 lw    a1, 0(a0)         0x44 jalr  zero, ra, 0
```

| Instruction | Format | `imm` | op1 mux | op2 mux | `alu.res` | wb mux / pc mux |
|---|---|---|---|---|---|---|
| `addi t0, zero, 12` | I | `12` | `REG1`(0) = 0 | `IMM`(1) = 12 | `12` | `ALURES`(1)=12 / `PC4`(0)=0x04 |
| `add t2, t0, t1` | R | — | `REG1`(0) = 12 | `REG2`(0) = 5 | `17` | `ALURES`(1)=17 / `PC4`(0)=0x0C |
| `lui t4, 0x2B` | U | `0x2B000` (176128) | `REG1`(0) = 0 | `IMM`(1) = 0x2B000 | `176128` | `ALURES`(1)=176128 / `PC4`(0)=0x14 |
| `auipc t5, 0x0` | U | `0` | `PC`(1) = 0x14 | `IMM`(1) = 0 | `20` | `ALURES`(1)=20 / `PC4`(0)=0x18 |
| `lw a1, 0(a0)` | I (load) | `0` | `REG1`(0) = 0x10000000 | `IMM`(1) = 0 | `268435456` | `MEMREAD`(0)=42 / `PC4`(0)=0x24 |
| `sw t2, 4(a0)` | S | `4` | `REG1`(0) = 0x10000000 | `IMM`(1) = 4 | `268435460` | write disabled (mux `ALURES`) / `PC4`(0)=0x28 |
| `beq t0, t1, skip` | B | `8` | `PC`(1) = 0x28 | `IMM`(1) = 8 | `48` (target 0x30) | write disabled / `PC4`(0)=0x2C (**not taken**) |
| `bne t0, t1, target` | B | `8` | `PC`(1) = 0x2C | `IMM`(1) = 8 | `52` (target 0x34) | write disabled / `ALU`(1)=0x34 (**taken**) |
| `jal ra, report` | J | `12` | `PC`(1) = 0x34 | `IMM`(1) = 12 | `64` (target 0x40) | `PC4`(2)=0x38 / `ALU`(1)=0x40 |
| `jalr zero, ra, 0` | I (jalr) | `0` | `REG1`(0) = 0x38 | `IMM`(1) = 0 | `56` (target 0x38) | `PC4`(2)=0x48 (write suppressed, rd=x0) / `ALU`(1)=0x38 |

Notes on the two "special" ALU rows:

* **lui / auipc differ only at the `alu_op1_src` multiplexer.** `lui` selects
  `REG1` (x0 = 0) and its ALU op is `LUI`, which passes operand 2 straight
  through; `auipc` selects `PC`. Same immediate, different addend.
* **Branches and jumps use the ALU to build the target.** `op1 = PC`,
  `op2 = IMM`, ALU op `ADD`, so `alu.res` is the branch/jump target. The
  comparison itself is done by the separate branch unit, not the ALU.
* **`jalr` writes no register** (rd = x0), so although its write-back mux
  selects `PC4 = 0x48`, the register file ignores it; `ra` keeps the `0x38`
  value written by `jal`.

---

## Step 5 — Instruction memory and Statistics panels

Reset, then ran `trace-classes.s` to completion on the single-cycle processor.

| Quantity | Value |
|---|---|
| Instructions listed in the Instruction memory panel | **18** |
| Instructions retired | **17** |
| Cycles | **17** |
| CPI | **1.00** |
| IPC | **1.00** |

The panel lists **18** instructions but only **17** retire. The discrepancy is
the pseudo-instruction: source line 27, `la a0, val`, is *one* line but expands
to *two* machine instructions (`auipc a0, 0x10000` at 0x18 and
`addi a0, a0, -24` at 0x1C). That turns 17 source instruction lines into 18
machine instructions. The one instruction that never executes is
`addi a2, zero, 99` at 0x30: `bne` is taken and branches over it to `target`
(0x34), so it is listed but never retires.

### Think (Step 5) — what the design sacrificed
CPU time = IC × CPI × Tc. This design achieves the best possible CPI
(1.00), so it did not sacrifice instructions or cycles. It sacrificed **Tc,
the clock period** (equivalently, clock *rate*). Everything an instruction
needs happens combinationally inside one clock cycle, so the clock must be
slow enough for the single longest path through the whole datapath — the load
path through instruction memory, the register file, the ALU and data memory,
plus the write-back mux. An ideal pipelined machine splits that same work
across its stages and can clock roughly `number-of-stages` times faster
(≈5× for the classic five-stage pipeline), at the cost of extra registers,
forwarding/hazard logic and a CPI that is no longer exactly 1.
