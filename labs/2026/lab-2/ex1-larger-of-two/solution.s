# CS3520 Lab 2, Exercise 1
# Print the larger of two integers held in the .data section.
# Uses a single conditional branch (blt) to select the larger value.

        .data
a:      .word   17
b:      .word   42
msg:    .asciz  "Larger: "

        .text
main:
        lw      t0, a               # t0 = a
        lw      t1, b               # t1 = b

        blt     t0, t1, b_is_larger # if a < b, b is the larger
        mv      a0, t0              # else a is the larger
        j       print               # skip past the other case

b_is_larger:
        mv      a0, t1              # a0 = b

print:
        # preserve the result across the string-print call
        mv      s0, a0              # s0 = larger (callee-saved: we own main)

        la      a0, msg             # print "Larger: "
        li      a7, 4
        ecall

        mv      a0, s0              # print the value
        li      a7, 1
        ecall

        li      a7, 10              # exit cleanly
        ecall