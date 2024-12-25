#include "trap.h"
    .org 0x0
    .set noreorder
    .set noat
    .text
    .globl main
main:
    # $2 = 0xbfd003f0 是矩阵键盘的地址， +4 检查是否可用
    lui $2, 0xbfd0                                          # 0x80000000         
    ori $2, $2, 0x03f0                                      # 0x80000004
    # $5 = 0xbfd003f8 是串口的地址， +4 检查是否可用
    lui $5, 0xbfd0                                          # 0x80000008
    ori $5, $5, 0x03f8                                      # 0x8000000c      
    # $11 = 0xbfd00370 是数码管的地址
    lui $11, 0xbfd0                                         # 0x80000010
    ori $11, $11, 0x0370                                    # 0x80000014
    # $9 记录写过了多少次
    lui $9, 0x0                                             # 0x80000018
try_btn:
    # $3 检查 btn 是否可用
    lb $3, 4($2)                                            # 0x8000001c
    andi $3, $3, 0x1                                        # 0x80000020
    beqz $3, try_btn                                        # 0x80000024
    nop                                                     # 0x80000028   
    # $4 读取按键值
    lb $4, 0($2)                                            # 0x8000002c
try_serial:
    # $6 检查 serial 是否可用
    lb $6, 4($5)                                            # 0x80000030
    andi $6, $6, 0x1                                        # 0x80000034
    beqz $6, try_serial                                     # 0x80000038
    nop                                                     # 0x8000003c
    # 写入按键值
    sb $4, 0($5)                                            # 0x80000040
    addiu $9, $9, 1                                         # 0x80000044
    # 写入数码管
    sll $10, $4, 16                                         # 0x80000048
    or $10, $10, $9                                         # 0x8000004c                 
    sw $10, 0($11)                                          # 0x80000050

    beqz $0, try_btn                                        # 0x80000054
    nop                                                     # 0x80000058     
   
    HIT_GOOD_TRAP		#stop temu
