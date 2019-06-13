module L1D_cache_datapath
(   
    input clk,
    
    input dirtyA_in,
    input dirtyA_W,
    input validA_W,
    input tagA_W,
    input dataA_W,
    input dirtyB_in,
    input dirtyB_W,
    input validB_W,
    input tagB_W,
    input dataB_W,
    input lru_in,
    input lru_W,
    
    output logic validA_out,
    output logic validB_out,
    output logic dirtyA_out,
    output logic dirtyB_out,
    output logic lru_out,
    
    input data_in_mux_sel,
    input [1:0] pmem_addr_mux_sel,
    input load_mdr,
    input load_pmem_data_out,
    
    output logic hit,
    output logic hitA,
    
    // Memory signals with CPU
    input [31:0] mem_address,
    output logic [31:0] mem_rdata,
    input [31:0] mem_wdata,
    input mem_read,
    input mem_write,
    input [3:0] mem_byte_enable,
    
    // Memory signals with physical memory
    output logic [31:0] pmem_address,
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata
);

logic [23:0] mem_tag;
logic [2:0] mem_set;
logic [4:0] mem_offset;
assign mem_tag = mem_address[31:8];
assign mem_set = mem_address[7:5];
assign mem_offset = mem_address[4:0];

logic [255:0] data_arr_in;
logic [255:0] dataA_out;
logic [255:0] dataB_out;
logic [23:0] tagA_out;
logic [23:0] tagB_out;

logic [255:0] hit_mux_out;
logic [255:0] data_modify_out;
logic [255:0] mdr_out;
logic [255:0] pmem_out_mux_out;
logic [23:0] pmem_addr_mux_out;

logic hitB;
assign hitA = (mem_tag == tagA_out) & validA_out;
assign hitB = (mem_tag == tagB_out) & validB_out;
assign hit = hitA | hitB;


// pmem_addr out
mux4 #(24) pmem_addr_mux
(
    .sel(pmem_addr_mux_sel),
    .a(mem_tag),
    .b(tagA_out),
    .c(tagB_out),
    .d(),
    .out(pmem_addr_mux_out)
);
assign pmem_address = {pmem_addr_mux_out, mem_set, 5'b0};

// data modify & in & MDR
register #(256) L1D_MDR
(
    .clk(clk),
    .load(load_mdr),
    .in(pmem_rdata),
    .out(mdr_out)
);


cache_data_modify cdm
(
    .mem_byte_enable(mem_byte_enable),
    .mem_wdata(mem_wdata),
    .offset(mem_offset),
    .in(hit_mux_out),
    .out(data_modify_out)
);

mux2 #(256) data_in_mux
(
    .sel(data_in_mux_sel),
    .a(data_modify_out),
    .b(mdr_out),
    .out(data_arr_in)
);


// hit out
mux2 #(256) hit_mux
(
    .sel(hitB),
    .a(dataA_out),
    .b(dataB_out),
    .out(hit_mux_out)
);


// mem out
cache_word_select mem_out_word_select
(
    .offset(mem_offset),
    .in(hit_mux_out),
    .out(mem_rdata)
);


// pmem out & pmem_data_out
mux2 #(256) pmem_out_mux
(
    .sel(lru_out),
    .a(dataA_out),
    .b(dataB_out),
    .out(pmem_out_mux_out)
);

register #(256) pmem_data_out
(
    .clk(clk),
    .load(load_pmem_data_out),
    .in(pmem_out_mux_out),
    .out(pmem_wdata)
);

// Arrays
array #(256) data_array0
(
    .clk(clk),
    .write(dataA_W),
    .index(mem_set),
    .datain(data_arr_in),
    .dataout(dataA_out)
);
array #(256) data_array1
(
    .clk(clk),
    .write(dataB_W),
    .index(mem_set),
    .datain(data_arr_in),
    .dataout(dataB_out)
);

array #(24) tag_array0
(
    .clk(clk),
    .write(tagA_W),
    .index(mem_set),
    .datain(mem_tag),
    .dataout(tagA_out)
);
array #(24) tag_array1
(
    .clk(clk),
    .write(tagB_W),
    .index(mem_set),
    .datain(mem_tag),
    .dataout(tagB_out)
);

array #(1) valid_arr_A
(
    .clk(clk),
    .write(validA_W),
    .index(mem_set),
    .datain(1'b1),
    .dataout(validA_out)
);
array #(1) valid_arr_B
(
    .clk(clk),
    .write(validB_W),
    .index(mem_set),
    .datain(1'b1),
    .dataout(validB_out)
);

array #(1) dirty_arr_A
(
    .clk(clk),
    .write(dirtyA_W),
    .index(mem_set),
    .datain(dirtyA_in),
    .dataout(dirtyA_out)
);
array #(1) dirty_arr_B
(
    .clk(clk),
    .write(dirtyB_W),
    .index(mem_set),
    .datain(dirtyB_in),
    .dataout(dirtyB_out)
);

array #(1) lru_arr
(
    .clk(clk),
    .write(lru_W),
    .index(mem_set),
    .datain(lru_in),
    .dataout(lru_out)
);


endmodule : L1D_cache_datapath
