# ==============================================================
# CS3520 - Lab 3, Part B
# hazard-raw.s : read-after-write dependencies at three distances.
#
# Every instruction below reads t0, which the first instruction
# writes. They differ only in how far behind it they sit.
#
# BEFORE YOU RUN THIS: write down the value you expect in each
# of t1, t2 and t3 on a processor with no forwarding. Then run
# it and see which of your predictions survived.
# ==============================================================

        .text
main:
        addi    t0, zero, 7         # t0 = 7

        addi    t1, t0, 3           # distance 1   intends t1 = 10
        addi    t2, t0, 100         # distance 2   intends t2 = 107
        addi    t3, t0, 1000        # distance 3   intends t3 = 1007
        addi    a7, zero, 10        # exit code
        nop                         # these three nops are load-bearing -
        nop                         # Step 11 asks you to work out why
        nop
        ecall
