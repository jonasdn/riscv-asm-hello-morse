#
# This Makefile will assemble code for the FE310-G002, which uses a E31
# RISC-V core.
#
# The E31 core supports Machine and User privilege modes as well as standard
# Multiply, Atomic, and Compressed RISC‑V extensions (RV32IMAC).
#
ARCH=rv32imac
ABI=ilp32
EMU=elf32lriscv

ARCHFLAGS=-march=rv32imac -mabi=ilp32
CFLAGS=$(ARCHFLAGS) -g -o0
LDFLAGS=-m $(EMU) -nostartfiles -nostdlib -Thello-morse.lds
AS=riscv64-unknown-elf-as
LD=riscv64-unknown-elf-ld
OBJCOPY=riscv64-unknown-elf-objcopy

name=hello-morse
hex=$(name).hex
elf=$(name).elf
map=$(name).map
lds=$(name).lds

objs=hello-morse.o wait.o led.o morse.o

#
# The final product of this Makefile is a hex file with the binary code
#
all: $(hex)

#
# This is the rule to turn assembly files to object files
#
%.o: %.S
	$(AS) $(CFLAGS)  -c -o $@ $<
#
# We will use  ur object code to create an ELF executable
#
$(elf): $(objs) $(lds)
	$(LD) --verbose $(objs) $(LDFLAGS) -o $@

#
# And we use objcopy to slice out the binary code from the ELF executable and
# turn it into an hex file.
#
$(hex): $(elf)
	$(OBJCOPY) -O ihex $< $@

#
# Clean up, remove elf and hex files
#
.PHONY: clean
clean:
	rm -f $(hex) $(elf) *.o

#
# The HiFive1 Rev B is populated with a Segger J-Link OB module which bridges
# USB to JTAG, we can use the J-Link software from Segger to upload our hex.
#
.PHONY: upload
upload: $(hex)
	echo "loadfile $(hex)\nrnh\nexit" | JLinkExe -device FE310 -if JTAG -speed 4000 -jtagconf -1,-1 -autoconnect 1
