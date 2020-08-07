.section .text

.equ GPIO_BASE, 0x10012000
.equ GPIO_RED, 0b00000000010000000000000000000000

.global init_led
init_led:
    addi sp, sp, -16
    sw ra, 0(sp)

    li t0, GPIO_BASE
    li t1, GPIO_RED
    sw t1, 0x0c(t0)
    sw t1, 0x40(t0)

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.global set_led
set_led:
    addi sp, sp, -16
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)

    li s0, GPIO_BASE
    beqz a0, off
    li s1, GPIO_RED
    j set_and_ret
off:
    li s1, 0
set_and_ret:
    sw s1, 0x08(s0)

    lw ra, 8(sp)
    lw s0, 4(sp)
    lw s1, 0(sp)
    addi sp, sp, 16
    ret
