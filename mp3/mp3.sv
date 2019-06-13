module mp3
(
    input  logic clk,
    
    output logic [31:0] pmem_address,
    input  logic [255:0] pmem_rdata,
    output logic [255:0] pmem_wdata,
    output logic pmem_read,
    output logic pmem_write,
    input  logic pmem_resp
);


logic [31:0] imem_addr;
logic [31:0] imem_rdata;
logic imem_read;
logic imem_resp;

logic [31:0] dmem_addr;
logic [31:0] dmem_rdata;
logic [31:0] dmem_wdata;
logic dmem_read;
logic dmem_write;
logic [3:0] dmem_byte_enable;
logic dmem_resp;

// Counters
logic L1I_hit_clear;
logic L1I_miss_clear;
logic [31:0] L1I_hit_count;
logic [31:0] L1I_miss_count;
logic L1D_hit_clear;
logic L1D_miss_clear;
logic [31:0] L1D_hit_count;
logic [31:0] L1D_miss_count;
logic L2_hit_clear;
logic L2_miss_clear;
logic [31:0] L2_hit_count;
logic [31:0] L2_miss_count;


datapath_pipeline datapath_pipeline
(
    .*
);

memory_hierarchy memory_hierarchy
(
    .*
);

endmodule : mp3
