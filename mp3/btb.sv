module btb
(
	 input clk, 
	 input [31:0] pc,
	 input [31:0] pc_write,
	 input [31:0] dest_in,
	 input write,
	 input j_in,
    output logic [31:0] dest_out,
	 output logic valid,
	 output logic j_out
);

logic [22:0] pc_storage [127:0] /* synthesis ramstyle = "logic" */;
logic [31:0] dest_storage [127:0]  /* synthesis ramstyle = "logic" */;
logic [127:0] jmp_storage; 

logic a;
logic x;

initial
begin
    for (int i = 0; i < 128; i++)
    begin
        pc_storage[i] = 0;
		  dest_storage[i] = 0;
		  jmp_storage[i] = 0;
    end
end

always_ff @(posedge clk)
begin
    if (write)
    begin
      pc_storage[pc_write[8:2]] = pc_write[31:9];
		dest_storage[pc_write[8:2]] = dest_in;
		jmp_storage[pc_write[8:2]] = j_in;
    end
end

always_comb
begin
	 a = (pc[31:9] == pc_storage[pc[8:2]]);
	 x = (dest_storage[pc[8:2]] != 32'h00000000);
	 valid = a & x;
	 if (valid) begin 
		dest_out = dest_storage[pc[8:2]];
	 end else begin
		dest_out = 32'h00000000;
	 end
//	 hit = (pc[31:7] == pc_storage[pc[6:3]] && dest_in == dest_storage[pc[6:3]]); // checking whether we got a hit
	 j_out = jmp_storage[pc[8:2]];
end

endmodule : btb
