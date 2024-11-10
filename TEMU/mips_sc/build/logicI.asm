
build/logicI:     file format elf32-tradlittlemips
build/logicI


Disassembly of section .text:

80000000 <main>:
80000000:	34011234 	li	at,0x1234
80000004:	34025678 	li	v0,0x5678
80000008:	34039abc 	li	v1,0x9abc
	...
8000001c:	3c011234 	lui	at,0x1234
80000020:	3c025678 	lui	v0,0x5678
80000024:	3c039abc 	lui	v1,0x9abc
	...
80000038:	00222021 	addu	a0,at,v0
8000003c:	302156f8 	andi	at,at,0x56f8
80000040:	3042edbc 	andi	v0,v0,0xedbc
	...
80000058:	00222825 	or	a1,at,v0
8000005c:	346356f8 	ori	v1,v1,0x56f8
80000060:	3c041234 	lui	a0,0x1234
80000064:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	0000003e 	0x3e
	...
