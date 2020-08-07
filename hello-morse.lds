MEMORY
{
  ram 	(rwx)	: ORIGIN = 0x80000000, LENGTH = 16k
  flash	(rx)	: ORIGIN = 0x20010000, LENGTH = 512M
}

SECTIONS
{
  .text :
  {
    *(.text)
    *(.rodata)
  } > flash
}
