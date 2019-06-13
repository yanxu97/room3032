
module mp2_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
logic pmem_resp;
logic pmem_read;
logic pmem_write;
logic [31:0] pmem_address;
logic [255:0] pmem_wdata;
logic [255:0] pmem_rdata;

/* autograder signals */
logic [255:0] write_data;
logic [27:0] write_address;
logic write;
logic halt;
logic [31:0] registers [32];
logic [255:0] data0 [8];
logic [255:0] data1 [8];
logic [23:0] tags0 [8];
logic [23:0] tags1 [8];

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;

assign registers = dut.cpu.datapath.regfile.data;
assign halt = ((dut.cpu.datapath.IR.data == 32'h00000063) | (dut.cpu.datapath.IR.data == 32'h0000006F));
assign data0 = dut.cache.datapath.data_array0.data;
assign data1 = dut.cache.datapath.data_array1.data;
assign tags0 = dut.cache.datapath.tag_array0.data;
assign tags1 = dut.cache.datapath.tag_array1.data;

always @(posedge clk)
begin
    if (pmem_write & pmem_resp) begin
        write_address = pmem_address[31:5];
        write_data = pmem_wdata;
        write = 1;
    end else begin
        write_address = 27'hx;
        write_data = 256'hx;
        write = 0;
    end
    if (halt) $finish;
end


mp2 dut(
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

endmodule : mp2_tb

