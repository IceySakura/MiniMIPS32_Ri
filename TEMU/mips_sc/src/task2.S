#include "trap.h"
   .set noat
   .globl main

   .data
wdata: .word 0x12369678, 0x9abc2ef0, 0xdeadbeef, 0x87652121

   .text
main:
    lb $1, 3($0)
    lw $3, 8($0)
    lw $7, 8($0)
    nop
    nop
    nop
    nop
    sb $1, 7($0)
    sw $3, 4($0)
    sb $4, 2($0)
    nop
    nop
    nop
    ori $2, $0, 0x1234
    addiu $3, $0, 0x5678
    nop
    nop
    nop
    sw $3, 0($0)
    sll $2, $2, 2
    nop
    nop
    nop
    sw $2, 4($0)
    lb $1, 5($0)
   
   HIT_GOOD_TRAP        # stop temu
