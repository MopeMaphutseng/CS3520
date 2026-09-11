# CS3520 Lab 2, Exercise 5
# Greatest common divisor using Euclid's algorithm, as a procedure.
# gcd is a leaf procedure - calls nothing - so it does not need to save ra.
# It uses only caller-saved registers t0/t1, so it touches no stack.
# The remainder a mod b is computed by repeated subtraction, so the
# M-extension is not required.
# Arguments: a in a0, b in a1. Return value in a0.

        .data
x:      .word   84
y:      .word   30
msg:    .asciz  "GCD: "

        .text
main:
        lw      a0, x               # first argument
        lw      a1, y               # second argument
        jal     ra, gcd             # call gcd a b

        mv      s0, a0              # keep the result safe across the print
        la      a0, msg             # print "GCD: "
        li      a7, 4
        ecall

        mv      a0, s0              # print the value
        li      a7, 1
        ecall

        li      a7, 10              # exit cleanly
        ecall

# ---------------------------------------------------------------
# gcd a in a0, b in a1 -> gcd in a0
# while b != 0:  r = a mod b;  a = b;  b = r
# a mod b is found by subtracting b from a repeatedly while a >= b.
# leaf procedure: no calls, no callee-saved registers, no stack.
# ---------------------------------------------------------------
gcd:
loop:
        beq     a1, zero, done      # leave the loop once b == 0

        # r = a mod b by repeated subtraction:
        mv      t0, a0              # t0 = working copy of a
        mv      t1, a1              # t1 = working copy of b
mod_loop:
        blt     t0, t1, mod_done    # once a < b, t0 holds the remainder
        sub     t0, t0, t1          # a -= b
        beq     x0, x0, mod_loop

mod_done:
        mv      a0, a1              # a = b
        mv      a1, t0              # b = r
        beq     x0, x0, loop

done:
        jalr    x0, ra, 0           # gcd is already in a0