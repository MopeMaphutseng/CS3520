# CS3520 Lab 2, Exercise 4
# Factorial of N computed by a procedure that main calls.
# factorial is a leaf procedure - it calls nothing - so it never needs to
# save ra, and it uses no callee-saved registers, so it touches no stack.
# Multiplication is done by repeated addition, so no M-extension is needed.
# Argument N in a0; return value in a0, per the calling convention.

        .data
n:      .word   5
msg:    .asciz  "Factorial: "

        .text
main:
        lw      a0, n               # argument: N
        jal     ra, factorial       # call factorial N

        mv      s0, a0              # keep the result safe across the print
        la      a0, msg             # print "Factorial: "
        li      a7, 4
        ecall

        mv      a0, s0              # print the value
        li      a7, 1
        ecall

        li      a7, 10              # exit cleanly
        ecall

# ---------------------------------------------------------------
# factorial n in a0 -> n! in a0
# leaf procedure: calls nothing, uses only caller-saved registers,
# so it neither saves ra nor uses the stack.
# ---------------------------------------------------------------
factorial:
        li      t0, 1               # result = 1
        li      t1, 2               # i = 2

loop:
        blt     a0, t1, done        # leave once i > n
        # multiply result by i with repeated addition:
        mv      t3, t0              # t3 = copy of the current result
        li      t0, 0               # t0 = 0, will become result*i
        li      t4, 0               # once = 0
mul_loop:
        bge     t4, t1, loop_next   # added i times yet?
        add     t0, t0, t3          # result += original result
        addi    t4, t4, 1           # once++
        beq     x0, x0, mul_loop
loop_next:
        addi    t1, t1, 1           # i++
        beq     x0, x0, loop

done:
        mv      a0, t0              # place the result where main looks
        jalr    x0, ra, 0           # return to main