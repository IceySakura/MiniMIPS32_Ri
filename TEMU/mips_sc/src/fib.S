#include "trap.h"
#include "include/inst_test.h"
#include "include/regdef.h"    
   .set noat
   .globl main
   .text

main:
    ori   t0, zero, 0x1     # t0 = 1
    ori   t1, zero, 0x1     # t1 = 1
    lui   a0, 0x8040        # a0 = 0x80400000
    addiu t4, a0, 0x100     # t4 = 0x80400100
loop0:
    addu  t2, t0, t1        # t2 = t0+t1
    ori   t0, t1, 0x0       # t0 = t1
    ori   t1, t2, 0x0       # t1 = t2
    sw    t1, 0(a0)
    lw    t3, 0(a0)
    nop
    addiu a0, a0, 0x4       # a0 += 4

    bne   a0, t4, loop0
    nop
    
    HIT_GOOD_TRAP		# stop temu
