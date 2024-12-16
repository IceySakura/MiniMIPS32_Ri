`include "defines.sv"

module MiniMIPS32(
    input  logic cpu_clk,
    input  logic cpu_rst_n,
    output logic [31:0] iaddr,
    input  logic [31:0] inst,
    output logic [31:0] daddr,
    output logic we,
    output logic [31:0] din,
    input  logic [31:0] dout
    );
    
    logic [`WORD_BUS      ] pc;
    
    // 连接译码阶段ID模块与通用寄存器Regfile模块的变量 
    logic [`REG_ADDR_BUS  ] A1;
    logic [`REG_BUS       ] RD1;
    logic [`REG_ADDR_BUS  ] A2;
    logic [`REG_BUS       ] RD2;
    
    // 分支跳转指令相关变量
    logic                   PCSrc;
    logic                   Branch;
    logic [`INST_ADDR_BUS]   PCBranch;
    logic [`INST_ADDR_BUS]   PCJump;
    logic [`INST_ADDR_BUS]   PCPlus4;

    // 译码阶段相关变量
    logic [`ALUCTRL_BUS   ] ALUControl;
    logic [`REG_BUS       ] SrcA;
    logic [`REG_BUS       ] SrcB;
    logic                   ALUSrc;
    
    // 访存与寄存器相关变量
    logic                   RegWrite;
    logic [`REG_ADDR_BUS  ] WriteReg;
    logic [`REG_BUS       ] WriteData;
    logic [`REG_BUS       ] RegData;
    logic [`REG_BUS       ] ALUResult;
    logic                   MemtoReg;
    logic                   MemWrite;
    logic                   RegDst;
    logic                   Jump;
    
    if_stage if_stage (
        .cpu_clk(cpu_clk),
        .cpu_rst_n(cpu_rst_n),
        .PCSrc(PCSrc),
        .Jump(Jump),
        .PCBranch(PCBranch),
        .PCJump(PCJump),
        .PCPlus4(PCPlus4),
        .iaddr(iaddr)
    );
    
    id_stage id_stage0(
        .PCPlus4(PCPlus4),
        .Instr_i(inst),
        .RD1(RD1),
        .RD2(RD2),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUControl(ALUControl),
        .ALUSrc(ALUSrc),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .WriteData(WriteData),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .PCBranch(PCBranch),
        .PCJump(PCJump),
        .A1(A1),
        .A2(A2),
        .WriteReg(WriteReg)
    );
    
    regfile regfile0(
        .cpu_clk(cpu_clk), 
        .cpu_rst_n(cpu_rst_n),
        .WE3(RegWrite), 
        .A3(WriteReg), 
        .WD3(RegData),
        .A1(A1), 
        .RD1(RD1),
        .A2(A2), 
        .RD2(RD2)
    );
    
    exe_stage exe_stage0(
        .ALUControl(ALUControl),
        .SrcA(SrcA), 
        .SrcB(SrcB),
        .Branch(Branch),
        .ALUResult(ALUResult),
        .PCSrc(PCSrc)
    );
    
    mem_stage mem_stage0(
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .MemWrite(MemWrite),
        .A(daddr),
        .WE(we),
        .WD(din)
    );
    
    wb_stage wb_stage0(
        .MemtoReg(MemtoReg),
        .ALUResult(ALUResult),       
        .ReadData(dout),     
        .RegData(RegData)  
    );
    
endmodule
