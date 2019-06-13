
module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic pmem_resp;
logic pmem_read;
logic pmem_write;
logic [31:0] pmem_address;
logic [255:0] pmem_wdata;
logic [255:0] pmem_rdata;

logic halt;
logic [31:0] registers [32];

assign registers = dut.datapath_pipeline.ID_regfile.data;
assign halt = dut.datapath_pipeline.WB_ir == 32'h0000006f || dut.datapath_pipeline.WB_ir == 32'h00000063;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

always @(posedge clk) begin
    if (halt) $finish;
end


mp3 dut(
    .*
);

physical_memory memory(
    .clk,
    .read(pmem_read),
    .write(pmem_write),
    .address(pmem_address),
    .wdata(pmem_wdata),
    .resp(pmem_resp),
    .rdata(pmem_rdata)
);

endmodule : mp3_tb
