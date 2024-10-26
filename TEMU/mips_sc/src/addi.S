#include "trap.h"
   .set noat
   .globl main
   .text
main:
   li $at, 0x10101010           # $at = 0x10101010
   addi $v0, $at, 0xfffe    # $v0 = $at - 2
   
   HIT_GOOD_TRAP		#stop temu
