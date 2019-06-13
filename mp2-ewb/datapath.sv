import rv32i_types::*;

module datapath
(
    input clk,

    /* control signals */
    input load_pc,
    input load_ir,
    input load_regfile,
    input load_mar,
    input load_mdr,
    input load_data_out,
    input [2:0] mdrmux_sel,
    input [1:0] pcmux_sel,
    input alumux1_sel,
    input [2:0] alumux2_sel,
    input [2:0] regfilemux_sel,
    input marmux_sel,
    input cmpmux_sel,
    input alu_ops aluop,
    input branch_funct3_t cmpop,
    
    input rv32i_word mem_rdata,
    
    output rv32i_word mem_address,
    output rv32i_word mem_wdata,
    output rv32i_opcode opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic br_en
);

/* declare internal signals */
rv32i_reg rs1;
rv32i_reg rs2;
rv32i_reg rd;
rv32i_word rs1_out;
rv32i_word rs2_out;
rv32i_word i_imm;
rv32i_word u_imm;
rv32i_word b_imm;
rv32i_word s_imm;
rv32i_word j_imm;
rv32i_word mdrmux_out;
rv32i_word pcmux_out;
rv32i_word alumux1_out;
rv32i_word alumux2_out;
rv32i_word regfilemux_out;
rv32i_word marmux_out;
rv32i_word cmpmux_out;
rv32i_word pc_out;
rv32i_word alu_out;
rv32i_word pc_plus4_out;
rv32i_word mdrreg_out;


/*
 * PC
 */
mux4 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus4_out),
    .b(alu_out),
    .c({alu_out[31:1],1'b0}),
    .d(),
    .f(pcmux_out)
);

pc_register pc
(
    .clk(clk),
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

assign pc_plus4_out = pc_out + 4;


/*
 * MDR
 */
register mdr_register
(
    .clk(clk),
    .load(load_mdr),
    .in(mem_rdata),
    .out(mdrreg_out)
);

mux8 mdrmux
(
    .sel(mdrmux_sel),
    .a({{24{mdrreg_out[7]}}, mdrreg_out[7:0]}),
    .b({{16{mdrreg_out[15]}}, mdrreg_out[15:0]}),
    .c(mdrreg_out),
    .d(),
    .e({24'b0, mdrreg_out[7:0]}),
    .f({16'b0, mdrreg_out[15:0]}),
    .g(),
    .h(),
    .out(mdrmux_out)
);


/*
 * IR
 */
ir IR
(
    .clk,
    .load(load_ir),
    .in(mdrreg_out),
    .funct3,
    .funct7,
    .opcode,
    .i_imm,
    .s_imm,
    .b_imm,
    .u_imm,
    .j_imm,
    .rs1,
    .rs2,
    .rd
);


/*
 * Regfile
 */
regfile regfile
(
    .clk(clk),
    .load(load_regfile),
    .in(regfilemux_out),
    .src_a(rs1),
    .src_b(rs2),
    .dest(rd),
    .reg_a(rs1_out),
    .reg_b(rs2_out)
);

mux8 regfilemux
(
    .sel(regfilemux_sel),
    .a(alu_out),
    .b({31'b0, br_en}),
    .c(u_imm),
    .d(mdrmux_out),
    .e(pc_plus4_out),
    .f(),
    .g(),
    .h(),
    .out(regfilemux_out)
);


/*
 * Regfile
 */
alu alu
(
    .aluop(aluop),
    .a(alumux1_out),
    .b(alumux2_out),
    .f(alu_out)
);

mux2 alumux1
(
    .sel(alumux1_sel),
    .a(rs1_out),
    .b(pc_out),
    .f(alumux1_out)
);

mux8 alumux2
(
    .sel(alumux2_sel),
    .a(i_imm),
    .b(u_imm),
    .c(b_imm),
    .d(s_imm),
    .e(j_imm),
    .f(rs2_out),
    .g(),
    .h(),
    .out(alumux2_out)
);


/*
 * CMP
 */
cmp cmp
(
    .cmpop(cmpop),
    .a(rs1_out),
    .b(cmpmux_out),
    .br_en(br_en)
);

mux2 cmpmux
(
    .sel(cmpmux_sel),
    .a(rs2_out),
    .b(i_imm),
    .f(cmpmux_out)
);


/*
 * mem_data_out
 */
register mem_data_out
(
    .clk(clk),
    .load(load_data_out),
    .in(rs2_out),
    .out(mem_wdata)
);


/*
 * CMP
 */
register mar_register
(
    .clk(clk),
    .load(load_mar),
    .in(marmux_out),
    .out(mem_address)
);

mux2 marmux
(
    .sel(marmux_sel),
    .a(pc_out),
    .b(alu_out),
    .f(marmux_out)
);

endmodule : datapath
