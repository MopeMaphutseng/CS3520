# Exercise 5 — Greatest common divisor (Euclid's algorithm)

**What it does:** `main` passes `a = 84, b = 30` to the `gcd` procedure,
which returns `6` by Euclid's algorithm. Verified: `GCD: 6`, matching model.cpp.

**Registers:**
- `a0` — procedure argument (a) / return value (gcd)
- `a1` — procedure argument (b)
- `t0` — working copy of `a`, used during repeated subtraction; holds the
  remainder `r` after the inner loop
- `t1` — working copy of `b` inside the inner loop
- `s0` — in `main`, holds the returned value across the print calls

**How it works:** the outer loop tests `beq a1, zero, done`; if `b == 0` the
algorithm stops, with `a` already holding the gcd. Otherwise it computes `r = a
mod b` by a second inner loop that repeatedly subtracts `b` from `a` while `a >=
b` (`blt` is the exit test). The remainder in `t0` becomes the new `b`, and the
old `b` becomes the new `a`. The asm swaps in one sweep: `mv a0,a1` then
`mv a1,t0`.

**Procedure decisions:** `gcd` is a leaf, so `ra` needs no saving. It uses only
caller-saved `t0`/`t1`, so it never touches the stack. If the procedure were
non-leaf — or used an `s`-register — the stack would be required.

**Harder than expected:** computing the remainder without `rem` was the
challenge. Euclid's algorithm naturally calls for `a mod b`, and `rem` is an M-
extension instruction that default Ripes does not enable. Implementing the
remainder by a nested repeat-subtract loop kept the solution self-contained and
also made the exercise more instructive: you end up with a procedure containing
two loops and two branches, reinforcing both patterns.