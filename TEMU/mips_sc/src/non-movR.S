#include "trap.h"
   .set noat
   .globl main
   .text
main:
   and $a0, $v0, $at		# $a0 = $v0 & $at
   or $a1, $v0, $at	    	# $a1 = $v0 | $at
   addu $a2, $v0, $at		# $a2 = $v0 + $at
   
   HIT_GOOD_TRAP		#stop temu
