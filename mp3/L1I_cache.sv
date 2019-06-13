module L1I_cache
(
    input clk,
    
    // signals to CPU
    input [31:0] mem_address,
    output logic [31:0] mem_rdata,
    input mem_read,
    output logic mem_resp,
    
    // signals to Arbiter
    output logic [31:0] pmem_address,
    input [255:0] pmem_rdata,
    output logic pmem_read,
    input pmem_resp,
    
    // signals for counter
    input L1I_hit_clear,
    input L1I_miss_clear,
    output logic [31:0] L1I_hit_count,
    output logic [31:0] L1I_miss_count
);

logic validA_W;
logic tagA_W;
logic dataA_W;
logic validB_W;
logic tagB_W;
logic dataB_W;
logic lru_in;
logic lru_W;

logic load_mdr;
logic load_mar;
logic addr_mux_sel;

logic validA_out;
logic validB_out;
logic lru_out;

logic hit;
logic hitA;
    
L1I_cache_control L1I_cache_control
(
    .*
);

L1I_cache_datapath L1I_datapath
(
    .*
);


endmodule : L1I_cache
