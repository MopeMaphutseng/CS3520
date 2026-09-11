# Exercise 3 — Count even elements in an array

**What it does:** walks an array of 10 integers stored in `.data`, tests each
element with a bitwise AND, counts those whose bit 0 is 0 (even), and prints
the count. Verified: `Even count: 5` — matches model.cpp.

**Registers:**
- `a0` — base address of the array
- `a1` — `n`
- `t0` — loop index `i`
- `t1` — running `count`
- `t2` — byte offset `i*4` (via `slli`)
- `t3` — address `&array[i]` (base + offset)
- `t4` — `array[i]` value
- `t5` — `array[i] & 1` (the evenness test)

**How it works:** indexing follows array-max.s exactly (`slli` for the word
offset then `add`): an even number has bit 0 clear, so `andi t5, t4, 1` is 0
for even and 1 for odd — `bne t5, zero, increment` therefore skips the count
for odd values. Loop exits with the inverted test `bge t0, a1, done`.

**Harder than expected:** remembering that `andi` needs an immediate, so the
bit test must use a register result (`t5`) and a separate branch — you cannot
`bne andi-result, ...` directly. Also mixing the loop index and the array base
in registers meant carefully keeping the `t0` index separate from the loaded
value `t4`.