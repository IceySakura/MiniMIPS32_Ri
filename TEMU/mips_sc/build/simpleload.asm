
build/simpleload:     file format elf32-tradlittlemips
build/simpleload


Disassembly of section .text:

80000000 <main>:
80000000:	3c078040 	lui	a3,0x8040
80000004:	3403dead 	li	v1,0xdead
80000008:	ace30000 	sw	v1,0(a3)
8000000c:	8ce40000 	lw	a0,0(a3)
80000010:	3485beef 	ori	a1,a0,0xbeef
80000014:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	000000b8 	0xb8
	...
