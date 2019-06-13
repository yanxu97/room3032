module L2_cache
(
    input clk,
    
    // signals to Arbiter
    input [31:0] mem_address,
    output logic [255:0] mem_rdata,
    input [255:0] mem_wdata,
    input mem_read,
    input mem_write,
    output logic mem_resp,
    
    // signals to pmem
    output logic [31:0] pmem_address,
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic pmem_read,
    output logic pmem_write,
    input pmem_resp,
	
	input L2_hit_clear,
    input L2_miss_clear,
    output logic [31:0] L2_hit_count,
    output logic [31:0] L2_miss_count
);

logic data_w;
logic tag_w;
logic valid_w;
logic dirty_w;

logic dirty_in;
logic lru_W;

logic dirtyA_out;
logic dirtyB_out;
logic dirtyC_out;
logic dirtyD_out;
logic [1:0] update_cache_out;

logic data_in_mux_sel;
logic real_pmem_addr_mux_sel;
logic update_cache_sel; // newly added and be careful
logic hit;
	
L2_cache_control L2_control
(
    .*
);

L2_cache_datapath L2_datapath
(
    .*
);


endmodule : L2_cache
