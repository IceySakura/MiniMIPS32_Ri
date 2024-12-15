`include "defines.v"

module if_stage (
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,
    
    output  reg                     ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	     [`INST_ADDR_BUS]	iaddr,
    output       [`INST_ADDR_BUS] 	debug_wb_pc,  // 供调试使用的PC值，上板测试时务必删除该信号

    input   wire [`INST_ADDR_BUS] 	bj_pc        // branch or jump pc
    );
    
    wire [`INST_ADDR_BUS] pc_next; 
    assign pc_next = pc + 4;                  // 计算下一条指令的地址
    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			ice <= `CHIP_DISABLE;		      // 复位的时候指令存储器禁用  
		end else begin
			ice <= `CHIP_ENABLE; 		      // 复位结束后，指令存储器使能
		end
	end

    always @(posedge cpu_clk_50M) begin
        if (ice == `CHIP_DISABLE)
            pc <= `PC_INIT;                   // 指令存储器禁用的时候，PC保持初始值（MiniMIPS32中设置为0xBFC00000）
        else begin
            if (bj_pc != 32'h00000000) begin
                pc <= bj_pc;                   // 分支或跳转指令的目标地址
            end else begin
                pc <= pc_next;                 // 下一条指令的地址
            end
        end
    end
    
    // TODO：指令存储器的访问地址没有根据其所处范围进行进行固定地址映射，需要修改!!!
    assign iaddr = ((ice == `CHIP_DISABLE) ? `PC_INIT : pc) & 32'h7fffffff;    // 获得访问指令存储器的地址
    
    assign debug_wb_pc = pc;   // 上板测试时务必删除该语句

endmodule