# Step 5 — Encoding Analysis: B-type and J-type Instructions

Two instructions were chosen from Exercise 4 (factorial.s): a branch and a jump.
The 32-bit encoding Ripes generates for each was reconstructed by computing
fields from the known instruction/offset values, then verified against the
Ripes disassembly which confirmed the encoded offset.

---

## 1. B-type instruction — `blt a0, t1, done` (offset 40)

Source line in ex4-factorial.s (line 30):
```
        blt     a0, t1, done        # leave once i > n
```

Ripes disassembly: `blt x10 x6 40 <done>`
(recorded rs1=x10(a0), rs2=x6(t1), byte offset=40 from the instruction to the
label `done`)

### 32-bit encoding

    0000 0010 0110 0101 0100 0100 0110 0011  =  0x02654463

### Field split (B-type)

| Bit(s)  | Field       | Value        | Meaning                        |
|---------|-------------|-------------|--------------------------------|
| 31      | imm[12]     | 0           | sign bit of the 13-bit immediate |
| 30-25   | imm[10:5]   | 000001      | high 6 bits of offset/2        |
| 24-20   | rs2         | 00110       | x6 = t1                        |
| 19-15   | rs1         | 01010       | x10 = a0                       |
| 14-12   | funct3      | 100         | blt (signed less-than)         |
| 11-8    | imm[4:1]    | 0100        | low 4 bits of offset/2         |
| 7       | imm[11]     | 0           | mid-bit of the immediate       |
| 6-0     | opcode      | 1100011     | B-type (branches)              |

Reconstructing the immediate: imm = (imm[12] << 11) | (imm[11] << 11) |
(imm[10:5] << 5) | (imm[4:1] << 1) = 0 + 0 + (1 << 5) + (4 << 1) = 32 + 8
= **40**. The branch distance is exactly 40 bytes (10 instructions from `blt`
to the `done` label), matching the Ripes disassembly.

---

## 2. J-type instruction — `jal ra, factorial` (offset 44)

Source line in ex4-factorial.s (line 16):
```
        jal     ra, factorial       # call factorial(N)
```

Ripes disassembly: `jal x1 44 <factorial>`
(recorded rd=x1=ra, byte offset=44 from the jal to the procedure label)

### 32-bit encoding

    0000 0001 0110 0000 0000 1000 0110 1111  =  0x0160086F

### Field split (J-type)

| Bit(s)  | Field           | Value          | Meaning                           |
|---------|-----------------|----------------|-----------------------------------|
| 31      | imm[20]         | 0              | sign bit of the 21-bit immediate  |
| 30-21   | imm[10:1]       | 0000010110     | 10 bits of offset/2               |
| 20      | imm[11]         | 0              | mid-bit of the immediate          |
| 19-12   | imm[19:12]      | 00000000       | high 8 bits of the immediate      |
| 11-7    | rd              | 00001          | x1 = ra                           |
| 6-0     | opcode          | 1101111        | J-type (jal)                      |

Reconstructing: imm = (imm[20] << 20) | (imm[10:1] << 1) | (imm[11] << 11) |
(imm[19:12] << 12) = 0 + (22 << 1) + 0 + 0 = **44**, matching the Ripes
disassembly and the 44-byte gap (11 instructions from `jal` to `factorial`).

---

## Why is the immediate stored in scattered pieces?

The RISC-V instruction encoding is designed so that the **register fields occupy
the same bit positions** across the four main formats (R/I/S/B/J):

- rs1 is always at bits 19-15, and rs2 at bits 24-20, wherever they appear.
  This means the same hardware comparator/wiring can locate the registers
  regardless of instruction type.
- rd is always at bits 11-7 in the formats that write back (R/I/J).

To keep this alignment, the immediate field — which is a single contiguous
number in the instruction's semantics — must be split into pieces that fit
around the fixed register slots. In B-type the 13-bit signed immediate is
broken into five pieces (imm[12], imm[10:5], imm[4:1], imm[11]) that wrap
around rs2, rs1, funct3, and the opcode region. The same principle applies to
S-type and J-type.

This trades a small decoding cost (the hardware or assembler must gather the
scattered bits) against a much larger saving: the operand positions are stable,
so the register-file read ports and forwarding logic do not need per-format
multiplexers. For a load-store ISA, that is a significant simplification of
the critical datapath.