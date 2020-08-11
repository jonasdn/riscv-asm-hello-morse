MEMORY
{
  flash	(rx)	: ORIGIN = 0x20010000, LENGTH = 512M
}

SECTIONS
{
  .text :
  {
    *(.text)
  } > flash

  .rodata :
  {
    *(.rodata)
  } > flash
}
