.section .text

.equ GPIO_BASE, 0x10012000  # The memory address of the FE310-G002 GPIO instance
.equ GPIO_RED,  0x400000    # Bit 22 out of 32 set: 0b00000000010000000000000000000000
                            # Bit 22 will correspond to GPIO 22, where the red led is connected

.global init_led            # Make the init_led symbol global, so other (object) files can find it
init_led:
    li t0, GPIO_BASE        # li: load immediate: load the constant GPIO_BASE into t0
    li t1, GPIO_RED         # Load the constant GPIO_RED into t1
                            #
                            # RISC-v uses memory mapped io (MMIO) we interface with the GPIOs
                            # using regular memory instructions.
                            # The FE310-G002 manual tells us that the memory map of the GPIO
                            # control registers is:
                            #
                            # Offset    Name        Description
                            # 0x00      input_val   Pin value
                            # 0x04      input_en    Pin input enable*
                            # 0x08      output_en   Pin output enable*
                            # 0x0C      output_val  Output value
                            # 0x10      pue         Internal pull-up enable*
                            # 0x14      ds          Pin drive strength
                            # 0x18      rise_ie     Rise interrupt enable
                            # 0x1C      rise_ip     Rise interrupt pending
                            # 0x20      fall_ie     Fall interrupt enable
                            # 0x24      fall_ip     Fall interrupt pending
                            # 0x28      high_ie     High interrupt enable
                            # 0x2C      high_ip     High interrupt pending
                            # 0x30      low_ie      Low interrupt enable
                            # 0x34      low_ip      Low interrupt pending
                            # 0x40      out_xor     Output XOR (invert)
                            #
                            # And that each register is (number of gpios) 32 bits wide.

    sw t1, 0x08(t0)         # To enable GPIO_RED (1 << 22) we write a 32bit word with the 22bit
                            # set to offset 0x08 (output_en) of the GPIO control register

    sw t1, 0x40(t0)         # We make the GPIO "active high", by writing to offset 0x40 (out_xor)
                            # meaning writing a 1 will make the GPIO output high

    ret                     # Return to where ra register tells us

.global set_led             # Make the set_led symbol global, so other (object) files can find it
#
# Arguments:
#   - a0: 0 if led is to be off and !0 if led is to be on
#
set_led:
    addi sp, sp, -16        # We start by adding room on the stack (pointed to by reg sp).
    sw s0, 4(sp)            # Then we store the s0 and s1 registers on the stack so that we are
    sw s1, 0(sp)            # not writing over values used by the caller of the function.
                            # s0 - s11 are called "saved registers" and convention is that one is
                            # meant to trust that they are not overwritten by function calls.

    li s0, GPIO_BASE        # li: load immediate: load the constant GPIO_BASE into s0
    beqz a0, off            # If a0 (argument 0) is zero, then jump to the off label
    li s1, GPIO_RED         # Load the constant GPIO_RED into s1
    j set_and_ret           # Unconditonally jump to the set_and_ret label
off:
    li s1, 0                # Load 0 into s1 (w4 end up here when a0 is 0)
set_and_ret:
    sw s1, 0x0c(s0)         # Set output of GPIO_RED to the value stored in s1

    lw s0, 4(sp)            # Restore s0 and Ss from the stack ...
    lw s1, 0(sp)
    addi sp, sp, 16         # And unwind the stack we created
    ret                     # Return to where ra register tells us
