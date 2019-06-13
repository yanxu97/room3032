
module L2_cache_write
(
	input [1:0] sel,
	input write_enable,
	output logic wayA_w,
	output logic wayB_w,
	output logic wayC_w,
	output logic wayD_w
);

always_comb
begin
	// set to non-write
	wayA_w = 1'b0;
	wayB_w = 1'b0;
	wayC_w = 1'b0;
	wayD_w = 1'b0;
	if (write_enable == 1)
	begin
		case(sel)
			2'b00:
				wayA_w = 1'b1;
			2'b01:
				wayB_w = 1'b1;
			2'b10:
				wayC_w = 1'b1;
			2'b11:
				wayD_w = 1'b1;			
		endcase
	end
end

endmodule : L2_cache_write