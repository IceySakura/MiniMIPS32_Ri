
build/btn:     file format elf32-tradlittlemips
build/btn


Disassembly of section .text:

80000000 <main>:
80000000:	3c02bfd0 	lui	v0,0xbfd0
80000004:	344203f0 	ori	v0,v0,0x3f0
80000008:	3c05bfd0 	lui	a1,0xbfd0
8000000c:	34a503f8 	ori	a1,a1,0x3f8
80000010:	3c0bbfd0 	lui	t3,0xbfd0
80000014:	356b0370 	ori	t3,t3,0x370
80000018:	3c090000 	lui	t1,0x0

8000001c <try_btn>:
try_btn():
8000001c:	80430004 	lb	v1,4(v0)
80000020:	30630001 	andi	v1,v1,0x1
80000024:	1060fffd 	beqz	v1,8000001c <try_btn>
80000028:	00000000 	nop
8000002c:	80440000 	lb	a0,0(v0)

80000030 <try_serial>:
try_serial():
80000030:	80a60004 	lb	a2,4(a1)
80000034:	30c60001 	andi	a2,a2,0x1
80000038:	10c0fffd 	beqz	a2,80000030 <try_serial>
8000003c:	00000000 	nop
80000040:	a0a40000 	sb	a0,0(a1)
80000044:	25290001 	addiu	t1,t1,1
80000048:	00045400 	sll	t2,a0,0x10
8000004c:	01495025 	or	t2,t2,t1
80000050:	ad6a0000 	sw	t2,0(t3)
80000054:	1000fff1 	b	8000001c <try_btn>
80000058:	00000000 	nop
8000005c:	4a000000 	c2	0x0

Disassembly of section .reginfo:

00000000 <.reginfo>:
   0:	00000e7c 	0xe7c
	...
