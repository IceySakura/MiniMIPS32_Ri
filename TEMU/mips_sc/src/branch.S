#include "trap.h"
   .set noat
   .set noreorder
   .globl main
   .text
main:
   ori $3, $0, 0x0004
   lui $4, 0
   lui $5, 0
L1:
   addiu $3, $3, -1
   addiu $4, $4, 1
   addu $5, $5, $4
   beq $3, $0, END
   nop
   ori $6, $0, L1
   jalr $6
   nop
END:
   
   HIT_GOOD_TRAP		#stop temu
