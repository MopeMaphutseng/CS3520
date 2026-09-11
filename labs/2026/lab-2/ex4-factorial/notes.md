# Exercise 4 — Factorial of N as a procedure

**What it does:** `main` calls the `factorial` procedure with `N = 5` in `a0`;
the procedure returns `5! = 120` in `a0`, which `main` prints. Verified:
`Factorial: 120` matches model.cpp.

**Registers:**
- `a0` — procedure argument (N) in, return value (n!) out
- `ra` — return address, set by `jal` and used by `jalr`
- `t0` — running `result`
- `t1` — loop counter `i`
- `t3`, `t4` — scratch inside the multiply loop
- `s0` — in `main`, holds the returned value across the print calls

**How it works:** `factorial` computes `result *= i` for `i = 2..N`. The loop
tests `blt a0, t1, done`, i.e. exit once `i > n`, because the natural `i <= n`
continue test cannot be expressed directly — the array-max inversion again.
Multiplication is implemented as a nested repeat-add loop so the program runs
with no extension.

**Procedure/stack decisions:** `factorial` is a *leaf* procedure — it calls
nothing — so it does not overwrite `ra`, and there is no need to save it on the
stack. It also uses no callee-saved registers, so it never touches the stack at
all. `main` saves its live value in `s0` (callee-saved from its own point of
view, restored by nobody since main is the program).

**Harder than expected:** two things. (1) Getting the loop bound right the
first time: `bge` with `i >= n` exited one step early and produced 24 (4!)
instead of 120 — the inclusive `i <= n` bound needs the *strict* `i > n` exit
test. (2) Avoiding `mul`: the M-extension is not enabled in default Ripes, so
the factorial multiply is done with an inner add-loop; also the Ripes assembler
rejects parentheses inside comments, which took a moment to track down.