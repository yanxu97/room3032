import rv32i_types::*; /* Import types defined in rv32i_types.sv */

module control
(
    input clk,
    /* Datapath controls */
    output logic load_pc,
    output logic load_ir,
    output logic load_regfile,
    output logic load_mar,
    output logic load_mdr,
    output logic load_data_out,
    output logic [2:0] mdrmux_sel,
    output logic [1:0] pcmux_sel,
    output logic alumux1_sel,
    output logic [2:0] alumux2_sel,
    output logic [2:0] regfilemux_sel,
    output logic marmux_sel,
    output logic cmpmux_sel,
    output alu_ops aluop,
    output branch_funct3_t cmpop,
    
    input rv32i_opcode opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input br_en,
    
    /* Memory signals */
    input mem_resp,
    output logic mem_read,
    output logic mem_write,
    output rv32i_mem_wmask mem_byte_enable
);

enum int unsigned {
    /* List of states */
    fetch1,
    fetch2,
    fetch3,
    decode,
    s_imm,
    s_lui,
    s_auipc,
    s_br,
    s_calc_addr,
    s_ld1, s_ld2,
    s_st1, s_st2,
    s_reg,
    s_jal,
    s_jalr
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
    load_pc = 0;
    load_ir = 0;
    load_regfile = 0;
    load_mar = 0;
    load_mdr = 0;
    load_data_out = 0;
    mdrmux_sel = 2; // default load all 32 bit
    pcmux_sel = 0;
    cmpop = branch_funct3_t'(funct3);
    alumux1_sel = 0;
    alumux2_sel = 0;
    regfilemux_sel = 0;
    marmux_sel = 0;
    cmpmux_sel = 0;
     //in many cases, aluop will be the same as funct3, so just typecast it
    aluop = alu_ops'(funct3);
    mem_read = 0;
    mem_write = 0;
    mem_byte_enable = 4'b1111;
    
    case(state)
        fetch1: begin
            /* MAR <= PC */
            load_mar = 1;
        end
        
        fetch2: begin
            /* Read memory */
            mem_read = 1;
            load_mdr = 1;
        end
        
        fetch3: begin
            /* Load IR */
            load_ir = 1;
        end
        
        decode: /* Do nothing */;
        
        s_imm: begin
            load_regfile = 1;
            load_pc = 1;
            if(funct3 == 3'b010) begin// SLTI
                cmpop = blt;
                regfilemux_sel = 1;
                cmpmux_sel = 1;
            end else if(funct3 == 3'b011) begin // SLTIU
                cmpop = bltu;
                regfilemux_sel = 1;
                cmpmux_sel = 1;
            end else if(funct3 == 3'b101 && funct7[5] == 1) begin // SRAI
                aluop = alu_sra;
            end else begin
                aluop = alu_ops'(funct3);
            end
        end
        
        s_lui: begin
            load_regfile = 1;
            load_pc = 1;
            regfilemux_sel = 2;
        end
        
        s_auipc: begin
            /* DR <= PC + u_imm */
            load_regfile = 1;
            //PC is the first input to the ALU
            alumux1_sel = 1;
            //the u-type immediate is the second input to the ALU
            alumux2_sel = 1;
            //in the case of auipc, funct3 is some random bits so we
            //must explicitly set the aluop
            aluop = alu_add;
            /* PC <= PC + 4 */
            load_pc = 1;
        end
        
        s_br: begin
            pcmux_sel = {1'b0, br_en};
            load_pc = 1;
            alumux1_sel = 1;
            alumux2_sel = 2;
            aluop = alu_add;
        end
        
        s_calc_addr: begin
            if(opcode == op_load) begin
                aluop = alu_add;
                load_mar = 1;
                marmux_sel = 1;
            end
            if(opcode == op_store) begin
                alumux2_sel = 3;
                aluop = alu_add;
                load_mar = 1;
                load_data_out = 1;
                marmux_sel = 1;
            end
        end
        
        s_ld1: begin
            load_mdr = 1;
            mem_read = 1;
        end
        
        s_ld2: begin
            mdrmux_sel = funct3;
            regfilemux_sel = 3;
            load_regfile = 1;
            load_pc = 1;
        end
        
        s_st1: begin
            mem_write = 1;
            case(store_funct3_t'(funct3))
                sb: mem_byte_enable = 4'b0001;
                sh: mem_byte_enable = 4'b0011;
                sw: mem_byte_enable = 4'b1111;
					 default: ;
            endcase
        end
        
        s_st2: begin
            load_pc = 1;
        end
        
        s_reg: begin
            load_regfile = 1;
            load_pc = 1;
            if(funct3 == 3'b010) begin // SLT
                cmpop = blt;
                regfilemux_sel = 1;
                cmpmux_sel = 0;
            end else if(funct3 == 3'b011) begin // SLTU
                cmpop = bltu;
                regfilemux_sel = 1;
                cmpmux_sel = 0;
            end else if(funct3 == 3'b101 && funct7[5] == 1) begin // SRA
                alumux2_sel = 5;
                aluop = alu_sra;
            end else if(funct3 == 3'b000 && funct7[5] == 1) begin // SUB
                alumux2_sel = 5;
                aluop = alu_sub;
            end else begin
                alumux2_sel = 5;
                aluop = alu_ops'(funct3);
            end
        end
        
        s_jal: begin
            alumux1_sel = 1; // Select pc_out
            alumux2_sel = 4; // Select j_imm
            aluop = alu_add;
            pcmux_sel = 1; // Select alu_out
            load_pc = 1;
            regfilemux_sel = 4; // Select pc+4
            load_regfile = 1;
        end
        
        s_jalr: begin
            alumux1_sel = 0; // select rs1_out
            alumux2_sel = 0; // select i_imm
            aluop = alu_add;
            pcmux_sel = 2; // select alu_out with least-significant bit -> 0
            load_pc = 1;
            regfilemux_sel = 4; // select pc+4
            load_regfile = 1;
        end
        
        default: /* Do nothing */;
        
    endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
    next_state = state;
    case(state)
        fetch1: next_state = fetch2;
        fetch2: if (mem_resp) next_state = fetch3;
        fetch3: next_state = decode;
        decode: begin
            case(opcode)
                op_imm: next_state = s_imm;
                op_lui: next_state = s_lui;
                op_auipc: next_state = s_auipc;
                op_br: next_state = s_br;
                op_load: next_state = s_calc_addr;
                op_store: next_state = s_calc_addr;
                op_reg: next_state = s_reg;
                op_jal: next_state = s_jal;
                op_jalr: next_state = s_jalr;
                default: $display("Unknown opcode");
            endcase
        end
        s_imm: next_state = fetch1;
        s_lui: next_state = fetch1;
        s_auipc: next_state = fetch1;
        s_br: next_state = fetch1;
        s_calc_addr: begin
            if(opcode == op_load)
                next_state = s_ld1;
            if(opcode == op_store)
                next_state = s_st1;
        end
        s_ld1: if(mem_resp) next_state = s_ld2;
        s_ld2: next_state = fetch1;
        s_st1: if(mem_resp) next_state = s_st2;
        s_st2: next_state = fetch1;
        s_reg: next_state = fetch1;
        s_jal: next_state = fetch1;
        s_jalr: next_state = fetch1;
        default: next_state = fetch1;
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= next_state;
end

endmodule : control
