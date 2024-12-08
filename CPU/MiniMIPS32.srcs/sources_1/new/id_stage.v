`include "defines.v"

module id_stage(
    
    // 从取指阶段获得的PC值
    input  wire [`INST_ADDR_BUS]    id_pc_i,
    input  wire [`INST_ADDR_BUS]    id_debug_wb_pc,  // 供调试使用的PC值，上板测试时务必删除该信号

    input  wire [`INST_BUS     ]    id_inst_i,

    // to EXE
    output wire                     id_mreg_o,
    output wire                     id_wreg_o,
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
    output reg [`WORD_BUS     ]    id_din_o,
    
    // REG_FILE
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
    output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2,

    // forword
    input  wire                     exe2id_wreg,
    input  wire [`REG_ADDR_BUS ]    exe2id_wa,
    input  wire [`WORD_BUS     ]    exe2id_wd,
    input  wire                     mem2id_wreg,
    input  wire [`REG_ADDR_BUS ]    mem2id_wa,
    input  wire [`WORD_BUS     ]    mem2id_wd,
    
    output       [`INST_ADDR_BUS] 	debug_wb_pc  // 供调试使用的PC值，上板测试时务必删除该信号
    );
    
    // INST_ROM 读出的指令是大端序的
    // 需要根据小端模式组织指令字
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
    wire inst_lb   =  op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];
    wire inst_lw   =  op[5]&~op[4]&~op[3]&~op[2]& op[1]& op[0];
    wire inst_sb   =  op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sw   =  op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];
    /*------------------------------------------------------------------------------*/

    /*-------------------- 第二级译码逻辑：生成具体控制信号 --------------------*/
    // 写多路选择器使能信号
    assign id_mreg_o       = inst_lb  | inst_lw;
    // 写通用寄存器使能信号
    assign id_wreg_o       = inst_and | inst_or  | inst_xor | inst_addu | inst_sll | inst_sra 
						   | inst_ori | inst_andi| inst_lui | inst_addiu| inst_addi
                           | inst_lb  | inst_lw;

    // 操作类型alutype
    assign id_alutype_o[2] = inst_sll | inst_sra;
    assign id_alutype_o[1] = inst_and | inst_or | inst_xor | inst_ori | inst_andi | inst_lui;
    assign id_alutype_o[0] = inst_addu| inst_addiu| inst_addi | inst_lb | inst_lw | inst_sb | inst_sw;

	// 内部操作码aluop
	assign id_aluop_o[7]   = inst_lb  | inst_lw | inst_sb | inst_sw;
	assign id_aluop_o[6]   = 1'b0;
	assign id_aluop_o[5]   = 1'b0;
	assign id_aluop_o[4]   = inst_and | inst_or | inst_xor | inst_addu | inst_sll | inst_sra | inst_ori  | inst_andi | inst_addiu | inst_addi | inst_lb | inst_lw | inst_sb | inst_sw;
	assign id_aluop_o[3]   = inst_and | inst_or | inst_xor | inst_addu | inst_ori | inst_andi| inst_addiu| inst_addi | inst_sb    | inst_sw;
	assign id_aluop_o[2]   = inst_and | inst_or | inst_xor | inst_ori  | inst_andi| inst_lui;
	assign id_aluop_o[1]   = inst_xor | inst_sra| inst_lw  | inst_sw;
	assign id_aluop_o[0]   = inst_or  | inst_sll| inst_ori | inst_lui;

    // 读通用寄存器堆的读信号总是1，因为是在后续判断是否要使用读出的数据
    assign rreg1 = 1'b1;
    assign rreg2 = 1'b1;

	/*-------------------- 定义一些只在 ID 阶段使用的控制信号 --------------------*/
	wire shift;
	wire rt_sel;
	wire sext;
	wire upper;
	wire immsel;
    reg [1:0] fwrd1, fwrd2;
	assign shift = inst_sll | inst_sra; 												                             
	assign rt_sel = inst_ori | inst_andi | inst_lui | inst_addiu| inst_addi | inst_lb | inst_lw;	                 
	assign sext = inst_addiu | inst_addi | inst_lb  | inst_lw   | inst_sb   | inst_sw;				                 
	assign upper = inst_lui;															                             
	assign immsel = inst_ori | inst_andi | inst_lui | inst_addiu| inst_addi | inst_lb | inst_lw | inst_sb | inst_sw;
    always @(*) begin
        if(exe2id_wreg && exe2id_wa == rs) fwrd1 = 2'b01;
        else if(mem2id_wreg && mem2id_wa == rs) fwrd1 = 2'b10;
        else fwrd1 = 2'b00;
        if(exe2id_wreg && exe2id_wa == rt) fwrd2 = 2'b01;
        else if(mem2id_wreg && mem2id_wa == rt) fwrd2 = 2'b10;
        else fwrd2 = 2'b00;
    end
    /*------------------------------------------------------------------------------*/

    // 读通用寄存器堆端口1的地址为rs字段，读端口2的地址为rt字段
    assign ra1   = rs;
    assign ra2   = rt;
                                            
    // 获得待写入目的寄存器的地址（rt或rd）
    assign id_wa_o  = rt_sel ? rt : rd;

    // 处理立即数
	wire [`REG_BUS] extimm;
	wire [`REG_BUS] uppimm;
	wire [`REG_BUS] finimm;
	assign extimm = sext ? {{16{imm[15]}}, imm} : {16'b0, imm};
	assign uppimm = {imm, 16'b0};
	assign finimm = upper ? uppimm : extimm;

    // 确定源操作数
    reg [`WORD_BUS] true_rs, true_rt, id_src1, id_src2;
    always @(*) begin
        if(fwrd1 == 2'b00) true_rs = rd1;
        else if(fwrd1 == 2'b01) true_rs = exe2id_wd;
        else true_rs = mem2id_wd;
        if(fwrd2 == 2'b00) true_rt = rd2;
        else if(fwrd2 == 2'b01) true_rt = exe2id_wd;
        else true_rt = mem2id_wd;

        if(shift) id_src1 = {27'b0, sa};
        else id_src1 = true_rs;
        if(immsel) id_src2 = finimm;
        else id_src2 = true_rt;
    end
    assign id_src1_o = id_src1;
    assign id_src2_o = id_src2;

    // din 是 rt 寄存器的值
    always @(*) begin
        case(id_aluop_o)
            `MINIMIPS32_SB:  id_din_o = {4{true_rt[7:0]}};
            `MINIMIPS32_SW:  id_din_o = {true_rt[7:0], true_rt[15:8], true_rt[23:16], true_rt[31:24]};
            default:         id_din_o = `ZERO_WORD;
        endcase
    end
    
    assign debug_wb_pc = id_debug_wb_pc;    // 上板测试时务必删除该语句      

endmodule
