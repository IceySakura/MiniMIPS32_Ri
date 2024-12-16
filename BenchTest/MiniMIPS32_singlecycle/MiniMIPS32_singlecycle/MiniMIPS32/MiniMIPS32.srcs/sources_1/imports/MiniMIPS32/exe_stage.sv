`include "defines.sv"

module exe_stage (

    // 从译码阶段获得的信息
    input  logic [`ALUCTRL_BUS	] 	ALUControl,
    input  logic [`REG_BUS 		] 	SrcA,
    input  logic [`REG_BUS 		] 	SrcB,
    input  logic                    Branch,

    // 送至寄存器的数据
    output logic [`REG_BUS 		] 	ALUResult,
    output logic                    PCSrc
    );
    
    logic [`REG_BUS       ]      addres;          // 保存加法运算的结果
    logic [`REG_BUS       ]      orres;           // 保存或运算结果
    logic [`REG_BUS       ]      sltres;       // 保存小于置位的结果
    logic [`REG_BUS       ]      luires;       // 保存加载高半字的结果
    
    logic [`REG_BUS       ]      SrcB_tmp;
    logic                        Zero;
    
    assign SrcB_tmp = ((ALUControl == `MINIMIPS32_BEQ) | (ALUControl == `MINIMIPS32_BNE)) ? ~SrcB + 1 : SrcB;
    
    assign addres   = SrcA + SrcB_tmp;
    assign orres    = SrcA | SrcB;
    assign luires   = SrcB;    
    assign sltres   = (($signed(SrcA) < $signed(SrcB)) ? 32'b1 : 32'b0);
    
    always_comb begin
        if(ALUControl == `MINIMIPS32_BEQ) begin
            if (addres == 0) Zero = 1;
            else Zero = 0;
        end
        else if(ALUControl == `MINIMIPS32_BNE) begin
            if (addres != 0) Zero = 1;
            else Zero = 0;
        end
        else Zero = 0;
    end
    
    always_comb begin
        case(ALUControl)
            `MINIMIPS32_ADD : ALUResult = addres;
            `MINIMIPS32_OR  : ALUResult = orres;
            `MINIMIPS32_SLT : ALUResult = sltres;
            `MINIMIPS32_LUI : ALUResult = luires;
            default         : ALUResult = 32'b0;
        endcase
    end
    
    assign PCSrc = Zero & Branch;

    // 根据内部操作码aluop进行逻辑运算
    /*assign logicres = (cpu_rst_n == `RST_ENABLE)  ? `ZERO_WORD : 
                      (ALUControl == `MINIMIPS32_ORI ) ? (SrcA | SrcB) : `ZERO_WORD;

    // 根据内部操作码aluop进行移位运算
    assign shiftres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                      (ALUControl == `MINIMIPS32_SLL ) ? (SrcB << SrcA) : `ZERO_WORD;

    // 判断是否存在整数溢出异常
    logic [31: 0] exe_src2_t;
    assign exe_src2_t = (ALUControl == `MINIMIPS32_SUB) ? (~SrcB) + 1 : SrcB;
    logic [31: 0] arith_tmp;
    assign arith_tmp  = SrcA + exe_src2_t;
    // 根据内部操作码aluop进行算术运算
    assign arithres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                      (ALUControl == `MINIMIPS32_ADD  )  ? arith_tmp :
                      (ALUControl == `MINIMIPS32_LW   )  ? arith_tmp :
                      (ALUControl == `MINIMIPS32_SW   )  ? arith_tmp :
                      (ALUControl == `MINIMIPS32_SUB  )  ? arith_tmp[31:0] :
                      (ALUControl == `MINIMIPS32_SLT  )  ? (($signed(SrcA) < $signed(SrcB)) ? 32'b1 : 32'b0) :  `ZERO_WORD;
    
    // 根据操作类型alutype确定执行阶段最终的运算结果（既可能是待写入目的寄存器的数据，也可能是访问数据存储器的地址）
    assign ALUResult = (cpu_rst_n   == `RST_ENABLE ) ? `ZERO_WORD : 
                       (ALUControl == `MINIMIPS32_ORI) ? logicres  :
                       (ALUControl == `MINIMIPS32_SLL) ? shiftres  :
                       (ALUControl == `MINIMIPS32_ADD) ? arithres  :
                       (ALUControl == `MINIMIPS32_LW ) ? arithres  :
                       (ALUControl == `MINIMIPS32_SW ) ? arithres  :
                       (ALUControl == `MINIMIPS32_SUB) ? arithres  :
                       (ALUControl == `MINIMIPS32_SLT) ? arithres  : `ZERO_WORD;*/

endmodule
