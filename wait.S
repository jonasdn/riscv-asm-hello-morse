.section .text
.global wait_ms

.equ MTIME_REG, 0x200bff8
.equ RTC_FREQ, 33

wait_ms:
    addi sp, sp, -16
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    li s0, MTIME_REG
    lw s1, 0(s0)
    li s2, RTC_FREQ
    mul s2, s2, a0
    add s2, s1, s2
cmp_time:
    lw s1, 0(s0)
    blt s1, s2, cmp_time

    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
