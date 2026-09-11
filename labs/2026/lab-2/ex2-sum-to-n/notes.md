# Exercise 2 — Sum of the first N integers

**What it does:** loads `N = 10` from `.data` and computes `1+2+...+10 = 55`
with a counted loop, then prints it.

**Registers:**
- `t0` — `n` (loop bound)
- `t1` — loop counter `i`
- `t2` — running `sum`
- `s0` — carries `sum` to the print section

**How it works:** the loop accumulates `sum += i` while `i <= n` and exits via
`blt t0, t1, done` — "leave the loop once `n < i`". This is the inverted exit
test from the array-max example: RISC-V branches jump *out* of a loop when the
negated condition holds.

**Harder than expected:** choosing the exit test. `while (i <= n)` becomes
"exit when `i > n`", and expressing that with real instructions (`blt`) instead
of the pseudo `bgt` took a moment — the array-max `bge` pattern doesn't apply
directly because this loop bound is *inclusive*.