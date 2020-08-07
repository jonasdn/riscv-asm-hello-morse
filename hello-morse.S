.section .text

.global _start
_start:
    jal init_led
    la t0, morse_string
loop:
    lb a0, 0(t0)
    beqz a0, break
    jal morse_blink_char
    addi t0, t0, 1
    j loop
break:
    j _start

.section .rodata
morse_string:
    .byte 0x40  # 0b01000000
    .byte 0x10  # 0b00010000
    .byte 0x42  # 0b01000010
    .byte 0x42  # 0b01000010
    .byte 0x37  # 0b00110111
    .byte 0x00
