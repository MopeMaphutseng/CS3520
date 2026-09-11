# Exercise 1 — Larger of two integers

**What it does:** reads `a = 17` and `b = 42` from `.data`, selects the larger
of the two with a conditional branch, and prints it.

**Registers:**
- `t0` — value of `a`
- `t1` — value of `b`
- `a0` — the chosen larger value, then the print argument
- `s0` — keeps the result safe across the string-print ecall

**How it works:** `blt t0, t1, b_is_larger` jumps to the else-branch when
`a < b`; otherwise execution falls through and `a` is the larger. `j print`
skips the other case. Verified: prints `Larger: 42`, identical to model.cpp.

**Harder than expected:** only the register discipline bit — I originally held
the result in `t2` and lost it when the second ecall used the a-registers;
moving it to callee-saved `s0` before the print calls fixed it.