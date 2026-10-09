# CS3520 Lab 3 — Google Form answer sheet

Submit these on the CS3520 Lab 3 Google Form (link on Thuto). Numbers only;
hex values are eight digits with no `0x` prefix. One submission per student.

| # | Question | Answer to enter |
|---|---|---|
| Q1 | `trace-classes.s` instructions listed in the Instruction memory panel | `18` |
| Q2 | Of those, how many are never executed | `1` |
| Q3 | Single-cycle CPI reported | `1.00` |
| Q4 | `t4` after `lui t4, 0x2B` (decimal) | `176128` |
| Q5 | `t5` after `auipc t5, 0x0` (decimal) | `20` |
| Q6 | 32-bit encoding of `add t2, t0, t1` | `006283B3` |
| Q7 | Immediate-generator output during `sw t2, 4(a0)` | `4` |
| Q8 | `alu.res` during `sw t2, 4(a0)` (decimal) | `268435460` |
| Q9 | Branch-unit output during `beq t0, t1, skip` | `0` |
| Q10 | `pc_src.select` during `bne t0, t1, target` | `1` |

---

## Why each answer is what it is

**Q1 = 18.** The source has 17 instruction lines, but `la a0, val` (line 27) is
a pseudo-instruction that expands to two real instructions
(`auipc a0, 0x10000` at 0x18 and `addi a0, a0, -24` at 0x1C), giving 18 machine
instructions in the Instruction memory panel.

**Q2 = 1.** Only `addi a2, zero, 99` at address 0x30 never executes:
`beq` falls through and `bne` is taken straight over it to `target` (0x34).
That is 18 listed instructions → 17 retired.

**Q3 = 1.00.** A single-cycle processor retires one instruction per cycle;
the Statistics panel reports 17 cycles for 17 retired instructions, so
CPI = 17/17 = 1.00.

**Q4 = 176128.** `lui` places the 20-bit immediate in the top bits:
`0x2B << 12 = 0x2B000 = 176128`.

**Q5 = 20.** `auipc t5, 0x0` adds 0 to its own address. The instruction sits at
0x14, so `t5 = 0x14 + 0 = 20`.

**Q6 = 006283B3.** `add t2, t0, t1` → R-type: `funct7=0000000`, `rs2=x6`,
`rs1=x5`, `funct3=000`, `rd=x7`, `opcode=0110011` →
`0000000 00110 00101 000 00111 0110011` = `0x006283B3`.

**Q7 = 4.** The S-type immediate for `sw t2, 4(a0)` is `4` (sign-extended to
32 bits, so still 4).

**Q8 = 268435460.** `sw`'s address is `a0 + 4`, which the ALU computes and puts
on `alu.res` / `data_mem.addr`. `la` gives `a0 = 0x10000000`
(`auipc` at 0x18 → 0x10000018, then `addi −24` → 0x10000000), so
`0x10000000 + 4 = 0x10000004 = 268435460`.

**Q9 = 0.** `beq t0, t1, skip` compares `t0 == t1`, i.e. `12 == 5`, which is
false, so the branch unit's output is 0 and the PC does not redirect.

**Q10 = 1.** `bne t0, t1, target` compares `12 != 5`, which is true, so
`br_and`/`controlflow_or` assert and `pc_src.select = 1`, selecting the ALU
(branch-target) input and redirecting the PC to 0x34.
