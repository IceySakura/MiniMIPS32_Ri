`include "defines.v"

module id_stage(
    
    // 从取指阶段获得的PC值
    input  wire [`INST_ADDR_BUS]    id_pc_i,
    input  wire [`INST_ADDR_BUS]    id_debug_wb_pc,  // 供调试使用的PC值，上板测试时务必删除该信号

    // 从指令存储器读出的指令字
    input  wire [`INST_BUS     ]    id_inst_i,

    // 从通用寄存器堆读出的数据 
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
      
    // 送至执行阶段的译码信息
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,

    // 送至执行阶段的源操作数1、源操作数2
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // 送至读通用寄存器堆端口的使能和地址
    output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2,
    
    output       [`INST_ADDR_BUS] 	debug_wb_pc  // 供调试使用的PC值，上板测试时务必删除该信号
    );
    
    // 根据小端模式组织指令字
    wire [`INST_BUS] id_inst = {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

    // 提取指令字中各个字段的信息
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    /*-------------------- 第一级译码逻辑：确定当前需要译码的指令 --------------------*/
	// R type
    wire inst_reg  = ~|op;
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
	wire inst_or   = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]& func[0];
	wire inst_xor  = inst_reg& func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0];
	wire inst_addu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]& func[0];
	wire inst_sll  = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0]&(|id_inst); // 非全零，区分 nop
	wire inst_sra  = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
	// I type
	wire inst_ori  = ~op[5]&~op[4]& op[3]& op[2]&~op[1]& op[0];
	wire inst_andi = ~op[5]&~op[4]& op[3]& op[2]&~op[1]&~op[0];
	wire inst_lui  = ~op[5]&~op[4]& op[3]& op[2]& op[1]& op[0];
	wire inst_addiu= ~op[5]&~op[4]& op[3]&~op[2]&~op[1]& op[0];
	wire inst_addi = ~op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0]; 
    /*------------------------------------------------------------------------------*/

    /*-------------------- 第二级译码逻辑：生成具体控制信号 --------------------*/
    // 操作类型alutype
    assign id_alutype_o[2] = inst_sll | inst_sra;
    assign id_alutype_o[1] = inst_and | inst_or | inst_xor | inst_ori | inst_andi | inst_lui;
    assign id_alutype_o[0] = inst_addu| inst_addiu| inst_addi;

	// 内部操作码aluop
	assign id_aluop_o[7]   = 1'b0;
	assign id_aluop_o[6]   = 1'b0;
	assign id_aluop_o[5]   = 1'b0;
	assign id_aluop_o[4]   = inst_and | inst_or | inst_xor | inst_addu | inst_sll | inst_sra | inst_ori  | inst_andi | inst_addiu | inst_addi;
	assign id_aluop_o[3]   = inst_and | inst_or | inst_xor | inst_addu | inst_ori | inst_andi| inst_addiu| inst_addi;
	assign id_aluop_o[2]   = inst_and | inst_or | inst_xor | inst_ori  | inst_andi| inst_lui;
	assign id_aluop_o[1]   = inst_xor | inst_sra;
	assign id_aluop_o[0]   = inst_or  | inst_sll| inst_ori | inst_lui;

    // 写通用寄存器使能信号
    assign id_wreg_o       = inst_and | inst_or  | inst_xor | inst_addu | inst_sll | inst_sra 
						   | inst_ori | inst_andi| inst_lui | inst_addiu| inst_addi;
    // 读通用寄存器堆端口1使能信号
    assign rreg1 = 1'b1;
    // 读通用寄存器堆读端口2使能信号
    assign rreg2 = 1'b1;

	/*-------------------- 定义一些只在 ID 阶段使用的控制信号 --------------------*/
	wire shift;
	wire rt_sel;
	wire sext;
	wire upper;
	wire immsel;
	assign shift = inst_sll | inst_sra; 												// shift信号有效时，源操作数1为移位位数
	assign rt_sel = inst_ori | inst_andi | inst_lui | inst_addiu| inst_addi;			// rt_sel信号有效时，目的寄存器为rt字段
	assign sext = inst_addiu | inst_addi;												// sext信号有效时，立即数为符号扩展
	assign upper = inst_lui;															// upper信号有效时，立即数为高16位
	assign immsel = inst_ori | inst_andi | inst_lui | inst_addiu| inst_addi;			// immsel信号有效时，源操作数2为立即数
    /*------------------------------------------------------------------------------*/

    // 读通用寄存器堆端口1的地址为rs字段，读端口2的地址为rt字段
    assign ra1   = rs;
    assign ra2   = rt;
                                            
    // 获得待写入目的寄存器的地址（rt或rd）
    assign id_wa_o  = rt_sel ? rt : rd;

    // 获得源操作数1。如果shift信号有效，则源操作数1为移位位数；否则为从读通用寄存器堆端口1获得的数据
	assign id_src1_o = shift ? {27'b0, sa} : rd1;

	// 处理立即数
	wire [`REG_BUS] extimm;
	wire [`REG_BUS] uppimm;
	wire [`REG_BUS] finimm;
	assign extimm = sext ? {imm[15], imm} : {16'b0, imm};
	assign uppimm = {imm, 16'b0};
	assign finimm = upper ? uppimm : extimm;
    // 获得源操作数2。如果immsel信号有效，则源操作数1为立即数；否则为从读通用寄存器堆端口2获得的数据
	assign id_src2_o = immsel ? finimm : rd2;           
    
    assign debug_wb_pc = id_debug_wb_pc;    // 上板测试时务必删除该语句      

endmodule
