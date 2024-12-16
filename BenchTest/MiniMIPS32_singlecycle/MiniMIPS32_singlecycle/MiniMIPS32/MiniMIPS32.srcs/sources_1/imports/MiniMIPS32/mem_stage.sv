`include "defines.sv"

module mem_stage (

    // 从译码和执行阶段获得的信息
    input  logic [`REG_BUS       ]      ALUResult,
    input  logic [`REG_BUS       ]      WriteData,
    input  logic                        MemWrite,

    // 送至数据存储器的信号
    output logic [`INST_ADDR_BUS ]       A,
    output logic                         WE,
    output logic [`REG_BUS       ]       WD
    );

    // 获得数据存储器的访问地址,待写入的数据和写使能
    assign A = ALUResult;
    assign WD = ((ALUResult[31:16] == 16'h8000) | (ALUResult[31:16] == 16'h8004)) ? 
                    WriteData : {WriteData[7 : 0], WriteData[15 : 8], WriteData[23 : 16], WriteData[31 : 24]};
    assign WE = (ALUResult[31] == 1'b1) ? 1'b0 : MemWrite;

endmodule
