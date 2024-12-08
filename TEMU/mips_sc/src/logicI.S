#include "trap.h"
   .set noat
   .globl main
   .text
main:
   ori $1, $0, 0x1234
   ori $2, $0, 0x5678
   xor $4, $1, $2
   ori $3, $1, 0x9abc
   lui $1, 0x1234
   lui $2, 0x5678
   xor $3, $1, $2
   lui $3, 0x9abc
   addu $4, $1, $2
   addiu $5, $1, 0x5678
   ori $1, $0, 0x1234
   lui $2, 0x5678
   andi $1, $1, 0x56f8
   ori $2, $2, 0xedbc
   and $3, $1, $2
   addu $4, $1, $2
   or $5, $1, $2
   ori $3, $3, 0x56f8
   lui $4, 0x1234
   ori $5, $4, 0x5678
   
   HIT_GOOD_TRAP		#stop temu
