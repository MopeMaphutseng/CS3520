# ==============================================================
# CS3520 - Lab 3, Part B
# pipeline-basic.s : the pipeline's best case.
#
# Eight instructions, no data dependencies between any of them
# and no branches. Nothing here can stall or go wrong, so the
# cycle count you measure is the pure cost of filling and
# draining the pipeline.
# ==============================================================

        .text
main:
        addi    t0, zero, 1
        addi    t1, zero, 2
        addi    t2, zero, 3
        addi    t3, zero, 4
        addi    t4, zero, 5
        addi    t5, zero, 6
        addi    a7, zero, 10        # exit code
        nop                         # these three nops are load-bearing -
        nop                         # Step 11 asks you to work out why
        nop
        ecall
