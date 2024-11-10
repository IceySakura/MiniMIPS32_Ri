`include "defines.v"

module mem_stage (

    // ��ִ�н׶λ�õ���Ϣ
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,		  // д��Ŀ�ļĴ�����ַ
    input  wire                         mem_wreg_i,
	input  wire                         mem_mreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,		  // д������, ��Ҳ�����Ƿô��ַ
    input  wire [`INST_ADDR_BUS]        mem_debug_wb_pc,  // ������ʹ�õ�PCֵ���ϰ����ʱ���ɾ�����ź�
    
    // ����д�ؽ׶ε���Ϣ
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,		// д��Ŀ�ļĴ�����ַ
    output wire                         mem_wreg_o,		// дʹ��
	output wire                         mem_mreg_o,		// mem2regʹ��
    output wire [`REG_BUS       ]       mem_dreg_o,		// д������
	output reg [3 : 0]                 mem_dre_o,		// ɸѡ����word����Ч�ֽ�

	// data_ram	
	output reg dce,
	output reg [3 : 0] we,
    
    output wire [`INST_ADDR_BUS] 	    debug_wb_pc  // ������ʹ�õ�PCֵ���ϰ����ʱ���ɾ�����ź�
    );

    // �����ǰ���Ƿô�ָ���ֻ��Ҫ�Ѵ�ִ�н׶λ�õ���Ϣֱ�����
	assign mem_mreg_o   = mem_mreg_i;
	assign mem_wreg_o   = mem_wreg_i;
    assign mem_wa_o     = mem_wa_i;
    assign mem_dreg_o   = mem_wd_i; // д�����ݣ���Ҳ�����Ƿô��ַ

	// MCU ������ǰ�ô�ָ��
	always @(*) begin
		case (mem_aluop_i)
			`MINIMIPS32_LB: begin
				dce = 1'b1;
				we = 4'b0000;
				mem_dre_o = mem_wd_i[3 : 0];
			end
			default: begin
				dce = 1'b0;
				we = 4'b0000;
				mem_dre_o = 4'b0000;
			end
		endcase
	end
    
    assign debug_wb_pc = mem_debug_wb_pc;    // �ϰ����ʱ���ɾ������� 

endmodule