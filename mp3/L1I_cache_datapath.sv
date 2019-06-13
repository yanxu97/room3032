   module L1I_cache_datapath
(   
    input clk,
    
    input validA_W,
    input tagA_W,
    input dataA_W,
    input validB_W,
    input tagB_W,
    input dataB_W,
    input lru_in,
    input lru_W,
    
    input load_mdr,
    input load_mar,
    input addr_mux_sel,
    
    output logic validA_out,
    output logic validB_out,
    output logic lru_out,
    
    output logic hit,
    output logic hitA,
    
    // Memory signals with CPU
    input [31:0] mem_address,
    output logic [31:0] mem_rdata,
    input mem_read,
    
    // Memory signals with Arbiter
    output logic [31:0] pmem_address,
    input [255:0] pmem_rdata
);

logic [31:0] mar_out;
logic [31:0] addr_out;
logic [23:0] mem_tag;
logic [2:0] mem_set;
logic [4:0] mem_offset;
assign mem_tag = addr_out[31:8];
assign mem_set = addr_out[7:5];
assign mem_offset = addr_out[4:0];

logic [255:0] dataA_out;
logic [255:0] dataB_out;
logic [23:0] tagA_out;
logic [23:0] tagB_out;

logic [255:0] hit_mux_out;
logic [255:0] mdr_out;

logic hitB;
assign hitA = (mem_tag == tagA_out) & validA_out;
assign hitB = (mem_tag == tagB_out) & validB_out;
assign hit = hitA | hitB;


register L1_MAR
(
    .clk(clk),
    .load(load_mar),
    .in(mem_address),
    .out(mar_out)
);

mux2 addr_mux
(
    .sel(addr_mux_sel),
    .a(mem_address),
    .b(mar_out),
    .out(addr_out)
);


// pmem_addr out
assign pmem_address = {mem_tag, mem_set, 5'b0};


// hit out
mux2 #(256) hit_mux
(
    .sel(hitB),
    .a(dataA_out),
    .b(dataB_out),
    .out(hit_mux_out)
);


cache_word_select mem_out_word_select
(
    .offset(mem_offset),
    .in(hit_mux_out),
    .out(mem_rdata)
);


// MDR
register #(256) L1I_MDR
(
    .clk(clk),
    .load(load_mdr),
    .in(pmem_rdata),
    .out(mdr_out)
);


// Arrays
array #(256) data_array0
(
    .clk(clk),
    .write(dataA_W),
    .index(mem_set),
    .datain(mdr_out),
    .dataout(dataA_out)
);
array #(256) data_array1
(
    .clk(clk),
    .write(dataB_W),
    .index(mem_set),
    .datain(mdr_out),
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

array #(1) lru_arr
(
    .clk(clk),
    .write(lru_W),
    .index(mem_set),
    .datain(lru_in),
    .dataout(lru_out)
);



endmodule : L1I_cache_datapath

