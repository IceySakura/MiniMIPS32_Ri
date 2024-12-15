
build/branch:     file format elf32-tradlittlemips
build/branch


Disassembly of section .text:

80000000 <main>:
80000000:	34030004 	li	v1,0x4
80000004:	3c040000 	lui	a0,0x0
80000008:	3c050000 	lui	a1,0x0
8000000c:	3c098040 	lui	t1,0x8040

80000010 <L1>:
L1():
80000010:	2463ffff 	addiu	v1,v1,-1
80000014:	24840001 	addiu	a0,a0,1
80000018:	8d250000 	lw	a1,0(t1)
8000001c:	00a42821 	addu	a1,a1,a0
80000020:	ad250000 	sw	a1,0(t1)
80000024:	10600004 	beqz	v1,80000038 <END>
80000028:	00000000 	nop
8000002c:	34060010 	li	a2,0x10
80000030:	00c0f809 	jalr	a2
80000034:	00000000 	nop

80000038 <END>:
END():
80000038:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	80000278 	lb	zero,632(zero)
	...
