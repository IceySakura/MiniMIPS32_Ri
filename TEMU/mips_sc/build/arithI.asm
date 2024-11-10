
build/arithI:     file format elf32-tradlittlemips
build/arithI


Disassembly of section .text:

80000000 <main>:
80000000:	3405037f 	li	a1,0x37f
80000004:	3404123f 	li	a0,0x123f
80000008:	3403070f 	li	v1,0x70f
8000000c:	34023f1f 	li	v0,0x3f1f
	...
8000001c:	24011234 	li	at,4660
80000020:	00652021 	addu	a0,v1,a1
80000024:	00000000 	nop
80000028:	00422821 	addu	a1,v0,v0
8000002c:	34053f23 	li	a1,0x3f23
	...
8000003c:	00223021 	addu	a2,at,v0
	...
80000048:	20a71234 	addi	a3,a1,4660
8000004c:	20881d44 	addi	t0,a0,7492
80000050:	00000000 	nop
80000054:	20699de4 	addi	t1,v1,-25116
80000058:	3c091234 	lui	t1,0x1234
8000005c:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	000003fe 	0x3fe
	...
