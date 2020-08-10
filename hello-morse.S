.section .text            # By convention the text section is used for keeping code

.global _start            # The default entry point of the text section (GNU ld will look for this)
_start:
    jal init_led          # jal: correctly set the return register (ra) and jump to init_led
    la t0, morse_string   # Load the address of morse_string to t0 reg
loop:
    lb t1, 0(t0)          # Load one byte from the address found in t0 at offset 0, store in t1
    beqz t1, break        # If the value found in t1 is zero, jump to the break label

    srli a0, t1, 4        # srli: shift the value 4 step to the right, and store in a0. This will
                          # be the length of the morse character (see morse_string comment below)

    andi a1, t1, 0x0f     # andi: mask-out 4 right-most bits of the value and store in a1.
                          # This is the morse pattern to blink (see comment below)

    jal morse_blink_char  # After this we have the length of the morse char in a0 (argument 0) and
                          # the pattern to blink in a1 (argument 1). These are the arguments to the
                          # morse_blink_char function, we call it using the jal instruction.

    addi t0, t0, 1        # Add 1 to t0 to have the loop read the next byte from morse_string
    j loop                # Unconditionally jump to the loop label
break:
    j _start              # Unconditionally jump back to the _start label (loop forever)

.section .rodata          # By convention the rodata section is where const data is kept
#
# The chosen layout for a "morse string" is to use 1 byte per "character"
#   - the 4 MSB bits will represent the length (the number of dits and dahs)
#   - the 4 LSB bits will represent the pattern, 0 for dit and 1 for dah
#
# Example:
#     0011 0100 (0x35)
#
# Length:  0011 (0x03)
# Pattern: 0100 (0x05) => dit dit dah
#
morse_string:
    .byte 0x40  # 'H': dit dit dit dit (0100 0000)
    .byte 0x10  # 'E': dit             (0001 0000)
    .byte 0x42  # 'L': dit dah dit dit (0100 0010)
    .byte 0x42  # 'L': dit dah dit dit (0100 0010)
    .byte 0x37  # 'O': dah dah dah     (0011 0111)
    .byte 0x00  # sentinel: mark the end of the morse string
