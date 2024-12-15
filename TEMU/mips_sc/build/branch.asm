
build/branch:     file format elf32-tradlittlemips
build/branch


Disassembly of section .text:

80000000 <main>:
80000000:	34030004 	li	v1,0x4
80000004:	3c040000 	lui	a0,0x0
80000008:	3c050000 	lui	a1,0x0

8000000c <L1>:
L1():
8000000c:	2463ffff 	addiu	v1,v1,-1
80000010:	24840001 	addiu	a0,a0,1
80000014:	00a42821 	addu	a1,a1,a0
80000018:	10600004 	beqz	v1,8000002c <END>
8000001c:	00000000 	nop
80000020:	3406000c 	li	a2,0xc
80000024:	00c0f809 	jalr	a2
80000028:	00000000 	nop

8000002c <END>:
END():
8000002c:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	80000078 	lb	zero,120(zero)
	...
