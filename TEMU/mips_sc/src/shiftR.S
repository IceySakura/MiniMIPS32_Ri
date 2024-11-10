#include "trap.h"
   .set noat
   .globl main
   .text
main:
   sra $5, $1, 3
   sll $4, $2, 2
   
   HIT_GOOD_TRAP		#stop temu
