# ==============================================================
# CS3520 - Lab 3, Part B
# hazard-loaduse.s : the load-use hazard.
#
# A load produces its value in MEM - one stage later than the ALU
# produces an arithmetic result. This is the one data hazard that
# forwarding alone cannot repair.
#
# The address is built with lui rather than la on purpose. la is
# a pseudo-instruction that expands to auipc + addi, and those two
# depend on one another at distance 1 - which is itself a hazard.
# Step 10 asks you to prove that to yourself.
# ==============================================================

        .data
v:      .word   25

        .text
main:
        lui     a0, 0x10000         # a0 = 0x10000000, the start of .data
        nop
        nop
        lw      t0, 0(a0)           # t0 = 25
        addi    t1, t0, 5           # LOAD-USE: intends t1 = 30

        addi    a7, zero, 10        # exit code
        nop                         # these three nops are load-bearing -
        nop                         # Step 11 asks you to work out why
        nop
        ecall
