
build/logic:     file format elf32-tradlittlemips
build/logic


Disassembly of section .text:

80000000 <main>:
80000000:	3c011010 	lui	at,0x1010
80000004:	34211010 	ori	at,at,0x1010
80000008:	3c020101 	lui	v0,0x101
8000000c:	34421111 	ori	v0,v0,0x1111
80000010:	00224024 	and	t0,at,v0
80000014:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	00000106 	0x106
	...
