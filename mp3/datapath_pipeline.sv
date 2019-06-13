import rv32i_types::*;

module datapath_pipeline
(
    input clk,
    
    // Memory signals
    output rv32i_word imem_addr,
    input rv32i_word imem_rdata,
    output logic imem_read,
    input logic imem_resp,
    
    output rv32i_word dmem_addr,
    input rv32i_word dmem_rdata,
    output rv32i_word dmem_wdata,
    output logic dmem_read,
    output logic dmem_write,
    output logic [3:0] dmem_byte_enable,
    input logic dmem_resp,
    
    // Counters
    output logic L1I_hit_clear,
    output logic L1I_miss_clear,
    input logic [31:0] L1I_hit_count,
    input logic [31:0] L1I_miss_count,
    output logic L1D_hit_clear,
    output logic L1D_miss_clear,
    input logic [31:0] L1D_hit_count,
    input logic [31:0] L1D_miss_count,
    output logic L2_hit_clear,
    output logic L2_miss_clear,
    input logic [31:0] L2_hit_count,
    input logic [31:0] L2_miss_count
);
logic pipeline_enable;
logic load_data_hazard;
logic stall; 

//---------------------------------------------------------------------
// IF Declare
logic [31:0] IF_pc;
logic [31:0] IF_ir_in;
logic [31:0] IF_btb_dest;
logic [31:0] btb_dest_out;
logic btb_dest_valid; // if tag matches
logic btb_jump;
logic IF_predict_taken;

logic [7:0] IF_hist_table_idx_out;
logic [1:0] IF_lbht_result;

//---------------------------------------------------------------------
// ID Declare
logic [31:0] ID_pc;
logic [31:0] ID_ir;
logic [31:0] ID_btb;
logic ID_predict_taken;

logic [31:0] ID_btb_out;
logic [31:0] ID_ir_out;
logic [31:0] ID_rs1_out;
logic [31:0] ID_rs2_out;
rv32i_control_word ID_ctrl;
rv32i_control_word ID_ctrl_out;

logic [7:0] ID_hist_table_idx_out;
logic [1:0] ID_lbht_result;

logic [2:0] ID_funct3;
logic [6:0] ID_funct7;
rv32i_opcode ID_opcode;
logic [31:0] ID_i_imm;
logic [31:0] ID_s_imm;
logic [31:0] ID_b_imm;
logic [31:0] ID_u_imm;
logic [31:0] ID_j_imm;
logic [4:0] ID_rs1;
logic [4:0] ID_rs2;
logic [4:0] ID_rd;

//---------------------------------------------------------------------
// EX Declare
logic [31:0] EX_pc;
logic [31:0] EX_ir;
logic [31:0] EX_btb;
logic [31:0] EX_rs1_out;
logic [31:0] EX_rs2_out;
logic [31:0] EX_rs1_out_forward;
logic [31:0] EX_rs2_out_forward;
logic [31:0] EX_forward_EX;
rv32i_control_word EX_ctrl;

logic [7:0] EX_hist_table_idx_out;
logic [1:0] EX_lbht_result;
logic EX_predict_taken;

logic EX_branch_taken;
logic EX_branch_mispredict;
logic EX_branch_or_jump;
logic EX_btb_active;
logic [31:0] EX_cmpmux_out;
logic EX_alumux1_sel;
logic [31:0] EX_alumux1_out;
logic [2:0] EX_alumux2_sel;
logic [31:0] EX_alumux2_out;
logic [31:0] EX_alu_out;
alu_ops EX_aluop;
logic EX_br_en;

logic [2:0] EX_funct3;
logic [6:0] EX_funct7;
rv32i_opcode EX_opcode;
logic [31:0] EX_i_imm;
logic [31:0] EX_s_imm;
logic [31:0] EX_b_imm;
logic [31:0] EX_u_imm;
logic [31:0] EX_j_imm;
logic [4:0] EX_rs1;
logic [4:0] EX_rs2;
logic [4:0] EX_rd;

//---------------------------------------------------------------------
// MEM Declare
logic MEM_br_en;
logic [31:0] MEM_pc;
logic [31:0] MEM_ir;
logic [31:0] MEM_alu_out;
logic [31:0] MEM_rs1_out;
logic [31:0] MEM_rs2_out;
rv32i_control_word MEM_ctrl;

logic [31:0] MEM_mdrmux_out;
logic [31:0] MEM_mdrmux_in;
logic [31:0] MEM_counter_data;

logic MEM_access_counter;

//---------------------------------------------------------------------
// WB Declare
logic WB_br_en;
logic [31:0] WB_pc;
logic [31:0] WB_ir;
logic [31:0] WB_alu_out;
logic [31:0] WB_mdrmux_out;
rv32i_control_word WB_ctrl;

logic [2:0] WB_regfilemux_sel;
logic [31:0] WB_regfilemux_out;

//---------------------------------------------------------------------
// END Declare
logic END_load_regfile;
logic [4:0] END_rd;
logic [31:0] END_regfilemux_out;

//---------------------------------------------------------------------
// Forwarding Declare
logic [1:0] forward_rs1;
logic [1:0] forward_rs2;

//---------------------------------------------------------------------
// Counters Declare
logic branch_mispredict_counter_clear;
logic [31:0] branch_mispredict_counter_data;
logic branch_counter_clear;
logic [31:0] branch_counter_data;
logic dcache_stall_counter_clear;
logic [31:0] dcache_stall_counter_data;
logic icache_stall_counter_clear;
logic [31:0] icache_stall_counter_data;
logic mem_hazard_counter_clear;
logic [31:0] mem_hazard_counter_data;


// IF Stage
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pc_register pc
(
    .clk(clk),
    .a(IF_pc),
    .b(IF_pc + 4),
    .c(EX_alu_out),
    .d({EX_alu_out[31:1],1'b0}),
    .e(btb_dest_out),
    .f(EX_pc + 4),
    .branch(EX_branch_taken),
    //newly added signals 
    .predict_taken(IF_predict_taken),
    .btb_jump(btb_jump),
    .EX_branch_mispredict(EX_branch_mispredict),
    .jal(EX_ctrl.jal),
    .jalr(EX_ctrl.jalr),
    .enable((imem_resp | EX_branch_mispredict) & stall),
    .out(IF_pc) 
);

assign stall = pipeline_enable & ~load_data_hazard;
assign imem_addr = IF_pc;
assign imem_read = pipeline_enable;

assign IF_predict_taken = btb_dest_valid & (IF_lbht_result[1] | btb_jump);

mux2 ir_mux
(
    .sel(imem_resp & ~EX_branch_mispredict),
    .a(32'h00000013), // NOP
    .b(imem_rdata),
    .out(IF_ir_in)
);

mux2 if_id_btb_mux
(
    .sel(imem_resp & ~EX_branch_mispredict),
    .a(32'h00000000), // Invalid btb dest value, clear
    .b(btb_dest_out),
    .out(IF_btb_dest)
);

branch_predictor IF_bp
(
    .clk(clk),
    .new_branch_enable(EX_ctrl.opcode == op_br && pipeline_enable),
    .branch_result(EX_branch_taken),
    .prev_hist_table_idx(EX_hist_table_idx_out),
    .prev_lbht_result(EX_lbht_result),
    
    .pc_9_2(IF_pc[9:2]),
    .hist_table_idx_out(IF_hist_table_idx_out),
    .lbht_result(IF_lbht_result)
);

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//*********************************************************************
// IF/ID
register pc_IF_ID
(
    .clk(clk),
    .load(stall),
    .in(IF_pc),
    .out(ID_pc)
);

register ir_IF_ID
(
    .clk(clk),
    .load(stall),
    .in(IF_ir_in),
    .out(ID_ir)
);

register btb_IF_ID (
    .clk(clk), 
    .load(stall),
   .in(IF_btb_dest),
   .out(ID_btb)
);

register #(8) IF_ID_branch_hist_idx
(
    .clk(clk),
    .load(stall),
    .in(IF_hist_table_idx_out),
    .out(ID_hist_table_idx_out)
);

register #(2) IF_ID_lbht_result
(
    .clk(clk),
    .load(stall),
    .in(IF_lbht_result),
    .out(ID_lbht_result)
);

register #(1) IF_ID_predict_taken
(
    .clk(clk),
    .load(stall),
    .in(IF_predict_taken),
    .out(ID_predict_taken)
);

//*********************************************************************
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// ID Stage
ir ID_ir_decode
(
    .in(ID_ir),
    .funct3(ID_funct3),
    .funct7(ID_funct7),
    .opcode(ID_opcode),
    .i_imm(ID_i_imm),
    .s_imm(ID_s_imm),
    .b_imm(ID_b_imm),
    .u_imm(ID_u_imm),
    .j_imm(ID_j_imm),
    .rs1(ID_rs1),
    .rs2(ID_rs2),
    .rd(ID_rd)
);

control_rom ID_ctrl_rom
(
    .opcode(ID_opcode),
    .funct3(ID_funct3),
    .funct7(ID_funct7),
    .ctrl(ID_ctrl)
);

mux2 ID_miss_predict_ir_mux
(
    .sel(EX_branch_mispredict | load_data_hazard),
    .a(ID_ir),
    .b(32'h00000013), // NOP
    .out(ID_ir_out)
);

mux2 #($bits(rv32i_control_word)) ID_load_data_hazard_mux
(
    .sel(EX_branch_mispredict | load_data_hazard),
    .a(ID_ctrl),
    .b(35'b0), // NOP Ctrl
    .out(ID_ctrl_out)
);

mux2 ID_mispredict_btb_mux (
    .sel(EX_branch_mispredict | load_data_hazard), 
    .a(ID_btb),
    .b(32'h00000000),
    .out(ID_btb_out)
);

regfile ID_regfile
(
    .clk(clk),
    .load(WB_ctrl.load_regfile),
    .in(WB_regfilemux_out),
    .src_a(ID_rs1),
    .src_b(ID_rs2),
    .dest(WB_ir[11:7]),
    .reg_a(ID_rs1_out),
    .reg_b(ID_rs2_out)
);

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//*********************************************************************
// ID/EX
register ID_EX_pc
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_pc),
    .out(EX_pc)
);

register ID_EX_ir
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_ir_out),
    .out(EX_ir)
);

register ID_EX_rs1_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_rs1_out),
    .out(EX_rs1_out)
);

register ID_EX_rs2_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_rs2_out),
    .out(EX_rs2_out)
);

register #($bits(rv32i_control_word)) ID_EX_ctrl
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_ctrl_out),
    .out(EX_ctrl)
);

register ID_EX_btb (
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_btb_out), 
    .out(EX_btb)
);

register #(8) ID_EX_branch_hist_idx
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_hist_table_idx_out),
    .out(EX_hist_table_idx_out)
);

register #(2) ID_EX_lbht_result
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_lbht_result),
    .out(EX_lbht_result)
);

register #(1) ID_EX_predict_taken
(
    .clk(clk),
    .load(pipeline_enable),
    .in(ID_predict_taken),
    .out(EX_predict_taken)
);

//*********************************************************************
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// EX Stage
assign EX_branch_taken = (EX_br_en && (EX_ctrl.opcode == op_br));
assign EX_branch_or_jump = (EX_branch_taken | EX_ctrl.jal | EX_ctrl.jalr);
assign EX_btb_active = (EX_btb == EX_alu_out); // Tells if a branch was predicted.
assign EX_branch_mispredict = (EX_branch_or_jump && !EX_predict_taken) | (EX_branch_or_jump && !EX_btb_active) | (!EX_branch_or_jump & (EX_ctrl.opcode == op_br) & EX_predict_taken);

mux4 EX_forward_rs1
(
    .sel(forward_rs1),
    .a(EX_rs1_out),
    .b(EX_forward_EX),
    .c(WB_regfilemux_out),
    .d(END_regfilemux_out),
    .out(EX_rs1_out_forward)
);

mux4 EX_forward_rs2
(
    .sel(forward_rs2),
    .a(EX_rs2_out),
    .b(EX_forward_EX),
    .c(WB_regfilemux_out),
    .d(END_regfilemux_out),
    .out(EX_rs2_out_forward)
);

mux8 EX_forward_EX_mux
(
    .sel(MEM_ctrl.regfilemux_sel),
    .a(MEM_alu_out),
    .b({31'b0, MEM_br_en}),
    .c({MEM_ir[31:12], 12'h000}), // u_imm
    .d(32'hAAAAFFFF), // should not happen
    .e(MEM_pc + 4),
    .f(),
    .g(),
    .h(),
    .out(EX_forward_EX)
);

ir EX_ir_decode
(
    .in(EX_ir),
    .funct3(EX_funct3),
    .funct7(EX_funct7),
    .opcode(EX_opcode),
    .i_imm(EX_i_imm),
    .s_imm(EX_s_imm),
    .b_imm(EX_b_imm),
    .u_imm(EX_u_imm),
    .j_imm(EX_j_imm),
    .rs1(EX_rs1),
    .rs2(EX_rs2),
    .rd(EX_rd)
);

cmp EX_cmp
(
    .cmpop(EX_ctrl.cmpop),
    .a(EX_rs1_out_forward),
    .b(EX_cmpmux_out),
    .br_en(EX_br_en)
);

mux2 EX_cmpmux
(
    .sel(EX_ctrl.cmpmux_sel),
    .a(EX_rs2_out_forward),
    .b(EX_i_imm),
    .out(EX_cmpmux_out)
);

mux2 EX_alumux1
(
    .sel(EX_ctrl.alumux1_sel),
    .a(EX_rs1_out_forward),
    .b(EX_pc),
    .out(EX_alumux1_out)
);

mux8 EX_alumux2
(
    .sel(EX_ctrl.alumux2_sel),
    .a(EX_i_imm),
    .b(EX_u_imm),
    .c(EX_b_imm),
    .d(EX_s_imm),
    .e(EX_j_imm),
    .f(EX_rs2_out_forward),
    .g(),
    .h(),
    .out(EX_alumux2_out)
);

alu EX_alu
(
    .aluop(EX_ctrl.aluop),
    .a(EX_alumux1_out),
    .b(EX_alumux2_out),
    .f(EX_alu_out)
);

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//*********************************************************************
// EX/MEM
register #(1) EX_MEM_br_en
(
    .clk(clk),
    .load(pipeline_enable),
    .in(EX_br_en),
    .out(MEM_br_en)
);

register EX_MEM_pc
(
    .clk(clk),
    .load(pipeline_enable),
    .in(EX_pc),
    .out(MEM_pc)
);

register EX_MEM_ir
(
    .clk(clk),
    .load(pipeline_enable),
    .in(EX_ir),
    .out(MEM_ir)
);

register EX_MEM_alu_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(EX_alu_out),
    .out(MEM_alu_out)
);

register EX_MEM_rs1_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(EX_rs1_out),
    .out(MEM_rs1_out)
);

register EX_MEM_rs2_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(EX_rs2_out_forward),
    .out(MEM_rs2_out)
);

register #($bits(rv32i_control_word)) EX_MEM_ctrl
(
    .clk(clk),
    .load(pipeline_enable),
    .in(EX_ctrl),
    .out(MEM_ctrl)
);

//*********************************************************************
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// MEM Stage
mux8 MEM_mdrmux
(
    .sel(MEM_ctrl.mdrmux_sel),
    .a({{24{MEM_mdrmux_in[7]}}, MEM_mdrmux_in[7:0]}),
    .b({{16{MEM_mdrmux_in[15]}}, MEM_mdrmux_in[15:0]}),
    .c(MEM_mdrmux_in),
    .d(),
    .e({24'b0, MEM_mdrmux_in[7:0]}),
    .f({16'b0, MEM_mdrmux_in[15:0]}),
    .g(),
    .h(),
    .out(MEM_mdrmux_out)
);

btb btb 
(
    .clk(clk),
    .pc(IF_pc),
    .pc_write(MEM_pc),
    .dest_in(MEM_alu_out),
    .write((MEM_br_en && (MEM_ctrl.opcode == op_br)) | MEM_ctrl.jal | MEM_ctrl.jalr),
    .j_in(MEM_ctrl.jal | MEM_ctrl.jalr),
    .dest_out(btb_dest_out),
    .valid(btb_dest_valid),
    .j_out(btb_jump)
);


assign MEM_access_counter = ~(|MEM_alu_out[31:5]);
assign MEM_mdrmux_in = (MEM_access_counter == 1) ? MEM_counter_data : dmem_rdata;
assign L1I_hit_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h0) & MEM_access_counter;
assign L1I_miss_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h1) & MEM_access_counter;
assign L1D_hit_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h2) & MEM_access_counter;
assign L1D_miss_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h3) & MEM_access_counter;
assign L2_hit_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h4) & MEM_access_counter;
assign L2_miss_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h5) & MEM_access_counter;
assign branch_mispredict_counter_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h6) & MEM_access_counter;
assign branch_counter_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h7) & MEM_access_counter;
assign dcache_stall_counter_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h8) & MEM_access_counter;
assign icache_stall_counter_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'h9) & MEM_access_counter;
assign mem_hazard_counter_clear = MEM_ctrl.dmem_write & (MEM_alu_out[4:0] == 5'hA) & MEM_access_counter;


always_comb begin
    case(MEM_alu_out[4:0])
		5'h0: MEM_counter_data = L1I_hit_count;
		5'h1: MEM_counter_data = L1I_miss_count;
		5'h2: MEM_counter_data = L1D_hit_count;
		5'h3: MEM_counter_data = L1D_miss_count;
		5'h4: MEM_counter_data = L2_hit_count;
		5'h5: MEM_counter_data = L2_miss_count;
		5'h6: MEM_counter_data = branch_mispredict_counter_data;
		5'h7: MEM_counter_data = branch_counter_data;
		5'h8: MEM_counter_data = dcache_stall_counter_data;
		5'h9: MEM_counter_data = icache_stall_counter_data;
		5'hA: MEM_counter_data = mem_hazard_counter_data;
		default: MEM_counter_data = 0;
	 endcase
end

always_comb begin
    pipeline_enable = 1;
    if(dmem_read && dmem_resp == 0)
        pipeline_enable = 0;
    else if(dmem_write && dmem_resp == 0)
        pipeline_enable = 0;
end

assign dmem_addr = MEM_alu_out;
assign dmem_wdata = MEM_rs2_out;
assign dmem_byte_enable = MEM_ctrl.dmem_byte_enable;
assign dmem_write = MEM_ctrl.dmem_write & ~MEM_access_counter;
assign dmem_read = MEM_ctrl.dmem_read & ~MEM_access_counter;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//*********************************************************************
// MEM/WB
register #(1) MEM_WB_br_en
(
    .clk(clk),
    .load(pipeline_enable),
    .in(MEM_br_en),
    .out(WB_br_en)
);

register MEM_WB_pc
(
    .clk(clk),
    .load(pipeline_enable),
    .in(MEM_pc),
    .out(WB_pc)
);

register MEM_WB_ir
(
    .clk(clk),
    .load(pipeline_enable),
    .in(MEM_ir),
    .out(WB_ir)
);

register MEM_WB_alu_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(MEM_alu_out),
    .out(WB_alu_out)
);

register MEM_WB_mdrmux_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(MEM_mdrmux_out),
    .out(WB_mdrmux_out)
);

register #($bits(rv32i_control_word)) MEM_WB_ctrl
(
    .clk(clk),
    .load(pipeline_enable),
    .in(MEM_ctrl),
    .out(WB_ctrl)
);

//*********************************************************************
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// WB Stage

mux8 WB_regfilemux
(
    .sel(WB_ctrl.regfilemux_sel),
    .a(WB_alu_out),
    .b({31'b0, WB_br_en}),
    .c({WB_ir[31:12], 12'h000}), // u_imm
    .d(WB_mdrmux_out),
    .e(WB_pc + 4),
    .f(),
    .g(),
    .h(),
    .out(WB_regfilemux_out)
);

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//*********************************************************************
// END Latches
register #(1) WB_END_load_regfile
(
    .clk(clk),
    .load(pipeline_enable),
    .in(WB_ctrl.load_regfile),
    .out(END_load_regfile)
);

register #(5) WB_END_rd
(
    .clk(clk),
    .load(pipeline_enable),
    .in(WB_ir[11:7]),
    .out(END_rd)
);

register WB_END_regfilemux_out
(
    .clk(clk),
    .load(pipeline_enable),
    .in(WB_regfilemux_out),
    .out(END_regfilemux_out)
);

//---------------------------------------------------------------------
// Forwarding Control
always_comb begin
    forward_rs1 = 0;
    if(MEM_ctrl.load_regfile == 1 && MEM_ir[11:7] == EX_rs1 && EX_rs1)
        forward_rs1 = 1;
    else if(WB_ctrl.load_regfile == 1 && WB_ir[11:7] == EX_rs1 && EX_rs1)
        forward_rs1 = 2;
    else if(END_load_regfile == 1 && END_rd == EX_rs1 && EX_rs1)
        forward_rs1 = 3;
    
    forward_rs2 = 0;
    if(END_load_regfile == 1 && END_rd == EX_rs2 && EX_rs2)
        forward_rs2 = 3;
    if(WB_ctrl.load_regfile == 1 && WB_ir[11:7] == EX_rs2 && EX_rs2)
        forward_rs2 = 2;
    if(MEM_ctrl.load_regfile == 1 && MEM_ir[11:7] == EX_rs2 && EX_rs2)
        forward_rs2 = 1;
end

always_comb begin
    load_data_hazard = 0;
    if(EX_ctrl.opcode == op_load && EX_rd != 5'b00000) begin
        if(ID_ctrl.use_rs1 == 1 && EX_rd == ID_rs1)
            load_data_hazard = 1;
        if(ID_ctrl.use_rs2 == 1 && EX_rd == ID_rs2)
            load_data_hazard = 1;
    end
end


//---------------------------------------------------------------------
// Performance Counters
counter branch_mispredict_counter_reg //0x06
(
    .clk(clk),
    .enable(EX_branch_mispredict & pipeline_enable),
    .clear(branch_mispredict_counter_clear),
    .out(branch_mispredict_counter_data)
);

counter branch_counter_reg //0x07
(
    .clk(clk),
    .enable(WB_ctrl.opcode == op_br),
    .clear(branch_counter_clear),
    .out(branch_counter_data)
);

counter dcache_stall_counter_reg //0x08
(
    .clk(clk),
    .enable(~pipeline_enable),
    .clear(dcache_stall_counter_clear),
    .out(dcache_stall_counter_data)
);

counter icache_stall_counter_reg //0x09
(
    .clk(clk),
    .enable(pipeline_enable & ~imem_resp),
    .clear(icache_stall_counter_clear),
    .out(icache_stall_counter_data)
);

counter mem_hazard_counter_reg //0x0A
(
    .clk(clk),
    .enable(load_data_hazard),
    .clear(mem_hazard_counter_clear),
    .out(mem_hazard_counter_data)
); 

endmodule : datapath_pipeline

