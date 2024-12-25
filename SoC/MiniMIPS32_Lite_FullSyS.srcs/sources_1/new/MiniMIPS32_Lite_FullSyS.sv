`include "defines.v"
`timescale 1ns / 1ps

module MiniMIPS32_Lite_FullSyS(
    input sys_clk_25M,                          // 系统时钟25MHz
    input sys_rst_n,                            // 系统复位
    
    input        [7 : 0]    dip_sw,             // 拨动开关输入端
    input        [7 : 0]    btn_rc,             // 键盘阵列输入端
    input                   rxd,                // 串口接收端
    output logic            txd,                // 串口发送端
    output logic [3 : 0]    anL,                // 高位数码管使能段
    output logic [7 : 0]    a_to_gL,            // 高位数码管数据段
    output logic [3 : 0]    anH,                // 低位数码管使能段
    output logic [7 : 0]    a_to_gH,            // 高位数码管数据段
    output logic [7 : 0]    leds                // LED灯输出端
    );
    
    logic clk_out, rst_n;
    assign clk_out = sys_clk_25M;
    assign rst_n = sys_rst_n;
    
    

    // inst_rom
    logic [`INST_ADDR_BUS] iaddr;
    logic                  ice;
    logic [`INST_BUS]      inst;
    // data_ram
    logic                  dce;
    logic [3 : 0]          dwe;
    logic [`WORD_BUS]      daddr;
    logic [`WORD_BUS]      din;
    logic [`WORD_BUS]      dout;
    // debug
    logic [`INST_ADDR_BUS]  debug_wb_pc;   
    logic                   debug_wb_rf_wen;
    logic [`REG_ADDR_BUS  ] debug_wb_rf_wnum;
    logic [`WORD_BUS      ] debug_wb_rf_wdata;
    MiniMIPS32 cpu(
        .cpu_clk_50M(clk_out),
        .cpu_rst_n(rst_n),

        .iaddr(iaddr),
        .ice(ice),
        .inst(inst),

        .dce(dce),
        .dwe(dwe),
        .daddr(daddr),
        .din(din),
        .dout(dout),

        .debug_wb_pc(debug_wb_pc),       // 供调试使用的PC值，上板测试时务必删除该信号
        .debug_wb_rf_wen(debug_wb_rf_wen),   // 供调试使用的PC值，上板测试时务必删除该信号
        .debug_wb_rf_wnum(debug_wb_rf_wnum),  // 供调试使用的PC值，上板测试时务必删除该信号
        .debug_wb_rf_wdata(debug_wb_rf_wdata)  // 供调试使用的PC值，上板测试时务必删除该信号
    );

    // inst_rom
    inst_rom inst_rom0(
        .clka(clk_out),
        .addra(iaddr[12:2]),
        .ena(ice),
        .douta(inst)
    );

    // inst_rom for mem
    logic                  r_ice;
    logic [`WORD_BUS]      r_iaddr;
    logic [`WORD_BUS]      r_inst;
    inst_rom inst_rom1(
        .clka(clk_out),
        .addra(r_iaddr[12:2]),
        .ena(r_ice),
        .douta(r_inst)
    );

    // data_ram
    logic                  r_dce;
    logic [3 : 0]          r_dwe;
    logic [`WORD_BUS]      r_daddr;
    logic [`WORD_BUS]      r_din;
    logic [`WORD_BUS]      r_dout;
    data_ram data_ram0(
        .clka(clk_out),
        .ena(r_dce),
        .wea(r_dwe),
        .addra(r_daddr[12:2]),
        .dina(r_din),
        .douta(r_dout)
    );

    // 记忆上一次的 daddr
    logic             last_dce;
    logic [3 : 0]     last_dwe;
    logic [`WORD_BUS] last_daddr;
    always_ff @(posedge clk_out) begin
        if (~rst_n) begin
            last_dce <= 0;
            last_dwe <= 4'b0000;
            last_daddr <= 0;
        end
        else begin
            last_dce <= dce;
            last_dwe <= dwe;
            last_daddr <= daddr;
        end
    end

    // UART
    logic [7:0] ext_uart_rx, ext_uart_tx;
    logic [7:0] ext_uart_buffer_rx, ext_uart_buffer_tx;
    logic ext_uart_ready, ext_uart_clear, ext_uart_busy, ext_uart_start;
    logic ext_uart_avai_rx, ext_uart_avai_tx;
    async_receiver #(.ClkFrequency(25000000),.Baud(9600)) //接收模块，9600无检验位
    ext_uart_r(
        .clk(clk_out),                       //外部时钟信号
        .RxD(rxd),                           //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
        .RxD_clear(ext_uart_clear),       //清除接收标志
        .RxD_data(ext_uart_rx)             //接收到的一字节数据
    );
    async_transmitter #(.ClkFrequency(25000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(clk_out),                  //外部时钟信号
        .TxD(txd),                      //串行信号输出
        .TxD_busy(ext_uart_busy),       //发送器忙状态指示
        .TxD_start(ext_uart_start),    //开始发送信号
        .TxD_data(ext_uart_tx)        //待发送的数据
    );
    assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
    always @(posedge clk_out) begin // 读的状态机
        if(ext_uart_ready) begin
            ext_uart_buffer_rx <= ext_uart_rx;
            ext_uart_avai_rx <= 1;
        end
        else if(~rst_n || (last_daddr == 32'hbfd003f8 && last_dwe == 4'b0000 && last_dce)) begin
            ext_uart_buffer_rx <= 8'h00;
            ext_uart_avai_rx <= 0;
        end
    end
    always @(posedge clk_out) begin // 写的状态机
        if(daddr == 32'hbfd003f8 && dwe != 4'b0000 && dce) begin
            ext_uart_buffer_tx <= din[7:0];
            ext_uart_avai_tx <= 0;
        end
        else if(~rst_n || (~ext_uart_busy && ~ext_uart_avai_tx)) begin
            ext_uart_buffer_tx <= 8'h00;
            ext_uart_avai_tx <= 1;
        end
    end
    
    // 矩阵键盘逻辑
    logic [3 : 0] btn_num, btn_num_buffer, btn_num_buffer_last;
    btn_array btnA(.btn_rc(btn_rc), .btn_num(btn_num));

    // 记忆相邻两次的按键值
    always_ff @(posedge clk_out) begin
        if (~rst_n) begin
            btn_num_buffer <= 0;
            btn_num_buffer_last <= 0;
        end
        else begin
            btn_num_buffer_last <= btn_num_buffer;
            btn_num_buffer <= btn_num;
        end
    end

    //  矩阵键盘缓冲区
    logic [3:0] give_cpu_btn_num;
    logic give_cpu_avi;
    always_ff @(posedge clk_out) begin
        if(btn_num_buffer_last != btn_num_buffer && btn_num_buffer != 4'b0000) begin
            give_cpu_btn_num <= btn_num_buffer;
            give_cpu_avi <= 1;
        end
        else if(~rst_n || (last_daddr == 32'hbfd003f0 && last_dwe == 4'b0000 && last_dce)) begin
            give_cpu_btn_num <= 4'b0000;
            give_cpu_avi <= 0;
        end
    end

    // 数码管逻辑
    logic [15 : 0] numberH, numberL;
    x7seg segH(
        .sys_clk(clk_out), 
        .sys_rst_n(rst_n), 
        .iDIGL(numberH[7 : 0]), 
        .iDIGH(numberH[15 : 8]), 
        .an(anH), 
        .a_to_g(a_to_gH)
    );
    
    x7seg segL(
        .sys_clk(clk_out), 
        .sys_rst_n(rst_n), 
        .iDIGL(numberL[7 : 0]), 
        .iDIGH(numberL[15 : 8]), 
        .an(anL), 
        .a_to_g(a_to_gL)
    );

    always_ff @(posedge clk_out) begin
        if(~rst_n) begin
            numberH <= 16'h0000;
            numberL <= 16'h0000;
        end
        else if(daddr == 32'hbfd00370 && dwe != 4'b0000 && dce) begin
            numberH <= {din[7:0], din[15:8]};
            numberL <= {din[23:16], din[31:24]};
        end
        else begin
            numberH <= numberH;
            numberL <= numberL;
        end
    end

    // 组合逻辑
    always_comb begin
        // .data get
        if(daddr[31:16] == 16'h8040 && dce) begin
            r_dce = dce;
            r_dwe = dwe;
            r_daddr = daddr;
            r_din = din;
        end
        // .text get
        if(daddr[31:16] == 16'h8000 && dce) begin
            r_ice = dce;
            r_iaddr = daddr;
        end

        // .data give
        if(last_daddr[31:16] == 16'h8040 && last_dwe == 4'b0000 && last_dce) begin
            dout = r_dout;
        end
        // .text give
        if(last_daddr[31:16] == 16'h8000 && last_dwe == 4'b0000 && last_dce) begin
            dout = r_inst;
        end


        // 组合逻辑的写串口 buffer
        if(~ext_uart_busy && ~ext_uart_avai_tx) begin
            ext_uart_tx = ext_uart_buffer_tx;
            ext_uart_start = 1;
        end
        else begin
            ext_uart_tx = 8'h00;
            ext_uart_start = 0;
        end            

        // 组合逻辑的读串口 buffer
        if(last_daddr == 32'hbfd003f8 && last_dwe == 4'b0000 && last_dce) begin
            dout = {ext_uart_buffer_rx, 24'b0};
        end
        // 组合逻辑的读串口 status
        if(last_daddr == 32'hbfd003fc && last_dwe == 4'b0000 && last_dce) begin
            dout = {6'b0 , ext_uart_avai_rx ,ext_uart_avai_tx , 24'b0};
        end

        // 组合逻辑的读键盘 buffer
        if(last_daddr == 32'hbfd003f4 && last_dwe == 4'b0000 && last_dce)begin
            dout = {7'b0, give_cpu_avi, 24'b0};
        end
        // 组合逻辑的读键盘 status
        if(last_daddr == 32'hbfd003f0 && last_dwe == 4'b0000 && last_dce)begin
            dout = {4'b0, give_cpu_btn_num, 24'b0};
        end
    end


    
    

   
    
    
    
    
    
endmodule