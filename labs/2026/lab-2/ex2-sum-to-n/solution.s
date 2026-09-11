# CS3520 Lab 2, Exercise 2
# Compute the sum of the first N integers, N stored in memory.
# Counted loop with an inverted exit test, mirroring the array-max example:
# the C++ continues while i <= n, so the assembly exits when n < i.

        .data
n:      .word   10
msg:    .asciz  "Sum: "

        .text
main:
        lw      t0, n               # t0 = n
        li      t1, 1               # t1 = i = 1
        li      t2, 0               # t2 = sum = 0

loop:
        blt     t0, t1, done        # leave the loop once n < i (i.e. i > n)
        add     t2, t2, t1          # sum += i
        addi    t1, t1, 1           # i++
        beq     x0, x0, loop        # repeat

done:
        mv      s0, t2              # keep sum safe across the print calls

        la      a0, msg             # print "Sum: "
        li      a7, 4
        ecall

        mv      a0, s0              # print the value
        li      a7, 1
        ecall

        li      a7, 10              # exit cleanly
        ecall