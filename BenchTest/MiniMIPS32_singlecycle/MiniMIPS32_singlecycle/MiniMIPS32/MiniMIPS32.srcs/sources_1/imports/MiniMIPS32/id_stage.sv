`include "defines.sv"

module id_stage(

    // 从取指阶段获得的PC+4值
    input  logic [`INST_ADDR_BUS]    PCPlus4,

    // 从指令存储器读出的指令字
    input  logic [`INST_BUS     ]    Instr_i,

    // 从通用寄存器文件读出的数据 
    input  logic [`REG_BUS      ]    RD1,
    input  logic [`REG_BUS      ]    RD2,

    // 输出的译码控制信号
    output logic                     MemtoReg,
    output logic                     MemWrite,
    output logic                     Branch,
    output logic [`ALUCTRL_BUS    ]  ALUControl,
    output logic                     ALUSrc,
    output logic                     RegDst,
    output logic                     RegWrite,
    output logic                     Jump,
    output logic [`REG_BUS      ]    WriteData,

    // 送至执行阶段的源操作数1、源操作数2
    output logic [`REG_BUS      ]    SrcA,
    output logic [`REG_BUS      ]    SrcB,
    
    // 所有转移指令的地址
    output logic [`REG_BUS      ]   PCBranch,
    output logic [`REG_BUS      ]   PCJump,
      
    // 送至通用寄存器堆读端口的地址
    output logic [`REG_ADDR_BUS ]    A1,
    output logic [`REG_ADDR_BUS ]    A2,
    
    // 送至通用寄存器堆写端口的地址
    output logic [`REG_ADDR_BUS ]    WriteReg
    );

    logic [`INST_BUS] Instr;
    assign Instr = {Instr_i[7:0], Instr_i[15:8], Instr_i[23:16], Instr_i[31:24]};  //小端格式处理

    // 提取指令字中各个字段的信息
    logic [5 :0] op;
    assign op   = Instr[31:26];
    logic [5 :0] func;
    assign func = Instr[5 : 0];
    logic [4 :0] rd;
    assign rd   = Instr[15:11];
    logic [4 :0] rs;
    assign rs   = Instr[25:21];
    logic [4 :0] rt;
    assign rt   = Instr[20:16];
    logic [4 :0] sa;
    assign sa   = Instr[10: 6];
    logic [15:0] imm;
    assign imm  = Instr[15: 0]; 
    logic [25:0] instr_index;
    assign instr_index  = Instr[25: 0]; 

    // 第一级译码逻辑
    logic                   inst_reg, inst_lw, inst_sw, inst_beq, inst_bne;
    logic                   inst_addiu, inst_lui, inst_ori, inst_j;
    logic [`ALUOP_BUS ]     ALUOP;
    assign inst_reg     = (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (~op[1]) & (~op[0]);
    assign inst_lw      = (op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (op[0]);
    assign inst_sw      = (op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (op[1]) & (op[0]);
    assign inst_beq     = (~op[5]) & (~op[4]) & (~op[3]) & (op[2]) & (~op[1]) & (~op[0]);
    assign inst_bne     = (~op[5]) & (~op[4]) & (~op[3]) & (op[2]) & (~op[1]) & (op[0]);
    assign inst_addiu   = (~op[5]) & (~op[4]) & (op[3]) & (~op[2]) & (~op[1]) & (op[0]);
    assign inst_lui     = (~op[5]) & (~op[4]) & (op[3]) & (op[2]) & (op[1]) & (op[0]);
    assign inst_ori     = (~op[5]) & (~op[4]) & (op[3]) & (op[2]) & (~op[1]) & (op[0]);
    assign inst_j       = (~op[5]) & (~op[4]) & (~op[3]) & (~op[2]) & (op[1]) & (~op[0]);
    assign RegWrite     = inst_reg | inst_lw | inst_addiu | inst_lui | inst_ori;
    assign RegDst       = inst_reg;
    assign ALUSrc       = inst_lw | inst_sw | inst_addiu | inst_lui | inst_ori;
    assign Branch       = inst_beq | inst_bne;
    assign MemWrite     = inst_sw;
    assign MemtoReg     = inst_lw;
    assign ALUOP[2]     = inst_bne | inst_ori;
    assign ALUOP[1]     = inst_reg | inst_lui;
    assign ALUOP[0]     = inst_beq | inst_bne | inst_lui;
    assign Jump         = inst_j;

    // 第二级译码逻辑产生ALUCTRL
    logic   inst_addu, inst_slt;
    assign ALUControl[2] = ((~ALUOP[2]) & (~ALUOP[1]) & (ALUOP[0])) | (inst_reg & (func==6'b101010)) | ((ALUOP[2]) & (~ALUOP[1]) & (ALUOP[0]));
    assign ALUControl[1] = ((~ALUOP[2]) & (~ALUOP[1]) & (~ALUOP[0])) | ((~ALUOP[2]) & (~ALUOP[1]) & (ALUOP[0])) | (inst_reg & (func==6'b101010)) | (inst_reg & (func==6'b100001));
    assign ALUControl[0] = (inst_reg & (func==6'b101010)) | ((ALUOP[2]) & (~ALUOP[1]) & (~ALUOP[0]));  

    // 符号扩展使能信号
    logic sext;
    assign sext    = inst_lw | inst_sw | inst_addiu | inst_beq | inst_bne;
    logic [31 : 0] extimm;
    assign extimm  = (sext  == `SIGNED_EXT  )? {{16{imm[15]}}, imm} : {{16{1'b0}}, imm};

    // 读通用寄存器堆端口1的地址为rs字段，读端口2的地址为rt字段
    assign A1   = rs;
    assign A2   = rt;
    
    // 获得指令操作所需的立即数 
    logic [31:0] SrcB_tmp;
    assign SrcB_tmp   = (inst_lui) ? {imm, {16{1'b0}}} : extimm;

    // 目的寄存器的地址
    assign WriteReg  = (RegDst == `RT_ENABLE     ) ? rt : rd;

    // 获得访存阶段要存入数据存储器的数据（来自通用寄存器堆的读端口2）
    assign WriteData  = RD2;

    // 获得源操作数1。源操作数1可能是移位位数、也可能来自通用寄存器堆的读端口1
    assign SrcA     = RD1;

    // 获得源操作数2。源操作数1可能是立即数扩展、也可能来自通用寄存器堆的读端口2
    assign SrcB     =  (ALUSrc) ? SrcB_tmp : RD2;

/*********************** 转移指令添加 begin*******************************/
    // 生成计算转移地址所需信号
    logic [17 : 0] imm2; 
    assign imm2 = {imm, 2'b00};
    logic [31 : 0] imm3;
    assign imm3 = {{14{imm2[17]}}, imm2};
    assign PCBranch = imm3 + PCPlus4;
    assign PCJump   = {PCPlus4[31 : 28], {instr_index, 2'b00}};
/*********************** 转移指令添加 end*********************************/

endmodule
