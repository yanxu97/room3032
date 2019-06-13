
module L2_cache_lru_hit_update
(
	input hit,
	input [1:0] hitway,
	input [2:0] lru_out,
	output logic [2:0] lru_update
);

// LRU update algorithm
// https://courses.engr.illinois.edu/ece411/fa2018/secure/lectures/no_annotation/lect05.pdf

always_comb
begin
	lru_update = lru_out;
	if (hit == 1)
	begin
		case(hitway)
			2'b00:
			begin
				lru_update[0] = 0;
				lru_update[1] = 0;
			end
			2'b01:
			begin
				lru_update[0] = 0;
				lru_update[1] = 1;
			end
			2'b10:
			begin
				lru_update[0] = 1;
				lru_update[2] = 0;
			end
			2'b11:
			begin
				lru_update[0] = 1;
				lru_update[2] = 1;
			end
		endcase
	end
end

endmodule : L2_cache_lru_hit_update