#include "include/inst_test.h"
#include "include/regdef.h" 

    .org 0x0
    .set noreorder
    .set noat
    .text

    .global main
main:
    lui   s1, 0xBFD0
    lb    t0, 0x03FC(s1)
    andi  t0, t0, 0x0001
    ori   t1, 0xdeed
    sb    t1, 0x03F8(s1)