#include "helper.h"

#include "monitor.h"
#include "golden.h"

#include "reg.h"

extern uint32_t instr;
extern char assembly[80];

/* decode R-type instrucion */
static void decode_r_type(uint32_t instr) {

	op_src1->type = OP_TYPE_REG;
	op_src1->reg = (instr & RS_MASK) >> (RT_SIZE + IMM_SIZE);
	op_src1->val = reg_w(op_src1->reg);
	
	op_src2->type = OP_TYPE_REG;
	op_src2->reg = (instr & RT_MASK) >> (IMM_SIZE);
	op_src2->val = reg_w(op_src2->reg);

	op_dest->type = OP_TYPE_REG;
	op_dest->reg = (instr & RD_MASK) >> (SHAMT_SIZE + FUNC_SIZE);
}

make_helper(and) {

	decode_r_type(instr);
	reg_w(op_dest->reg) = (op_src1->val & op_src2->val);
	sprintf(assembly, "and   %s,   %s,   %s", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), REG_NAME(op_src2->reg));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(addu) {

	decode_r_type(instr);
	reg_w(op_dest->reg) = op_src1->val + op_src2->val;
	sprintf(assembly, "addu   %s,   %s,   %s", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), REG_NAME(op_src2->reg));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(or) {
	
	decode_r_type(instr);
	reg_w(op_dest->reg) = (op_src1->val | op_src2->val);
	sprintf(assembly, "or   %s,   %s,   %s", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), REG_NAME(op_src2->reg));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(xor) {

	decode_r_type(instr);
	reg_w(op_dest->reg) = (op_src1->val ^ op_src2->val);
	sprintf(assembly, "xor   %s,   %s,   %s", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg), REG_NAME(op_src2->reg));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(sll) {

	if(instr == 0)
	{
		// nop
		sprintf(assembly, "nop");
	}
	else
	{
		decode_r_type(instr);
		reg_w(op_dest->reg) = (op_src2->val << ((instr & SHAMT_MASK) >> (FUNC_SIZE)));
		sprintf(assembly, "sll   %s,   %s,   0x%02x", REG_NAME(op_dest->reg), REG_NAME(op_src2->reg), ((instr & SHAMT_MASK) >> (FUNC_SIZE)));
		golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
	}
}

make_helper(sra) {
	
	decode_r_type(instr);
	reg_w(op_dest->reg) = ((int32_t)op_src2->val >> ((instr & SHAMT_MASK) >> (FUNC_SIZE)));
	sprintf(assembly, "sra   %s,   %s,   0x%02x", REG_NAME(op_dest->reg), REG_NAME(op_src2->reg), ((instr & SHAMT_MASK) >> (FUNC_SIZE)));
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));
}

make_helper(jalr) {

	decode_r_type(instr);
	reg_w(op_dest->reg) = cpu.pc + 4;
	golden_write(cpu.pc, op_dest->reg, reg_w(op_dest->reg));

	cpu.pc = op_src1->val - 4;
	sprintf(assembly, "jalr   %s   %s", REG_NAME(op_dest->reg), REG_NAME(op_src1->reg));
}