`include "defines.sv"

module wb_stage(
    input  logic                   MemtoReg,
	input  logic [`REG_BUS       ] ALUResult,

    // 从数据存储器传来的的数据
    input  logic [`WORD_BUS      ] ReadData,
    // 写回目的寄存器的数据
    output logic [`WORD_BUS      ] RegData
    );

    logic [`WORD_BUS] data;
    assign data = {ReadData[7:0], ReadData[15:8], ReadData[23:16], ReadData[31:24]};

    assign RegData = (MemtoReg  == `MREG_ENABLE) ? data : ALUResult;
endmodule
