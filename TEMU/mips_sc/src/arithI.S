#include "trap.h"
   .set noat
   .globl main
   .text
main:
   ori $5, $0, 0x037f
   ori $4, $0, 0x123f
   ori $3, $0, 0x070f
   ori $2, $0, 0x3f1f
   nop
   nop
   nop
   addiu $1, $0, 0x1234
   addu $4, $3, $5
   nop
   addu $5, $2, $2
   ori $5, $0, 0x3f23
   nop
   nop
   nop
   addu $6, $1, $2
   nop
   nop
   addi $7, $5, 0x1234
   addi $8, $4, 0x1d44
   nop
   addi $9, $3, 0x9de4
   lui $9, 0x1234
   
   HIT_GOOD_TRAP		#stop temu
