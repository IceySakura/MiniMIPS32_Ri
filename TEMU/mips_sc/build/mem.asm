
build/mem:     file format elf32-tradlittlemips
build/mem


Disassembly of section .text:

80000000 <main>:
80000000:	3c108040 	lui	s0,0x8040
80000004:	340100ff 	li	at,0xff
80000008:	a2010003 	sb	at,3(s0)
8000000c:	340100ee 	li	at,0xee
80000010:	a2010002 	sb	at,2(s0)
80000014:	340100dd 	li	at,0xdd
80000018:	a2010001 	sb	at,1(s0)
8000001c:	340100cc 	li	at,0xcc
80000020:	a2010000 	sb	at,0(s0)
80000024:	82020003 	lb	v0,3(s0)
80000028:	3c014455 	lui	at,0x4455
8000002c:	34216677 	ori	at,at,0x6677
80000030:	ae010008 	sw	at,8(s0)
80000034:	8e020008 	lw	v0,8(s0)
80000038:	00000000 	nop
8000003c:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	00010006 	srlv	zero,at,zero
	...
