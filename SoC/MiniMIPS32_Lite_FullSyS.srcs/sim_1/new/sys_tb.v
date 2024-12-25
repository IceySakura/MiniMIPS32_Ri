`timescale 1ps / 1ps

module sys_tb();

    // Inputs
    reg sys_clk_25M;
	reg sys_rst_n;
	
	wire [31 : 0]           debug_wb_pc;       // 供调试使用的PC值，上板测试时务必删除该信号
    wire                    debug_wb_rf_wen;   // 供调试使用的PC值，上板测试时务必删除该信号
    wire [31 : 0]           debug_wb_rf_wnum;  // 供调试使用的PC值，上板测试时务必删除该信号
    wire [31 : 0]           debug_wb_rf_wdata;  // 供调试使用的PC值，上板测试时务必删除该信号
    
    wire soc_clk;
	
    wire rxd, txd;
	MiniMIPS32_Lite_FullSyS SoC (
        .sys_clk_25M(sys_clk_25M),
        .sys_rst_n(sys_rst_n),

        .rxd(rxd),
        .txd(txd)
	);
	
	initial begin
		// Initialize Inputs
        sys_clk_25M = 0;
		sys_rst_n = 0;
		
		#200_000;
		sys_rst_n = 1'b1;
		
		#200_000_000 $stop;
	end
	
	always #20000 sys_clk_25M = ~sys_clk_25M; 
	
	// 以下程序仅供调试使用
	assign soc_clk           = SoC.clk_out;
	
	assign debug_wb_pc        = SoC.debug_wb_pc;       // 供调试使用的PC值，上板测试时务必删除该信号
	assign debug_wb_rf_wen    = SoC.debug_wb_rf_wen;   // 供调试使用的PC值，上板测试时务必删除该信号
	assign debug_wb_rf_wnum   = SoC.debug_wb_rf_wnum;  // 供调试使用的PC值，上板测试时务必删除该信号
	assign debug_wb_rf_wdata  = SoC.debug_wb_rf_wdata; // 供调试使用的PC值，上板测试时务必删除该信号
	
	always @(posedge soc_clk) begin
	   if(debug_wb_rf_wen && debug_wb_rf_wnum!=5'd0) begin
	   /*
	       $display("--------------------------------------------------------------");
           $display("[%t]ns",$time/1000);
           $display("reference: PC = 0x%8h, wb_rf_wnum = 0x%2h, wb_rf_wdata = 0x%8h",
                      debug_wb_pc, debug_wb_rf_wnum, debug_wb_rf_wdata);
           $display("--------------------------------------------------------------");
           */
//           $display("0x%8h  %d  0x%8h",
//                      debug_wb_pc, debug_wb_rf_wnum, debug_wb_rf_wdata);    
	   end
	end

    // 监视 txd
    // Variable to hold the byte being captured
    reg [7:0] byte_buffer;
    reg [3:0] bit_count;
    reg capture_data;

    always @(posedge soc_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            byte_buffer <= 8'd0;
            bit_count <= 4'd0;
            capture_data <= 1'b0;
        end else begin
            // Monitor txd signal, when txd is 0, start capturing data
            if (txd == 1'b0 && !capture_data) begin
                capture_data <= 1'b1; // Start capturing
                byte_buffer <= 8'd0;   // Clear buffer
                bit_count <= 4'd0;     // Reset bit count
            end
            
            else if (capture_data) begin
                // Shift in the txd bit into the byte buffer
                byte_buffer <= {txd, byte_buffer[7:1]};
                bit_count <= bit_count + 1;
                
                // Once we have captured 8 bits, display the byte and reset
                if (bit_count == 4'd8) begin
                    $display("Captured Byte: 0x%2h %c", byte_buffer, byte_buffer);
                    capture_data <= 1'b0; // Stop capturing
                    bit_count <= 4'd0;    // Reset bit counter
                end
            end
        end
    end

    // 输出 rxd， 一个 T (0x54) 字符
    reg [7:0] data_to_send = 8'h54; // 数据：0x54 (01010100)
    reg [3:0] bit_count = 0;        // 当前发送的位计数
    reg rxd_reg = 1'b1;             // 初始化 rxd 为 1 (默认空闲状态)
    reg transmitting = 0;           // 标识是否正在发送数据
    reg done = 0;

    // 输出 rxd 数据，每次发送一个 bit
    always @(posedge soc_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            rxd_reg <= 1'b1;         // 复位时 rxd 为高电平（空闲状态）
            bit_count <= 4'd0;       // 计数器复位
            transmitting <= 0;        // 停止传输
        end 
        else if(~done) begin
            if (!transmitting) begin
                // 如果还没开始发送数据，则先发送一个 start bit（低电平 0）
                rxd_reg <= 1'b0; // 发送 start bit
                transmitting <= 1; // 开始发送数据
            end 
            else if (bit_count < 9) begin
                // 发送数据
                if (bit_count == 8) begin
                    // 完成数据发送后，返回到空闲状态
                    rxd_reg <= 1'b1; // 发送 stop bit（1）
                    transmitting <= 0; // 结束传输
                    done <= 1; // 标记数据发送完毕
                end else begin
                    // 逐位发送数据（0x54 -> 01010100）
                    rxd_reg <= data_to_send[bit_count]; // 发送当前位
                end
                bit_count <= bit_count + 1; // 增加计数器
            end
        end
    end

    // 将 rxd_reg 赋值给 rxd 输出
    assign rxd = rxd_reg;

endmodule
