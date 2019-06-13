module L1D_cache
(
    input clk,
    
    // signals to CPU
    input [31:0] mem_address,
    output logic [31:0] mem_rdata,
    input [31:0] mem_wdata,
    input mem_read,
    input mem_write,
    input [3:0] mem_byte_enable,
    output logic mem_resp,
    
    // signals to pmem
    output logic [31:0] pmem_address,
    input [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic pmem_read,
    output logic pmem_write,
    input pmem_resp,
    
    // Counter signals
    input L1D_hit_clear,
    input L1D_miss_clear,
    output logic [31:0] L1D_hit_count,
    output logic [31:0] L1D_miss_count
);

logic dirtyA_in;
logic dirtyA_W;
logic validA_W;
logic tagA_W;
logic dataA_W;
logic dirtyB_in;
logic dirtyB_W;
logic validB_W;
logic tagB_W;
logic dataB_W;
logic lru_in;
logic lru_W;

logic validA_out;
logic validB_out;
logic dirtyA_out;
logic dirtyB_out;
logic lru_out;

logic data_in_mux_sel;
logic [1:0] pmem_addr_mux_sel;
logic load_mdr;
logic load_pmem_data_out;

logic hit;
logic hitA;
    
L1D_cache_control L1D_cache_control
(
    .*
);

L1D_cache_datapath L1D_datapath
(
    .*
);


endmodule : L1D_cache
