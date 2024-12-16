`include "defines.sv"

module if_stage(
    input 	logic                    cpu_clk,
    input   logic                    cpu_rst_n,
    input   logic                    PCSrc,
    input   logic                    Jump,
    input   logic [`INST_ADDR_BUS]   PCBranch,
    input   logic [`INST_ADDR_BUS]   PCJump,
    
    output  logic [`INST_ADDR_BUS] 	 PCPlus4,
    output  logic [`INST_ADDR_BUS]   iaddr
    );
    
    logic [`INST_ADDR_BUS]   pc;
    logic [`INST_ADDR_BUS]   pc_next_tmp;
    logic [`INST_ADDR_BUS]   pc_next;
    
    assign PCPlus4 = pc + 4;
    assign pc_next_tmp = (PCSrc) ? PCBranch : PCPlus4;
    assign pc_next = (Jump) ? PCJump : pc_next_tmp;  

    always_ff @(posedge cpu_clk) begin
        if (cpu_rst_n == `RST_ENABLE)
            pc <= `PC_INIT;
        else begin
            pc <= pc_next;
        end
    end

    assign iaddr = pc;
    
endmodule
