# CS3520 Lab 2, Exercise 3
# Count how many elements of an array are even, and print the count.
# Uses andi to test bit 0: an element is even iff bit 0 is clear (result 0).
# Array indexing: offset = i*4, address = base + offset (as in array-max.s).

        .data
array:  .word   1, 2, 3, 4, 5, 6, 7, 8, 9, 10
n:      .word   10
msg:    .asciz  "Even count: "

        .text
main:
        la      a0, array           # a0 = base address of the array
        lw      a1, n               # a1 = n
        li      t0, 0               # t0 = i = 0
        li      t1, 0               # t1 = count = 0

loop:
        bge     t0, a1, done        # leave the loop once i >= n
        slli    t2, t0, 2           # t2 = i * 4 (byte offset)
        add     t3, a0, t2          # t3 = &array[i]
        lw      t4, 0(t3)           # t4 = array[i]

        andi    t5, t4, 1           # t5 = array[i] & 1
        bne     t5, zero, increment # if bit 0 set, skip the count (odd)
        addi    t1, t1, 1           # count++

increment:
        addi    t0, t0, 1           # i++
        beq     x0, x0, loop        # repeat

done:
        mv      s0, t1              # keep count safe across the print calls

        la      a0, msg             # print "Even count: "
        li      a7, 4
        ecall

        mv      a0, s0              # print the value
        li      a7, 1
        ecall

        li      a7, 10              # exit cleanly
        ecall