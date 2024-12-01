#include "helper.h"

#include "monitor.h"
#include "golden.h"

#include "reg.h"
#include "memory/memory.h"

// sign extent 16 bits to 32 bits
int32_t sext16(int16_t x) {
	return (int32_t)x;
}

// sign extent 8 bits to 32 bits
int32_t sext8(int8_t x) {
    return (int32_t)x;
}

extern uint32_t instr;
extern char assembly[80];

/* decode I-type instrucion with unsigned immediate */
static void decode_imm_type(uint32_t instr) {

	op_src1->type = OP_TYPE_REG;
	op_src1->reg = (instr & RS_MASK) >> (RT_SIZE + IMM_SIZE);
	op_src1->val = reg_w(op_src1->reg);
	
	op_src2->type = OP_TYPE_IMM;
	op_src2->imm = instr & IMM_MASK;
	op_src2->val = op_src2->imm;

	op_dest->type = OP_TYPE_REG;
	op_dest->reg = (instr & RT_MASK) >> (IMM_SIZE);
}

make_helper(lui) {

	decode_imm_type(instr);
	reg_w(op_dest->reg) = (op_src2->val << 16);
	sprintf(assembly, "lui   %s,   0x%04x", REG_NAME(op_dest->reg), op_src2->imm);
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(ori) {

	decode_imm_type(instr);
	reg_w(op_dest->reg) = op_src1->val | op_src2->val;
	sprintf(assembly, "ori   %s,   %s,   0x%04x", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), op_src2->imm);
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(andi) {

	decode_imm_type(instr);
	reg_w(op_dest->reg) = op_src1->val & op_src2->val;
	sprintf(assembly, "andi   %s,   %s,   0x%04x", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), op_src2->imm);
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(addiu) {
	
	decode_imm_type(instr);
	reg_w(op_dest->reg) = op_src1->val + op_src2->imm;
	sprintf(assembly, "addiu   %s,   %s,   0x%04x(%u)", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), op_src2->imm, op_src2->imm);
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(addi) {

	decode_imm_type(instr);
	reg_w(op_dest->reg) = op_src1->val + sext16(op_src2->simm);
	sprintf(assembly, "addi   %s,   %s,   0x%04x(%d)", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), sext16(op_src2->simm), sext16(op_src2->simm));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(bne) {

	decode_imm_type(instr);
	if (op_src1->val != op_dest->val) {
		cpu.pc += sext16(op_src2->simm) - 4;
	}
	sprintf(assembly, "bne   %s,   %s,   0x%08x", REG_NAME(op_src1->reg), REG_NAME(op_src2->reg), cpu.pc + 4);
}

make_helper(beq) {
	
	decode_imm_type(instr);
	if (op_src1->val == op_dest->val) {
		cpu.pc += sext16(op_src2->simm) - 4;
	}
	sprintf(assembly, "beq   %s,   %s,   0x%08x", REG_NAME(op_src1->reg), REG_NAME(op_src2->reg), cpu.pc + 4); 	
}

make_helper(lw) {

	decode_imm_type(instr);
	reg_w(op_dest->reg) = mem_read(op_src1->val + sext16(op_src2->simm), 4);
	sprintf(assembly, "lw   %s,   0x%04x(%s)", REG_NAME(op_dest->reg), sext16(op_src2->simm), REG_NAME(op_src1->reg));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(sw) {
	
	decode_imm_type(instr);
	mem_write(op_src1->val + sext16(op_src2->simm), 4, reg_w(op_dest->reg));
	sprintf(assembly, "sw   %s,   0x%04x(%s)", REG_NAME(op_dest->reg), sext16(op_src2->simm), REG_NAME(op_src1->reg));
}

make_helper(lb) {

	decode_imm_type(instr);
	reg_w(op_dest->reg) = sext8(mem_read(op_src1->val + sext16(op_src2->simm), 1));
	sprintf(assembly, "lb   %s,   0x%04x(%s)", REG_NAME(op_dest->reg), sext16(op_src2->simm), REG_NAME(op_src1->reg));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(sb) {
	
	decode_imm_type(instr);
	mem_write(op_src1->val + sext16(op_src2->simm), 1, reg_w(op_dest->reg));
	sprintf(assembly, "sb   %s,   0x%04x(%s)", REG_NAME(op_dest->reg), sext16(op_src2->simm), REG_NAME(op_src1->reg));
}