
module L2_cache_replacement_decision
(
	input [2:0] lru_out,
	output logic [1:0] replaced_out
);

always_comb
begin
// Pseudo LRU Algorithm from lecture 05
// https://courses.engr.illinois.edu/ece411/fa2018/secure/lectures/no_annotation/lect05.pdf
	replaced_out = 2'b00;
	if (lru_out[1] == 1 && lru_out[0] == 1)
		replaced_out = 2'b00;
	else if (lru_out[1] == 0 && lru_out[0] == 1)
		replaced_out = 2'b01;
	else if (lru_out[2] == 1 && lru_out[0] == 0)
		replaced_out = 2'b10;
	else if (lru_out[2] == 0 && lru_out[0] == 0)
		replaced_out = 2'b11;
end

endmodule: L2_cache_replacement_decision