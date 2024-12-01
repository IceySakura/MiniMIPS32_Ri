#include "temu.h"

FILE *golden_fp = NULL;

void init_golden() {
    golden_fp = fopen("golden.txt", "w");
    Assert(golden_fp, "Can not open 'golden.txt'");
}

void golden_write(uint32_t pc, uint32_t reg, uint32_t value) {
    fprintf(golden_fp, "0x%08x   %u  0x%08x\n", pc, reg, value);

}