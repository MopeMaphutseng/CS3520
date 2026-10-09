# ==============================================================
# CS3520 - Lab 3, Part B
# hazard-control.s : the control hazard.
#
# The branch below is taken. Open the stage table and look at
# what happens to the two instructions sitting behind it.
#
# The two nops are load-bearing. Work out what they are for,
# then delete them and explain what changes and why.
# ==============================================================

        .text
main:
        addi    t0, zero, 1
        addi    t1, zero, 1
        nop
        nop
        beq     t0, t1, here        # TAKEN

        addi    t2, zero, 55        # must NOT take effect
        addi    t3, zero, 66        # must NOT take effect

here:
        addi    t4, zero, 77
        addi    a7, zero, 10        # exit code
        nop                         # these three nops are load-bearing -
        nop                         # Step 11 asks you to work out why
        nop
        ecall
