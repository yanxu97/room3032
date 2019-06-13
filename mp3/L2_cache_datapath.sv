module L2_cache_datapath
(   
    input clk,
    
	input data_w,
	input tag_w,
	input valid_w,
	input dirty_w,
	
    input dirty_in,
    input lru_W,
    
    output logic dirtyA_out,
    output logic dirtyB_out,
	output logic dirtyC_out,
	output logic dirtyD_out,
	
	input update_cache_sel,
    output logic [1:0] update_cache_out,
    
	input real_pmem_addr_mux_sel,
    input data_in_mux_sel,    
    output logic hit,
    
    // Memory signals with Arbiter
    input [31:0] mem_address,
    output logic [255:0] mem_rdata,
    input [255:0] mem_wdata,
    input mem_read,
    input mem_write,
    
    // Memory signals with physical memory
    output logic [31:0] pmem_address,
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata
);

logic [23:0] mem_tag;
logic [2:0] mem_set;
assign mem_tag = mem_address[31:8];
assign mem_set = mem_address[7:5];

logic [255:0] data_arr_in;
logic [255:0] dataA_out;
logic [255:0] dataB_out;
logic [255:0] dataC_out;
logic [255:0] dataD_out;
logic [23:0] tagA_out;
logic [23:0] tagB_out;
logic [23:0] tagC_out;
logic [23:0] tagD_out;

logic dataA_W, dataB_W, dataC_W, dataD_W;
logic tagA_W, tagB_W, tagC_W, tagD_W;
logic validA_W, validB_W, validC_W, validD_W;
logic validA_out, validB_out, validC_out, validD_out;
logic dirtyA_W, dirtyB_W, dirtyC_W, dirtyD_W;
logic [2:0] lru_in, lru_out;

logic [255:0] data_modify_out;
logic [23:0] pmem_addr_mux_out;
logic [23:0] real_pmem_addr_mux_out;

logic [1:0] replaced_out;

// LRU updates from here 
logic [1:0] hitway;
logic hitA;
logic hitB;
logic hitC;
logic hitD;

assign hitA = (mem_tag == tagA_out) & validA_out;
assign hitB = (mem_tag == tagB_out) & validB_out;
assign hitC = (mem_tag == tagC_out) & validC_out;
assign hitD = (mem_tag == tagD_out) & validD_out;

assign hit = hitA | hitB | hitC | hitD; // check if hit happens here 
L2_cache_hit_way L2_cache_hit_way
(
	.hitA(hitA),
	.hitB(hitB),
	.hitC(hitC),
	.hitD(hitD),
	.hitway(hitway)
);

// pmem_addr out
///////////////////////////////////////////////////////////////////////////////

mux4 #(24) pmem_addr_mux
(
    .sel(replaced_out),
    .a(tagA_out),  // 00
    .b(tagB_out),  // 01
    .c(tagC_out),  // 10
	.d(tagD_out),  // 11
    .out(pmem_addr_mux_out)
);

mux2 #(24) real_pmem_addr_mux  
(
	.sel(real_pmem_addr_mux_sel),
	.a(mem_tag),
	.b(pmem_addr_mux_out),
	.out(real_pmem_addr_mux_out)
);

assign pmem_address = {real_pmem_addr_mux_out, mem_set, 5'b0};

// data modify & in
mux2 #(256) data_in_mux
(
    .sel(data_in_mux_sel),
    .a(mem_wdata),
    .b(pmem_rdata),
    .out(data_arr_in)
);


// hit out
mux4 #(256) hit_mux
(
    .sel(hitway),
    .a(dataA_out),
    .b(dataB_out),
	.c(dataC_out),
	.d(dataD_out),
    .out(mem_rdata)
);

// pmem out
mux4 #(256) pmem_out_mux
(
    .sel(replaced_out),
    .a(dataA_out),
    .b(dataB_out),
	.c(dataC_out),
	.d(dataD_out),
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

array #(256) data_array2
(
    .clk(clk),
    .write(dataC_W),
    .index(mem_set),
    .datain(data_arr_in),
    .dataout(dataC_out)
);

array #(256) data_array3
(
    .clk(clk),
    .write(dataD_W),
    .index(mem_set),
    .datain(data_arr_in),
    .dataout(dataD_out)
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

array #(24) tag_array2
(
    .clk(clk),
    .write(tagC_W),
    .index(mem_set),
    .datain(mem_tag),
    .dataout(tagC_out)
);

array #(24) tag_array3
(
    .clk(clk),
    .write(tagD_W),
    .index(mem_set),
    .datain(mem_tag),
    .dataout(tagD_out)
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

array #(1) valid_arr_C
(
    .clk(clk),
    .write(validC_W),
    .index(mem_set),
    .datain(1'b1),
    .dataout(validC_out)
);

array #(1) valid_arr_D
(
    .clk(clk),
    .write(validD_W),
    .index(mem_set),
    .datain(1'b1),
    .dataout(validD_out)
);

array #(1) dirty_arr_A
(
    .clk(clk),
    .write(dirtyA_W),
    .index(mem_set),
    .datain(dirty_in),
    .dataout(dirtyA_out)
);

array #(1) dirty_arr_B
(
    .clk(clk),
    .write(dirtyB_W),
    .index(mem_set),
    .datain(dirty_in),
    .dataout(dirtyB_out)
);

array #(1) dirty_arr_C
(
    .clk(clk),
    .write(dirtyC_W),
    .index(mem_set),
    .datain(dirty_in),
    .dataout(dirtyC_out)
);

array #(1) dirty_arr_D
(
    .clk(clk),
    .write(dirtyD_W),
    .index(mem_set),
    .datain(dirty_in),
    .dataout(dirtyD_out)
);

L2_cache_write data_array_write
(
	.sel(update_cache_out),
	.write_enable(data_w),
	.wayA_w(dataA_W),
	.wayB_w(dataB_W),
	.wayC_w(dataC_W),
	.wayD_w(dataD_W)
);

L2_cache_write tag_array_write
(
	.sel(update_cache_out),
	.write_enable(tag_w),
	.wayA_w(tagA_W),
	.wayB_w(tagB_W),
	.wayC_w(tagC_W),
	.wayD_w(tagD_W)
);

L2_cache_write valid_array_write
(
	.sel(update_cache_out),
	.write_enable(valid_w),
	.wayA_w(validA_W),
	.wayB_w(validB_W),
	.wayC_w(validC_W),
	.wayD_w(validD_W)
);

L2_cache_write dirty_array_write
(
	.sel(update_cache_out),
	.write_enable(dirty_w),
	.wayA_w(dirtyA_W),
	.wayB_w(dirtyB_W),
	.wayC_w(dirtyC_W),
	.wayD_w(dirtyD_W)
);

L2_cache_lru_hit_update lru_hit_update
(
	.hit(hit),
	.hitway(hitway),
	.lru_out(lru_out),
	.lru_update(lru_in)
);

array #(3) lru_arr
(
    .clk(clk),
    .write(lru_W),
    .index(mem_set),
    .datain(lru_in),
    .dataout(lru_out)
);

L2_cache_replacement_decision replacement_decision
(
	.lru_out(lru_out),
	.replaced_out(replaced_out)
);

mux2 #(2) update_cache
(
    .sel(update_cache_sel),
    .a(replaced_out),
    .b(hitway),
    .out(update_cache_out)
);


endmodule : L2_cache_datapath
