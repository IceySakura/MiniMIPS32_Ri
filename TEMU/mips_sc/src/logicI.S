#include "trap.h"
   .set noat
   .globl main
   .text
main:
   ori $1, $0, 0x1234
   ori $2, $0, 0x5678
   ori $3, $0, 0x9abc
   nop
   nop
   nop
   nop
   lui $1, 0x1234
   lui $2, 0x5678
   lui $3, 0x9abc
   nop
   nop
   nop
   nop
   addu $4, $1, $2
   andi $1, $1, 0x56f8
   andi $2, $2, 0xedbc
   nop
   nop
   nop
   nop
   nop
   or $5, $1, $2
   ori $3, $3, 0x56f8
   lui $4, 0x1234
   
   HIT_GOOD_TRAP		#stop temu
