.section .text
.global morse_blink_char

.equ MORSE_UNIT_MS, 333

morse_blink_char:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    mv s0, a0
    mv s1, a1
next:
    li a0, 1
    jal set_led
    li a0, MORSE_UNIT_MS
    andi s2, s1, 0x01
    beqz s2, dot
    li a0, 3 * MORSE_UNIT_MS
dot:
    jal wait_ms
    li a0, 0
    jal set_led
    li a0, MORSE_UNIT_MS
    jal wait_ms
    srli s1, s1, 1
    addi s0, s0, -1
    bnez s0, next

    li a0, 3 * MORSE_UNIT_MS
    jal wait_ms

    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
