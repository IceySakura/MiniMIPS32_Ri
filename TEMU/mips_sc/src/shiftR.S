#include "trap.h"
   .set noat
   .globl main
   .text
main:
   sll $4, $2, 2
   
   HIT_GOOD_TRAP		#stop temu
