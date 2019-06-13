
module L2_cache_hit_way
(
	input hitA,
	input hitB,
	input hitC,
	input hitD,
	output logic [1:0] hitway
);
// only if hit is one, hitway can be meaningful
always_comb
begin
	hitway = 2'b00;
	if (hitA == 1)
		hitway = 2'b00;
	else if (hitB == 1)
		hitway = 2'b01;
	else if (hitC == 1)
		hitway = 2'b10;
	else if (hitD == 1)
		hitway = 2'b11;
end

endmodule: L2_cache_hit_way