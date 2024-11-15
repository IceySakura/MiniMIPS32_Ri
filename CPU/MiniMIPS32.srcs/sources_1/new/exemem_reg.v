`include "defines.v"

module exemem_reg (
    input  wire 				cpu_clk_50M,
    input  wire 				cpu_rst_n,

    // 来自执行阶段的信息
    input  wire [`ALUOP_BUS   ] exe_aluop,
    input  wire [`REG_ADDR_BUS] exe_wa,
    input  wire                 exe_wreg,
	input  wire                 exe_mreg,
    input  wire [`REG_BUS 	  ] exe_wd,
    input  wire [`INST_ADDR_BUS]  exe_debug_wb_pc, // 供调试使用的PC值，上板测试时务必删除该信号
    
    // 送到访存阶段的信息 
    output reg  [`ALUOP_BUS   ] mem_aluop,
    output reg  [`REG_ADDR_BUS] mem_wa,
    output reg                  mem_wreg,
	output reg                  mem_mreg,
    output reg  [`REG_BUS 	  ] mem_wd,				// 写回数据, 但也可能是访存地址，给data_ram也来一份
    output reg  [`INST_ADDR_BUS]  mem_debug_wb_pc,  // 供调试使用的PC值，上板测试时务必删除该信号
    );

    always @(posedge cpu_clk_50M) begin
    if (cpu_rst_n == `RST_ENABLE) begin
        mem_aluop              <= `MINIMIPS32_SLL;
        mem_wa 				   <= `REG_NOP;
        mem_wreg   			   <= `WRITE_DISABLE;
		mem_mreg   			   <= `WRITE_DISABLE;
        mem_wd   			   <= `ZERO_WORD;
        mem_debug_wb_pc        <= `PC_INIT;   // 上板测试时务必删除该语句
    end
    else begin
        mem_aluop              <= exe_aluop;
        mem_wa 				   <= exe_wa;
        mem_wreg 			   <= exe_wreg;
		mem_mreg 			   <= exe_mreg;
        mem_wd 		    	   <= exe_wd;
        mem_debug_wb_pc        <= exe_debug_wb_pc;   // 上板测试时务必删除该语句
    end
  end

endmodule