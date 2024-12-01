#include "trap.h"
   .set noat
   .globl main

   .data
wdata: .word 0x12345678, 0x9abcdef0, 0xdeadbeef, 0x87654321

   .text
main:
   lb $1, 0x0($0)
   lb $2, 0x1($0)
   nop
   nop
   nop
   nop
   nop
   lb $3, 0x5($0)
   lb $4, 0x7($1)
   lb $5, 0x8($2)
   lw $6, 0x0($0)
   lw $7, 0x4($0)
   
   HIT_GOOD_TRAP        # stop temu
