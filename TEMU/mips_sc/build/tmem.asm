
build/tmem:     file format elf32-tradlittlemips
build/tmem


Disassembly of section .text:

80000000 <main>:
80000000:	80010000 	lb	at,0(zero)
80000004:	80020001 	lb	v0,1(zero)
	...
8000001c:	80030005 	lb	v1,5(zero)
80000020:	80240007 	lb	a0,7(at)
80000024:	80450008 	lb	a1,8(v0)
80000028:	8c060000 	lw	a2,0(zero)
8000002c:	8c070004 	lw	a3,4(zero)
80000030:	00000000 	nop
80000034:	4a000000 	c2	0x0

Disassembly of section .data:

80400000 <wdata>:
wdata():
80400000:	12345678 	beq	s1,s4,804159e4 <wdata+0x159e4>
80400004:	9abcdef0 	lwr	gp,-8464(s5)
80400008:	deadbeef 	0xdeadbeef
8040000c:	87654321 	lh	a1,17185(k1)

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	000000fe 	0xfe
	...
