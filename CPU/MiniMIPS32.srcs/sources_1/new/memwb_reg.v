`include "defines.v"

module memwb_reg (
    input  wire                     cpu_clk_50M,
	input  wire                     cpu_rst_n,

	// 来自访存阶段的信息
    input  wire                     mem_mreg,
    input  wire                     mem_wreg,
    input  wire [3 : 0]             mem_dre,
	input  wire [`REG_ADDR_BUS  ]   mem_wa,
	input  wire [`REG_BUS       ] 	mem_dreg,
	input  wire [`INST_ADDR_BUS]   mem_debug_wb_pc, // 供调试使用的PC值，上板测试时务必删除该信号

	// 送至写回阶段的信息 
    output reg                      wb_mreg, 
    output reg                      wb_wreg,
    output reg  [3 : 0]             wb_dre,
	output reg  [`REG_ADDR_BUS  ]   wb_wa,
	output reg  [`REG_BUS       ]   wb_dreg,
	
	output reg  [`INST_ADDR_BUS]    wb_debug_wb_pc  // 供调试使用的PC值，上板测试时务必删除该信号
    );

    always @(posedge cpu_clk_50M) begin
		// 复位的时候将送至写回阶段的信息清0
		if (cpu_rst_n == `RST_ENABLE) begin
			wb_wa                 <= `REG_NOP;
            wb_mreg               <= `WRITE_DISABLE;
			wb_wreg               <= `WRITE_DISABLE;
            wb_dre                <= `ZERO_WORD;
			wb_dreg               <= `ZERO_WORD;
			wb_debug_wb_pc        <= `PC_INIT;   // 上板测试时务必删除该语句
		end
		// 将来自访存阶段的信息寄存并送至写回阶段
		else begin
			wb_wa 	              <= mem_wa;
            wb_mreg               <= mem_mreg;
			wb_wreg               <= mem_wreg;
            wb_dre                <= mem_dre;
			wb_dreg               <= mem_dreg;
			wb_debug_wb_pc        <= mem_debug_wb_pc;   // 上板测试时务必删除该语句
		end
	end

endmodule