# CS3520 Lab 2 — Assembly Programming II

Solutions to Lab 2 by **Engineer Sammy**.

## Step 2 — Worked example discussion questions

Studied `examples/2026/array-max/`. The C++ model (g++ run) and the assembly
(`array-max.s`, run in Ripes) both print `Maximum: 93`.

### 1. Why is `i < n` inverted to `bge` in the assembly?

RISC-V has no "branch if less than" instruction; its only signed-lt test is
`blt`, and here the natural loop-exit test is the *negation* of the C++ guard.
The C++ says `continue while (i < n)`. The assembly needs a single branch that
leaves the loop: "if `i >= n`, go to done". `bge t1, a1, done` is exactly that
negation, so the branch points *out* of the loop to the code after it. Inverting
the test is required because RISC-V branches are conditional *jumps*: you jump
when the *exit* condition holds, not when the *continue* condition holds.

### 2. What real instructions do `li`, `mv`, `la`, `ble` expand into?

Verified against the machine code Ripes generates:

* `la a0, array` → `auipc a0, %pcrel_hi(array)` + `addi a0, a0, %pcrel_lo(array)`
  — two instructions that build a 32-bit PC-relative address.
* `lw a1, n` → `auipc a1, ...` + `lw a1, offset(a1)` — because the label `n`
  also needs a 32-bit address; Ripes folds it into the load.
* `li a7, 4` → `addi a7, x0, 4` — a single I-type instruction with the zero
  register as source (only valid for small immediates; large ones need
  `lui`+`addi`).
* `mv a0, s0` → `addi a0, s0, 0` — an add with an immediate of zero.
* `ble t4, s1, skip` → `bge s1, t4, skip` — the operands are swapped so the
  branch condition becomes true when the original "less or equal" test is false.

Pseudo-instructions exist so that source code reads like the intent (and like
C), and so the assembler—which knows the encoding details—can pick the cheapest
real instructions. `li`, `mv`, `la` and `ble` are conveniences; `addi`, `lui`,
`auipc`, `bge` are the real ISA.

### 3. Why does `find_max` save `s1` but not `ra`?

The calling convention says:
* `s1` is **callee-saved**: if the callee touches it, it must restore the
  caller's value before returning. `find_max` uses `s1` as its running max, so
  it must push the old value and pop it on return — hence the `addi sp,sp,-4`
  / `sw s1,0(sp)` ... `lw s1,0(sp)` / `addi sp,sp,4` prologue/epilogue.
* `ra` (the return address) is only preserved by the *caller* for a non-leaf
  procedure. `find_max` is a **leaf**: it calls nothing, so it never overwrites
  `ra` during its own execution, and saving it would be pointless. (Only a
  procedure that itself calls another procedure — nested via `jal` — must save
  `ra`.) Both decisions are therefore correct.

---

## Structure

```
labs/2026/lab-2/
├── README.md                    ← this file
├── encoding-analysis.md         ← Step 5: B-type and J-type field analysis
├── ex1-larger-of-two/           model.cpp, solution.s, notes.md
├── ex2-sum-to-n/                model.cpp, solution.s, notes.md
├── ex3-count-evens/             model.cpp, solution.s, notes.md
├── ex4-factorial/               model.cpp, solution.s, notes.md
└── ex5-gcd/                     model.cpp, solution.s, notes.md
```