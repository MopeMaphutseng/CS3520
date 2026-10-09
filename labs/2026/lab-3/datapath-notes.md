# CS3520 Lab 3 — Processor Simulation and Tracing (Part A)
# datapath-notes.md — reasoning, Step 4 questions and Step 6 findings

Processor: **RISC-V Single Cycle Processor**, Extended layout, signal values on.
All port values were predicted from the datapath first and then checked against
the simulator.

---

## Step 2 — Reading the datapath: the write-back multiplexer

**Question:** element 14 (`reg_wr_src`) chooses between *three* candidate
results, but the Week 7 truth table has only a two-way `MemtoReg` signal. What
is the third input, and which instructions cannot work without it?

**Answer.** The three inputs to `reg_wr_src` are
`MEMREAD` (data memory output), `ALURES` (ALU result) and **`PC4`** (the
`pc_4` adder output, i.e. the address of the following instruction). The third
input is **PC + 4**, the *link/return address*. It is needed by the two jump
instructions, **`jal` and `jalr`**, which must write the return address into a
destination register (by default `ra`, x1). Neither the ALU nor data memory can
produce that value: the ALU is already busy computing the jump *target*
(PC+imm for `jal`, rs1+imm for `jalr`), and memory holds program data, not the
PC. Without the `PC4` input there would be no way to get the link address into
the register file, so `jal`/`jalr` could not return.

---

## Step 3 — Reading the datapath: the unused data-memory address
See `trace-tables.md` for the `data_mem.addr` discussion.

---

## Step 4 — Four questions on the instruction classes

### Q1. `lui` and `auipc` share a format but differ — which element makes the difference?
They share the U-type format and therefore receive the *same* immediate
(`imm[31:12] << 12`, sign-extended). The difference is at the **first ALU
operand multiplexer, `alu_op1_src`**:

* `lui` → `alu_op1_src` selects `REG1` (rs1, which is x0 = 0); the ALU op is
  `LUI`, which simply passes operand 2, so the result is the immediate itself,
  `0x2B000`.
* `auipc` → `alu_op1_src` selects **`PC`**; the ALU op is `ADD`, so the result
  is `PC + imm`, a PC-relative address.

So the same immediate yields "load upper immediate" versus "add upper
immediate to PC" purely because of *which operand-1 value the mux feeds the
ALU* (this is the port the handout tells you to watch on `auipc` and `jal`).

### Q2. `sw` writes memory but no register — which single control signal expresses that?
**`reg_do_write_ctrl = 0`** (the register-file write-enable, Week 7's
`RegWrite`, is de-asserted for stores). Meanwhile the write-back multiplexer
`reg_wr_src` still has a select value — for a store `reg_wr_src_ctrl` defaults
to `ALURES` (1), so the mux puts the store address calculation on its output —
but that output is harmless because the register file's `wr_en` is 0, so
nothing is committed. (The store operation itself is enabled separately by
`mem_do_write_ctrl = 1`.) For the store in the program, `alu.res = 0x10000004`
appears on the write-back path and is simply ignored.

### Q3. Path from the branch unit to `pc_src` — name every gate
The comparison result travels:

```
branch.res ──► br_and.in[0]
                br_and.in[1] ◄── control.do_branch
   br_and.out ──► controlflow_or.in[0]
                controlflow_or.in[1] ◄── control.do_jump
controlflow_or.out ──► pc_src.select
```

For a branch, `do_jump = 0`, so `pc_src.select = (branch.res AND do_branch)`.
Thus:

* `beq t0, t1, skip` — branch unit compares `t0 == t1` → **false (0)**;
  `br_and` = 0 AND 1 = 0; `controlflow_or` = 0; `pc_src.select = 0` → PC takes
  **PC+4 (0x2C)**, i.e. *no redirect*.
* `bne t0, t1, target` — comparison `t0 != t1` → **true (1)**;
  `br_and` = 1 AND 1 = 1; `controlflow_or` = 1; `pc_src.select = 1` → PC takes
  the **ALU target (0x34)**, i.e. *redirected*.

Same two registers, same gate chain — only the branch unit's own comparison
result differs, and that single bit is what redirects (or does not redirect)
the PC.

### Q4. `jal`/`jalr` write a return address — which write-back input, and why not the ALU or memory?
The `reg_wr_src` input **`PC4`** (`RegWrSrc = 2`) supplies it. It cannot come
from the ALU because the ALU is computing the *jump target* on that same cycle
(`PC + imm`, or `rs1 + imm` for `jalr`); and it cannot come from data memory
because memory is for program data — the value PC+4 lives in the fetch/PC
adder path and is not produced by either the ALU or the memory. For `jal`,
`reg_wr_src_ctrl = PC4` routes `pc_4.out = 0x38` into `ra`. For `jalr` with
`rd = x0` the mux still selects `PC4 = 0x48`, but the write is suppressed.

---

## Step 6 — Three ways the implementation differs from the Week 6 figure

### A. There is no dedicated branch adder — the ALU computes the target
The Week 6 figure shows a separate adder next to the ALU that computes
`PC + branch offset`. In this implementation there is only one adder
(`pc_4` computes PC+4) and **the branch/jump target is computed by the main
ALU**. The control unit routes `PC` to `alu_op1_src` (`AluSrc1::PC`) and the
immediate to `alu_op2_src` (`AluSrc2::IMM`), and sets the ALU op to `ADD`, so
`alu.res = PC + imm`. That result is wired into `pc_src`'s `ALU` input, and the
decision reaches `pc_src.select` through the `br_and`/`controlflow_or` gates.
**Gain:** one fewer 32-bit adder — less area and power — at the cost of a
longer ALU critical path and one extra input (PC) on the operand-1 mux.

### B. A dedicated comparison unit replaces the ALU Zero flag
Week 6 CBZ/`beq` branching is often shown using the ALU's subtraction and its
`Zero` output. Here a separate **`branch` unit** takes `r1_out` and `r2_out`
directly and is driven by `comp_ctrl` (`CompOp`). It can evaluate **`EQ`, `NE`,
`LT`, `LTU`, `GE`, `GEU`** — signed *and* unsigned less-than/greater-equal as
well as equality. A subtraction `Zero` flag alone can only express equality
(and, with the sign bit, some ordering), so a single `Zero` line cannot cover
the full set. The instructions that need this unit are the six branches:
**`beq, bne, blt, bge, bltu, bgeu`**. **Gain:** all six branch conditions come
straight from one comparator, with the comparison kept off the ALU entirely,
simplifying control.

### C. The write-back multiplexer has three inputs, not two
The textbook's `MemtoReg` mux chooses between the ALU result and memory read
data. This implementation's `reg_wr_src` chooses among **`MEMREAD`, `ALURES`
and `PC4`**. The third input, `PC4`, is the return address required by **`jal`
and `jalr`** (see Step 2). The two-input `MemtoReg` cannot express a
return-address source at all, so `jal`/`jalr` would be impossible.

### Step 6 trade-off — dedicated branch adder vs. ALU sharing
Both designs are correct; they optimise different things.

* **Textbook (dedicated adder):** the branch target is computed in parallel
  with the ALU, so the ALU critical path stays short and the branch/jump target
  is not stuck behind ALU operations. It spends an extra adder. Choose this
  when **maximising clock frequency** matters most and silicon area allows it.
* **This implementation (shared ALU):** reuses the existing adder, saving area
  and power, but lengthens the ALU combinational path (PC+imm must now pass
  through the operand mux and ALU). Choose this when **minimising area/cost**
  dominates — e.g. a low-frequency or area-constrained design, or a teaching
  model where clarity and a small component count matter more than speed.

---

## Google Form — numerical answers (numbers only)

| # | Question | Answer |
|---|---|---|
| Q1 | Instructions listed in the Instruction memory panel | `18` |
| Q2 | Of those, how many are never executed | `1` |
| Q3 | Single-cycle CPI reported | `1.00` |
| Q4 | `t4` after `lui t4, 0x2B`, decimal | `176128` |
| Q5 | `t5` after `auipc t5, 0x0`, decimal | `20` |
| Q6 | 32-bit encoding of `add t2, t0, t1` (8 hex digits, no 0x) | `006283B3` |
| Q7 | Immediate-generator output during `sw t2, 4(a0)` | `4` |
| Q8 | `alu.res` during `sw t2, 4(a0)`, decimal | `268435460` |
| Q9 | Branch-unit output during `beq t0, t1, skip` | `0` |
| Q10 | `pc_src.select` during `bne t0, t1, target` | `1` |

Working for the less obvious ones:

* **Q1/Q2** — 17 source instruction lines; `la` expands to two, giving 18
  machine instructions. `bne` skips `addi a2, zero, 99` (0x30), so exactly one
  of the 18 never retires (17 retired, confirmed by the Statistics panel).
* **Q4** — `lui` shifts the 20-bit immediate to the top: `0x2B << 12 =
  0x2B000 = 176128` (register x29 = 176128).
* **Q5** — `auipc t5, 0x0` adds 0 to its own address, 0x14: `t5 = 20`
  (register x30 = 20).
* **Q8** — `sw` address = `a0 + 4`. `la` produced `a0 = 0x10000000`
  (auipc at 0x18 gives 0x10000018, then addi −24), so
  `0x10000000 + 4 = 0x10000004 = 268435460`. This is the address the ALU
  computes and puts on `alu.res`/`data_mem.addr`.
* **Q9** — `beq` tests `t0 == t1` → `12 == 5` is false → branch unit output 0.
* **Q10** — `bne` tests `t0 != t1` → true, so `controlflow_or` asserts and
  `pc_src.select = 1` (ALU target selected).
