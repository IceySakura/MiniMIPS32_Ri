#include "trap.h"
   .set noat
   .set noreorder
   .globl main
   .text
main:
   lui $7, 0x8040
   ori $3, $0, 0xdead
   sw $3, 0($7)
   lw $4, 0($7)
   ori $5, $4, 0xbeef
   
   HIT_GOOD_TRAP		#stop temu
