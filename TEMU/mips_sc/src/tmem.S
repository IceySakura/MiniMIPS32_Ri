#include "trap.h"
   .set noat
   .globl main

   .data
wdata: .word 0x12345678, 0x9abcdef0, 0xdeadbeef, 0x87654321

   .text
main:
    lb $1, 3($0)
    lw $3, 8($0)
    lw $2, 0($0)
    nop
    nop
    nop
    nop
    sb $1, 7($0)
    sw $3, 4($0)
    sb $3, 2($0)
    nop
    nop
    nop
    ori $2, $0, 0x1234
    addiu $3, $0, 0x5678
    nop
    nop
    nop
    sw $2, 0($0)
    sll $2, $2, 7
    nop
    nop
    nop
    sw $2, 8($0)
    lb $1, 7($0)
   
   HIT_GOOD_TRAP        # stop temu
