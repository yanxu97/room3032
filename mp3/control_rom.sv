import rv32i_types::*;

module control_rom
(
    input rv32i_opcode opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    output rv32i_control_word ctrl
);
/*
typedef struct packed {
    rv32i_opcode opcode;
    branch_funct3_t cmpop;
    logic cmpmux_sel;
    logic alumux1_sel;
    alu_ops aluop;
    logic [2:0] alumux2_sel;
    logic [3:0] dmem_byte_enable;
    logic dmem_read;
    logic dmem_write;
    logic [2:0] mdrmux_sel;
    logic load_regfile;
    logic [2:0] regfilemux_sel;
    logic jump;
} rv32i_control_word;
*/
always_comb begin
    /* Default assignments */
    ctrl.opcode = opcode;
    ctrl.cmpop = branch_funct3_t'(funct3);
    ctrl.cmpmux_sel = 0;
    ctrl.alumux1_sel = 0;
    ctrl.aluop = alu_ops'(funct3);
    ctrl.alumux2_sel = 0;
    ctrl.dmem_byte_enable = 4'b1111;
    ctrl.dmem_read = 0;
    ctrl.dmem_write = 0;
    ctrl.mdrmux_sel = 2;
    ctrl.load_regfile = 0;
    ctrl.regfilemux_sel = 0;
    ctrl.jal = 0;
    ctrl.jalr = 0;
    ctrl.use_rs1 = 0;
    ctrl.use_rs2 = 0;
    
    /* Assign control signals based on opcode */
    case(opcode)
        op_lui: begin
            ctrl.load_regfile = 1;
            ctrl.regfilemux_sel = 2;
        end
        op_auipc: begin
            ctrl.alumux1_sel = 1;
            ctrl.aluop = alu_add;
            ctrl.alumux2_sel = 1;
            ctrl.load_regfile = 1;
            ctrl.regfilemux_sel = 0;
        end
        op_jal: begin
            ctrl.alumux1_sel = 1; //PC
            ctrl.aluop = alu_add;
            ctrl.alumux2_sel = 4; //j_imm
            ctrl.jal = 1;
            ctrl.load_regfile = 1;
            ctrl.regfilemux_sel = 4;
        end
        op_jalr: begin
            ctrl.alumux1_sel = 0;
            ctrl.aluop = alu_add;
            ctrl.alumux2_sel = 0;
            ctrl.jalr = 1;
            ctrl.load_regfile = 1;
            ctrl.regfilemux_sel = 4;
            ctrl.use_rs1 = 1;
        end
        op_br: begin
            ctrl.cmpop = branch_funct3_t'(funct3);
            ctrl.cmpmux_sel = 0;
            ctrl.alumux1_sel = 1;
            ctrl.aluop = alu_add;
            ctrl.alumux2_sel = 2;
            ctrl.use_rs1 = 1;
            ctrl.use_rs2 = 1;
        end
        op_load: begin
            ctrl.alumux1_sel = 0;
            ctrl.aluop = alu_add;
            ctrl.alumux2_sel = 0;
            ctrl.dmem_read = 1;
            ctrl.dmem_write = 0;
            ctrl.mdrmux_sel = funct3;
            ctrl.load_regfile = 1;
            ctrl.regfilemux_sel = 3;
            ctrl.use_rs1 = 1;
        end
        op_store: begin
            ctrl.alumux1_sel = 0;
            ctrl.aluop = alu_add;
            ctrl.alumux2_sel = 3;
            case(store_funct3_t'(funct3))
                sb: ctrl.dmem_byte_enable = 4'b0001;
                sh: ctrl.dmem_byte_enable = 4'b0011;
                sw: ctrl.dmem_byte_enable = 4'b1111;
                default: ;
            endcase
            ctrl.dmem_read = 0;
            ctrl.dmem_write = 1;
            ctrl.use_rs1 = 1;
            ctrl.use_rs2 = 1;
        end
        op_imm: begin
            ctrl.load_regfile = 1;
            if(funct3 == 3'b010) begin // SLTI
                ctrl.cmpop = blt;
                ctrl.regfilemux_sel = 1;
                ctrl.cmpmux_sel = 1;
            end else if(funct3 == 3'b011) begin // SLTIU
                ctrl.cmpop = bltu;
                ctrl.regfilemux_sel = 1;
                ctrl.cmpmux_sel = 1;
            end else if(funct3 == 3'b101 && funct7[5] == 1'b1) begin // SRAI
                ctrl.aluop = alu_sra;
            end else begin
                ctrl.aluop = alu_ops'(funct3);
            end
            ctrl.use_rs1 = 1;
        end
        op_reg: begin
            ctrl.load_regfile = 1;
            if(funct3 == 3'b010) begin // SLT
                ctrl.cmpop = blt;
                ctrl.regfilemux_sel = 1;
                ctrl.cmpmux_sel = 0;
            end else if(funct3 == 3'b011) begin // SLTU
                ctrl.cmpop = bltu;
                ctrl.regfilemux_sel = 1;
                ctrl.cmpmux_sel = 0;
            end else if(funct3 == 3'b101 && funct7[5] == 1) begin // SRA
                ctrl.alumux2_sel = 5;
                ctrl.aluop = alu_sra;
            end else if(funct3 == 3'b000 && funct7[5] == 1) begin // SUB
                ctrl.alumux2_sel = 5;
                ctrl.aluop = alu_sub;
            end else begin
                ctrl.alumux2_sel = 5;
                ctrl.aluop = alu_ops'(funct3);
            end
            ctrl.use_rs1 = 1;
            ctrl.use_rs2 = 1;
        end
        op_csr: begin
        
        end
        default: begin
            ctrl = 0; /* Unknown opcode, set control word to zero */
        end
    endcase
end
endmodule : control_rom
