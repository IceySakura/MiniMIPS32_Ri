
build/tmem:     file format elf32-tradlittlemips
build/tmem


Disassembly of section .text:

80000000 <main>:
80000000:	80010003 	lb	at,3(zero)
80000004:	8c030008 	lw	v1,8(zero)
80000008:	8c020000 	lw	v0,0(zero)
	...
8000001c:	a0010007 	sb	at,7(zero)
80000020:	ac030004 	sw	v1,4(zero)
80000024:	a0030002 	sb	v1,2(zero)
80000028:	4a000000 	c2	0x0

Disassembly of section .data:

80400000 <wdata>:
wdata():
80400000:	12345678 	beq	s1,s4,804159e4 <wdata+0x159e4>
80400004:	9abcdef0 	lwr	gp,-8464(s5)
80400008:	deadbeef 	0xdeadbeef
8040000c:	87654321 	lh	a1,17185(k1)

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	0000000e 	0xe
	...
