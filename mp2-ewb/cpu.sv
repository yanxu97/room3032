import rv32i_types::*;

module cpu
(
    input clk,

    /* Memory signals */
    input mem_resp,
    input [31:0] mem_rdata,
    output mem_read,
    output mem_write,
    output [3:0] mem_byte_enable,
    output [31:0] mem_address,
    output [31:0] mem_wdata
);

rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic bit30;
logic br_en;
logic load_pc;
logic load_ir;
logic load_regfile;
logic load_mar;
logic load_mdr;
logic [2:0] mdrmux_sel;
logic [1:0] pcmux_sel;
logic [2:0] regfilemux_sel;
logic marmux_sel;
alu_ops aluop;
logic alumux1_sel;
logic [2:0] alumux2_sel;
logic alumux3_sel;
branch_funct3_t cmpop;
logic cmpmux_sel;
logic load_data_out;
logic jalr;



control control
(
    .*
);

datapath datapath
(
    .*
);

endmodule : cpu
