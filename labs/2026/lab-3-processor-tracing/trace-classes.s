# ==============================================================
# CS3520 - Lab 3, Part A
# trace-classes.s : one instruction from every RV32I class.
#
# The program is deliberately short and loop-free so that it can
# be stepped one clock at a time. Each line below drives a
# different path through the single-cycle datapath.
#
# NOTE: la is a PSEUDO-INSTRUCTION and expands to two real
# instructions. Always read the instruction count and the
# addresses from the Instruction memory panel, never from this
# file.
# ==============================================================

        .data
val:    .word   42
slot:   .word   0

        .text
main:
        addi    t0, zero, 12        # I-type, arithmetic     t0 = 12
        addi    t1, zero, 5         # I-type, arithmetic     t1 = 5
        add     t2, t0, t1          # R-type                 t2 = 17
        sub     t3, t0, t1          # R-type                 t3 = 7
        lui     t4, 0x2B            # U-type                 t4 = 0x0002B000
        auipc   t5, 0x0             # U-type, PC-relative    t5 = this PC
        la      a0, val             # PSEUDO -> auipc + addi
        lw      a1, 0(a0)           # I-type, load           a1 = 42
        sw      t2, 4(a0)           # S-type                 slot = 17
        beq     t0, t1, skip        # B-type, NOT taken
        bne     t0, t1, target      # B-type, TAKEN
skip:
        addi    a2, zero, 99        # never executed
target:
        jal     ra, report          # J-type

        addi    a7, zero, 10        # exit
        ecall

report:
        addi    a2, zero, 7         # a2 = 7
        jalr    zero, ra, 0         # I-type, jump register
