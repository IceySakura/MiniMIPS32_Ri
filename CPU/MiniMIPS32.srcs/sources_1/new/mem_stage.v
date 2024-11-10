`include "defines.v"

module mem_stage (

    // 从执行阶段获得的信息
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,		  // 写回目的寄存器地址
    input  wire                         mem_wreg_i,
	input  wire                         mem_mreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,		  // 写回数据, 但也可能是访存地址
    input  wire [`INST_ADDR_BUS]        mem_debug_wb_pc,  // 供调试使用的PC值，上板测试时务必删除该信号
    
    // 送至写回阶段的信息
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,		// 写回目的寄存器地址
    output wire                         mem_wreg_o,		// 写使能
	output wire                         mem_mreg_o,		// mem2reg使能
    output wire [`REG_BUS       ]       mem_dreg_o,		// 写回数据
	output reg [3 : 0]                 mem_dre_o,		// 筛选读出word的有效字节

	// data_ram	
	output reg dce,
	output reg [3 : 0] we,
    
    output wire [`INST_ADDR_BUS] 	    debug_wb_pc  // 供调试使用的PC值，上板测试时务必删除该信号
    );

    // 如果当前不是访存指令，则只需要把从执行阶段获得的信息直接输出
	assign mem_mreg_o   = mem_mreg_i;
	assign mem_wreg_o   = mem_wreg_i;
    assign mem_wa_o     = mem_wa_i;
    assign mem_dreg_o   = mem_wd_i; // 写回数据，但也可能是访存地址

	// MCU 分析当前访存指令
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
    
    assign debug_wb_pc = mem_debug_wb_pc;    // 上板测试时务必删除该语句 

endmodule