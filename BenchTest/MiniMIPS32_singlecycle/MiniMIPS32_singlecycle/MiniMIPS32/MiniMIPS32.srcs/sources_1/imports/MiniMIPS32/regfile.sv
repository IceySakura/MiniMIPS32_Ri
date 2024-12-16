`include "defines.sv"

module regfile(
    input  logic 				  cpu_clk,
	input  logic 				  cpu_rst_n,
	
	// 写端口
	input  logic  [`REG_ADDR_BUS] A3,
	input  logic  [`REG_BUS     ] WD3,
	input  logic 				  WE3,
	
	// 读端口1
	input  logic  [`REG_ADDR_BUS] A1,
	output logic  [`REG_BUS 	] RD1,
	
	// 读端口2 
	input  logic  [`REG_ADDR_BUS] A2,
	output logic  [`REG_BUS     ] RD2
    );

    //定义32个32位寄存器
	logic [`REG_BUS] regs[0:`REG_NUM-1];
	
	always_ff @(posedge cpu_clk) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			regs[ 0] <= `ZERO_WORD;
			regs[ 1] <= `ZERO_WORD;
			regs[ 2] <= `ZERO_WORD;
			regs[ 3] <= `ZERO_WORD;
			regs[ 4] <= `ZERO_WORD;
			regs[ 5] <= `ZERO_WORD;
			regs[ 6] <= `ZERO_WORD;
			regs[ 7] <= `ZERO_WORD;
			regs[ 8] <= `ZERO_WORD;
			regs[ 9] <= `ZERO_WORD;
			regs[10] <= `ZERO_WORD;
			regs[11] <= `ZERO_WORD;
			regs[12] <= `ZERO_WORD;
			regs[13] <= `ZERO_WORD;
			regs[14] <= `ZERO_WORD;
			regs[15] <= `ZERO_WORD;
			regs[16] <= `ZERO_WORD;
			regs[17] <= `ZERO_WORD;
			regs[18] <= `ZERO_WORD;
			regs[19] <= `ZERO_WORD;
			regs[20] <= `ZERO_WORD;
			regs[21] <= `ZERO_WORD;
			regs[22] <= `ZERO_WORD;
			regs[23] <= `ZERO_WORD;
			regs[24] <= `ZERO_WORD;
			regs[25] <= `ZERO_WORD;
			regs[26] <= `ZERO_WORD;
			regs[27] <= `ZERO_WORD;
			regs[28] <= `ZERO_WORD;
			regs[29] <= `ZERO_WORD;
			regs[30] <= `ZERO_WORD;
			regs[31] <= `ZERO_WORD;
		end
		else begin
			if ((WE3 == `WRITE_ENABLE) && (A3 != 5'h0))	
				regs[A3] <= WD3;
		    else;
		end
	end
	
	//读端口1的读操作 
	assign RD1 = regs[A1];
	
	//读端口2的读操作 
	assign RD2 = regs[A2];

endmodule
