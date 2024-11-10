#include "trap.h"
   .set noat
   .globl main
   .text
main:
   and $v1, $v0, $at	# $v1 = $v0 & $at
   
   HIT_GOOD_TRAP		#stop temu
