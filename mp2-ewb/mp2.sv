module mp2
(
    input clk,

    /* Memory signals */
    output [31:0] pmem_address,
    input [255:0] pmem_rdata,
    output [255:0] pmem_wdata,
    output pmem_read,
    output pmem_write,
    input pmem_resp
);

// signals between CPU and cache
logic mem_resp;
logic [31:0] mem_rdata;
logic mem_read;
logic mem_write;
logic [3:0] mem_byte_enable;
logic [31:0] mem_address;
logic [31:0] mem_wdata;


logic [31:0] L2_addr;
logic [255:0] L2_wdata;
logic L2_read;
logic L2_write;
logic L2_resp;



cpu cpu
(
    .*
);

cache cache
(
    .clk,
    
    // signals to CPU
    .mem_address,
    .mem_rdata,
    .mem_wdata,
    .mem_read,
    .mem_write,
    .mem_byte_enable,
    .mem_resp,
    
    // signals to pmem
    .pmem_address(L2_addr),
    .pmem_rdata,
    .pmem_wdata(L2_wdata),
    .pmem_read(L2_read),
    .pmem_write(L2_write),
    .pmem_resp(L2_resp)
);

eviction_write_buffer ewb(
    .clk,
    
    .L2_addr,
    .pmem_addr(pmem_address),
    
    .L2_wdata,
    .pmem_wdata,
    
    .L2_read,
    .L2_write,
    .pmem_read,
    .pmem_write,
    
    .pmem_resp,
    .L2_resp
);

endmodule : mp2
