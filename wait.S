.section .text

.equ MTIME_REG, 0x200bff8   # The memory address of the timer register for the FE310-GOO2
.equ RTC_FREQ, 33           # The RTC is driven at 32.768 kHz (taken from manual)

.global wait_ms             # Make the wait_ms symbol global, so other (object) files can find it
#
# Arguments:
#   - a0: number of milliseconds to busy wait
#
wait_ms:
    addi sp, sp, -16        # We start by adding room on the stack (pointed to by reg sp)
    sw s0, 8(sp)            # Then we store the s0,s1 and s2 registers on the stack so that we are
    sw s1, 4(sp)            # not writing over values used by the caller of the function.
    sw s2, 0(sp)            # s0 - s11 are called "saved registers" and convention is that one is
                            # meant to trust that they are not overwritten by function calls

    li s0, MTIME_REG        # li: load immediate: load the constant MTIME_REG into s0
    lw s1, 0(s0)            # lw: load word: load the value at offset 0 of MTIME_REG into s1
                            # This will get us the current number of cycles counted by the RTC

    li s2, RTC_FREQ         # Load the constant RTC_FREQ into S2
    mul s2, s2, a0          # Multiply the number of milliseconds to wait with the RTC frequency
                            # (divided by zero). This will get us how many cycles to wait

    add s2, s1, s2          # And number of cycles to wait to the current number of cycles
cmp_time:
    lw s1, 0(s0)            # Load current number of cycles into s1
    blt s1, s2, cmp_time    # If current number of cycles are lower than target, keep looping

    lw s0, 8(sp)            # Restore all sX registers.
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16         # Restore stack
    ret
