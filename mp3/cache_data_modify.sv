import rv32i_types::*;

module cache_data_modify
(
    input [3:0] mem_byte_enable,
    input rv32i_word mem_wdata,
    input [4:0] offset,
    input [255:0] in,
    output logic [255:0] out
);

logic cdmw7_sel,cdmw6_sel,cdmw5_sel,cdmw4_sel,cdmw3_sel,cdmw2_sel,cdmw1_sel,cdmw0_sel;
always_comb begin
    cdmw7_sel = 0;
    cdmw6_sel = 0;
    cdmw5_sel = 0;
    cdmw4_sel = 0;
    cdmw3_sel = 0;
    cdmw2_sel = 0;
    cdmw1_sel = 0;
    cdmw0_sel = 0;
    case(offset[4:2])
        3'b000: cdmw0_sel = 1;
        3'b001: cdmw1_sel = 1;
        3'b010: cdmw2_sel = 1;
        3'b011: cdmw3_sel = 1;
        3'b100: cdmw4_sel = 1;
        3'b101: cdmw5_sel = 1;
        3'b110: cdmw6_sel = 1;
        3'b111: cdmw7_sel = 1;
    endcase
end


logic [31:0] cdmw7_out;
logic [31:0] cdmw6_out;
logic [31:0] cdmw5_out;
logic [31:0] cdmw4_out;
logic [31:0] cdmw3_out;
logic [31:0] cdmw2_out;
logic [31:0] cdmw1_out;
logic [31:0] cdmw0_out;

cache_data_modify_word cdmw7(
    .in(in[255:224]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw7_out)
);
mux2 cdm_mux7(
    .sel(cdmw7_sel),
    .a(in[255:224]),
    .b(cdmw7_out),
    .out(out[255:224])
);

cache_data_modify_word cdmw6(
    .in(in[223:192]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw6_out)
);
mux2 cdm_mux6(
    .sel(cdmw6_sel),
    .a(in[223:192]),
    .b(cdmw6_out),
    .out(out[223:192])
);

cache_data_modify_word cdmw5(
    .in(in[191:160]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw5_out)
);
mux2 cdm_mux5(
    .sel(cdmw5_sel),
    .a(in[191:160]),
    .b(cdmw5_out),
    .out(out[191:160])
);

cache_data_modify_word cdmw4(
    .in(in[159:128]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw4_out)
);
mux2 cdm_mux4(
    .sel(cdmw4_sel),
    .a(in[159:128]),
    .b(cdmw4_out),
    .out(out[159:128])
);

cache_data_modify_word cdmw3(
    .in(in[127:96]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw3_out)
);
mux2 cdm_mux3(
    .sel(cdmw3_sel),
    .a(in[127:96]),
    .b(cdmw3_out),
    .out(out[127:96])
);

cache_data_modify_word cdmw2(
    .in(in[95:64]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw2_out)
);
mux2 cdm_mux2(
    .sel(cdmw2_sel),
    .a(in[95:64]),
    .b(cdmw2_out),
    .out(out[95:64])
);

cache_data_modify_word cdmw1(
    .in(in[63:32]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw1_out)
);
mux2 cdm_mux1(
    .sel(cdmw1_sel),
    .a(in[63:32]),
    .b(cdmw1_out),
    .out(out[63:32])
);

cache_data_modify_word cdmw0(
    .in(in[31:0]),
    .mem_byte_enable_in(mem_byte_enable),
    .mem_wdata_in(mem_wdata),
    .offset_2(offset[1:0]),
    .out(cdmw0_out)
);
mux2 cdm_mux0(
    .sel(cdmw0_sel),
    .a(in[31:0]),
    .b(cdmw0_out),
    .out(out[31:0])
);

endmodule : cache_data_modify



module cache_data_modify_word
(
    input [31:0] in,
    input [3:0] mem_byte_enable_in,
    input [31:0] mem_wdata_in,
    input [1:0] offset_2,
    output logic [31:0] out
);

logic [3:0] mem_byte_enable;
logic [31:0] mem_wdata;

assign mem_byte_enable = mem_byte_enable_in << offset_2;

always_comb begin
    case(offset_2)
        2'b00: mem_wdata = mem_wdata_in;
        2'b01: mem_wdata = mem_wdata_in << 8;
        2'b10: mem_wdata = mem_wdata_in << 16;
        2'b11: mem_wdata = mem_wdata_in << 24;
    endcase
    
    out = in;
    if(mem_byte_enable[3]) begin
        out[31:24] = mem_wdata[31:24];
    end
    if(mem_byte_enable[2]) begin
        out[23:16] = mem_wdata[23:16];
    end
    if(mem_byte_enable[1]) begin
        out[15:8] = mem_wdata[15:8];
    end
    if(mem_byte_enable[0]) begin
        out[7:0] = mem_wdata[7:0];
    end
end

endmodule : cache_data_modify_word
