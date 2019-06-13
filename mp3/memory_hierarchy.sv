module memory_hierarchy
(
    input clk,
    
    // Signals go into CPU Instruction port
    input [31:0] imem_addr,
    output logic [31:0] imem_rdata,
    input imem_read,
    output logic imem_resp,
    
    
    // Signals go into CPU data port
    input [31:0] dmem_addr,
    output logic [31:0] dmem_rdata,
    input [31:0] dmem_wdata,
    input dmem_read,
    input dmem_write,
    input [3:0] dmem_byte_enable,
    output logic dmem_resp,
    
    
    // Signals go into physical memory
    output logic [31:0] pmem_address,
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic pmem_read,
    output logic pmem_write,
    input pmem_resp,
    
    // Signals for counters
    input L1I_hit_clear,
    input L1I_miss_clear,
    output logic [31:0] L1I_hit_count,
    output logic [31:0] L1I_miss_count,
    input L1D_hit_clear,
    input L1D_miss_clear,
    output logic [31:0] L1D_hit_count,
    output logic [31:0] L1D_miss_count,
    input L2_hit_clear,
    input L2_miss_clear,
    output logic [31:0] L2_hit_count,
    output logic [31:0] L2_miss_count
);

logic resp_to_dmem, resp_to_imem, serving_data;

logic [31:0] dcache_address;
logic [31:0] icache_address;
logic [31:0] L2_address;
logic [255:0] L2_rdata;
logic [255:0] L2_wdata;

logic dcache_read, dcache_write, icache_read;
logic L2_read, L2_write, L2_resp;

logic [31:0] L2_ewb_addr;
logic [255:0] L2_ewb_wdata;
logic L2_ewb_read;
logic L2_ewb_write;
logic L2_ewb_resp;

arbiter_control arbiter_control(
    .clk(clk),
    .L2_resp(L2_resp),
    .dmem_read(dcache_read),
    .dmem_write(dcache_write),
    .imem_read(icache_read),
    .resp_to_dmem(resp_to_dmem),
    .resp_to_imem(resp_to_imem),
    .L2_read(L2_read),
    .L2_write(L2_write),
    .serving_data(serving_data)
);

always_comb begin
	if (serving_data) L2_address = dcache_address; 
	else L2_address = icache_address;
end

L1I_cache L1I(
    .clk(clk),
    
    // Signals go into CPU Instruction port
    .mem_address(imem_addr),
    .mem_rdata(imem_rdata),
    .mem_read(imem_read),
    .mem_resp(imem_resp),
    
    // Signals go into Arbiter / L2
    .pmem_address(icache_address),
    .pmem_rdata(L2_rdata),
    .pmem_read(icache_read),
    .pmem_resp(resp_to_imem),
    
    // Signals for counters
    .L1I_hit_clear,
    .L1I_miss_clear,
    .L1I_hit_count,
    .L1I_miss_count
);

L1D_cache L1D(
    .clk(clk),
    
    // Signals go into CPU Data port
    .mem_address(dmem_addr),
    .mem_rdata(dmem_rdata),
    .mem_wdata(dmem_wdata),
    .mem_read(dmem_read),
    .mem_write(dmem_write),
    .mem_byte_enable(dmem_byte_enable),
    .mem_resp(dmem_resp),
    
    // Signals go into Arbiter / L2
    .pmem_address(dcache_address),
    .pmem_rdata(L2_rdata),
    .pmem_wdata(L2_wdata),
    .pmem_read(dcache_read),
    .pmem_write(dcache_write),
    .pmem_resp(resp_to_dmem),
    
    // Signals for counters
    .L1D_hit_clear,
    .L1D_miss_clear,
    .L1D_hit_count,
    .L1D_miss_count
);


L2_cache L2(
    .clk(clk),
    
    // Signals come from Arbiter
    .mem_address(L2_address),
    .mem_rdata(L2_rdata),
    .mem_wdata(L2_wdata),
    .mem_read(L2_read),
    .mem_write(L2_write),
    .mem_resp(L2_resp),
    
    // Signals go into physical memory
    .pmem_address(L2_ewb_addr),
    .pmem_rdata(pmem_rdata),
    .pmem_wdata(L2_ewb_wdata),
    .pmem_read(L2_ewb_read),
    .pmem_write(L2_ewb_write),
    .pmem_resp(L2_ewb_resp),
    
    // Signals for counters
    .L2_hit_clear,
    .L2_miss_clear,
    .L2_hit_count,
    .L2_miss_count
);

eviction_write_buffer ewb
(
    .clk(clk),
    
    .L2_addr(L2_ewb_addr),
    .pmem_addr(pmem_address),
    
    .L2_wdata(L2_ewb_wdata),
    .pmem_wdata(pmem_wdata),
    
    .L2_read(L2_ewb_read),
    .L2_write(L2_ewb_write),
    .pmem_read,
    .pmem_write,
    
    .pmem_resp,
    .L2_resp(L2_ewb_resp)
);

endmodule : memory_hierarchy
