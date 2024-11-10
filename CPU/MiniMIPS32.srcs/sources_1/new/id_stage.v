`include "defines.v"

module id_stage(
    
    // ��ȡָ�׶λ�õ�PCֵ
    input  wire [`INST_ADDR_BUS]    id_pc_i,
    input  wire [`INST_ADDR_BUS]    id_debug_wb_pc,  // ������ʹ�õ�PCֵ���ϰ����ʱ���ɾ�����ź�

    // ��ָ��洢��������ָ����
    input  wire [`INST_BUS     ]    id_inst_i,

    // ��ͨ�üĴ����Ѷ��������� 
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
      
    // ����ִ�н׶ε�������Ϣ
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,

    // ����ִ�н׶ε�Դ������1��Դ������2
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // ������ͨ�üĴ����Ѷ˿ڵ�ʹ�ܺ͵�ַ
    output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2,
    
    output       [`INST_ADDR_BUS] 	debug_wb_pc  // ������ʹ�õ�PCֵ���ϰ����ʱ���ɾ�����ź�
    );
    
    // ����С��ģʽ��ָ֯����
    wire [`INST_BUS] id_inst = {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

    // ��ȡָ�����и����ֶε���Ϣ
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    /*-------------------- ��һ�������߼���ȷ����ǰ��Ҫ�����ָ�� --------------------*/
	// R type
    wire inst_reg  = ~|op;
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
	wire inst_or   = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]& func[0];
	wire inst_xor  = inst_reg& func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0];
	wire inst_addu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]& func[0];
	wire inst_sll  = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0]&(|id_inst); // ��ȫ�㣬���� nop
	wire inst_sra  = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
	// I type
	wire inst_ori  = ~op[5]&~op[4]& op[3]& op[2]&~op[1]& op[0];
	wire inst_andi = ~op[5]&~op[4]& op[3]& op[2]&~op[1]&~op[0];
	wire inst_lui  = ~op[5]&~op[4]& op[3]& op[2]& op[1]& op[0];
	wire inst_addiu= ~op[5]&~op[4]& op[3]&~op[2]&~op[1]& op[0];
	wire inst_addi = ~op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0]; 
    /*------------------------------------------------------------------------------*/

    /*-------------------- �ڶ��������߼������ɾ�������ź� --------------------*/
    // ��������alutype
    assign id_alutype_o[2] = inst_sll | inst_sra;
    assign id_alutype_o[1] = inst_and | inst_or | inst_xor | inst_ori | inst_andi | inst_lui;
    assign id_alutype_o[0] = inst_addu| inst_addiu| inst_addi;

	// �ڲ�������aluop
	assign id_aluop_o[7]   = 1'b0;
	assign id_aluop_o[6]   = 1'b0;
	assign id_aluop_o[5]   = 1'b0;
	assign id_aluop_o[4]   = inst_and | inst_or | inst_xor | inst_addu | inst_sll | inst_sra | inst_ori  | inst_andi | inst_addiu | inst_addi;
	assign id_aluop_o[3]   = inst_and | inst_or | inst_xor | inst_addu | inst_ori | inst_andi| inst_addiu| inst_addi;
	assign id_aluop_o[2]   = inst_and | inst_or | inst_xor | inst_ori  | inst_andi| inst_lui;
	assign id_aluop_o[1]   = inst_xor | inst_sra;
	assign id_aluop_o[0]   = inst_or  | inst_sll| inst_ori | inst_lui;

    // дͨ�üĴ���ʹ���ź�
    assign id_wreg_o       = inst_and | inst_or  | inst_xor | inst_addu | inst_sll | inst_sra 
						   | inst_ori | inst_andi| inst_lui | inst_addiu| inst_addi;
    // ��ͨ�üĴ����Ѷ˿�1ʹ���ź�
    assign rreg1 = 1'b1;
    // ��ͨ�üĴ����Ѷ��˿�2ʹ���ź�
    assign rreg2 = 1'b1;

	/*-------------------- ����һЩֻ�� ID �׶�ʹ�õĿ����ź� --------------------*/
	wire shift;
	wire rt_sel;
	wire sext;
	wire upper;
	wire immsel;
	assign shift = inst_sll | inst_sra; 												// shift�ź���Чʱ��Դ������1Ϊ��λλ��
	assign rt_sel = inst_ori | inst_andi | inst_lui | inst_addiu| inst_addi;			// rt_sel�ź���Чʱ��Ŀ�ļĴ���Ϊrt�ֶ�
	assign sext = inst_addiu | inst_addi;												// sext�ź���Чʱ��������Ϊ������չ
	assign upper = inst_lui;															// upper�ź���Чʱ��������Ϊ��16λ
	assign immsel = inst_ori | inst_andi | inst_lui | inst_addiu| inst_addi;			// immsel�ź���Чʱ��Դ������2Ϊ������
    /*------------------------------------------------------------------------------*/

    // ��ͨ�üĴ����Ѷ˿�1�ĵ�ַΪrs�ֶΣ����˿�2�ĵ�ַΪrt�ֶ�
    assign ra1   = rs;
    assign ra2   = rt;
                                            
    // ��ô�д��Ŀ�ļĴ����ĵ�ַ��rt��rd��
    assign id_wa_o  = rt_sel ? rt : rd;

    // ���Դ������1�����shift�ź���Ч����Դ������1Ϊ��λλ��������Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�1��õ�����
	assign id_src1_o = shift ? {27'b0, sa} : rd1;

	// ����������
	wire [`REG_BUS] extimm;
	wire [`REG_BUS] uppimm;
	wire [`REG_BUS] finimm;
	assign extimm = sext ? {imm[15], imm} : {16'b0, imm};
	assign uppimm = {imm, 16'b0};
	assign finimm = upper ? uppimm : extimm;
    // ���Դ������2�����immsel�ź���Ч����Դ������1Ϊ������������Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�2��õ�����
	assign id_src2_o = immsel ? finimm : rd2;           
    
    assign debug_wb_pc = id_debug_wb_pc;    // �ϰ����ʱ���ɾ�������      

endmodule
