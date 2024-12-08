`include "defines.v"

module mem_stage (

    // 从执行阶段获得的信息
    input  wire                         mem_mreg_i,
    input  wire                         mem_wreg_i,
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
    input  wire [`WORD_BUS      ]       mem_din_i,
    input  wire [`INST_ADDR_BUS]        mem_debug_wb_pc,  // 供调试使用的PC值，上板测试时务必删除该信号

    // data_ram
    output reg                  dce,
    output reg [3 : 0]          dwe,
    output wire [`WORD_BUS]     daddr,
    output wire [`WORD_BUS]     din,
    
    // 送至写回阶段的信息
    output wire                         mem_mreg_o,
    output wire                         mem_wreg_o,
    output reg [3 : 0]                  mem_dre_o,
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
    
    output wire [`INST_ADDR_BUS] 	    debug_wb_pc  // 供调试使用的PC值，上板测试时务必删除该信号
    );

    // to WB
    assign mem_mreg_o   = mem_mreg_i;
    assign mem_wreg_o   = mem_wreg_i;
    assign mem_wa_o     = mem_wa_i;
    assign mem_dreg_o   = mem_wd_i;

    // to data_ram
    assign daddr = mem_wd_i;
    assign din = mem_din_i;

    /* MCU */
    // 将 mem_wd_i[1:0] 转为 one_hot
    reg [3 : 0] one_hot;
    always @(*) begin
        case (mem_wd_i[1 : 0])
            2'b00: one_hot = 4'b1000;
            2'b01: one_hot = 4'b0100;
            2'b10: one_hot = 4'b0010;
            2'b11: one_hot = 4'b0001;
            default: one_hot = 4'b0000;
        endcase
    end
    // 根据 aluop 解码
    always @(*) begin
        case (mem_aluop_i)
            `MINIMIPS32_LB:begin
                dce = 1'b1;
                dwe = 1'b0;
                mem_dre_o = one_hot;
            end
            `MINIMIPS32_LW:begin
                dce = 1'b1;
                dwe = 1'b0;
                mem_dre_o = 4'b1111;
            end
            `MINIMIPS32_SB:begin
                dce = 1'b1;
                dwe = one_hot;
            end
            `MINIMIPS32_SW:begin
                dce = 1'b1;
                dwe = 4'b1111;
            end
            default:begin
                dce = 1'b0;
                dwe = 1'b0;
                mem_dre_o = 4'b0000;
            end
        endcase
    end
    
    assign debug_wb_pc = mem_debug_wb_pc;    // 上板测试时务必删除该语句 

endmodule