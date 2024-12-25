
build/serial:     file format elf32-tradlittlemips
build/serial


Disassembly of section .text:

80000000 <main>:
80000000:	3c11bfd0 	lui	s1,0xbfd0
80000004:	822803fc 	lb	t0,1020(s1)
80000008:	31080001 	andi	t0,t0,0x1
8000000c:	3529deed 	ori	t1,t1,0xdeed
80000010:	a22903f8 	sb	t1,1016(s1)

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	00020300 	sll	zero,v0,0xc
	...
