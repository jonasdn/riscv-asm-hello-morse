.section .text

.equ MORSE_UNIT_MS, 333         # A morse unit is the length of a dit and also the time to wait
                                # between a dit or a dah. A dah is 3 times a morse unit.
.global morse_blink_char
#
# Arguments:
#   - a0: the length of the morse character
#   - a1: the pattern of the morse character
#
# (see hello-morse.S for details)
#
morse_blink_char:
    addi sp, sp, -16            # We start by adding room on the stack (pointed to by reg sp)
    sw ra, 12(sp)               # Then store ra register so it is not overwritten by function calls
    sw s0, 8(sp)                # Then we store the s0, s1 and s2 registers so that we are not
    sw s1, 4(sp)                # writing over values used by the caller of the function
    sw s2, 0(sp)                # s0 - s11 are called "saved registers" and convention is that one is
                                # meant to trust that they are not overwritten by function calls

    mv s0, a0                   # Since a0 and a1 are used to call functions below, we store the
    mv s1, a1                   # values in s0 and s1.
next:
    li a0, 1                    # li: load immediate: load the constant 1 into a0
    jal led_set                 # call led_set function (argument: 1)
    li a0, MORSE_UNIT_MS        # load the constant MOSE_UNIT_MS into a0
    andi s2, s1, 0x01           # Use and to check if the LSB bit of s1 (morse pattern) is set
    beqz s2, dot                # If it is not, we have a dot (see hello-morse.S for details)
    li a0, 3 * MORSE_UNIT_MS    # If it is set we load a longer wait time into a0 (for a dah)
dot:
    jal wait_ms                 # a0 has MORSE_UNIT_MS or 3xMORSE_UNIT_MS, call wait_ms function
    li a0, 0                    # Load 0 into a0
    jal led_set                 # Call led_set to turn led off after wait.
    li a0, MORSE_UNIT_MS        # Load MORSE_UNIT_MS into a0
    jal wait_ms                 # Call wait_ms to wait a morse unit until next dit or dah.

    srli s1, s1, 1              # Shift the value in s1 (morse pattern) to the right to
                                # "discard" the bit we just examined for dit or dah

    addi s0, s0, -1             # s0 contains the length of the pattern, decrease it ...
    bnez s0, next               # ... and if it is not zero, keep looping

    li a0, 3 * MORSE_UNIT_MS    # Make sure we wait 3 times a morse unit between characters
    jal wait_ms

    lw ra, 12(sp)               # Restore the return and sX registers
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16             # Restore the stack
    ret
