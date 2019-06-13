module L2_cache_control
(
    input clk,
    
	output logic data_w,
	output logic tag_w,
	output logic valid_w,
	output logic dirty_w,
	
    output logic dirty_in,
    output logic lru_W,

    input dirtyA_out,
    input dirtyB_out,
	input dirtyC_out,
	input dirtyD_out,
    input [1:0] update_cache_out,
	
    output logic data_in_mux_sel,
    output logic update_cache_sel, // newly added and be careful
	output logic real_pmem_addr_mux_sel,

    input hit,
    
    // Memory signals
    input mem_read,
    input mem_write,
    output logic mem_resp,
    output logic pmem_read,
    output logic pmem_write,
    input pmem_resp
);

enum int unsigned {
    // List of states
    ready,
    R_write_back,
    R_read_from_pmem,
    W_write_back
} state, next_state;

// Calculate if the LRU is dirty
// If LRU is dirty, then we have to write the data back to pmem, then overwrite the whole cache block
// Otherwise we can immediately overwrite the LRU cache block
logic write_dirty;
always_comb begin
//    if(lru_out[0] == 1 && lru_out[1] == 1 && dirtyA_out == 1) begin
//        write_dirty = 1;
//    end else if(lru_out[0] == 1 && lru_out[1] == 0 && dirtyB_out == 1) begin
//        write_dirty = 1;
//	end else if(lru_out[0] == 0 && lru_out[2] == 1 && dirtyC_out == 1) begin
//		write_dirty = 1;
//	end else if(lru_out[0] == 0 && lru_out[2] == 0 && dirtyD_out == 1) begin
//		write_dirty = 1;
	if(update_cache_out == 2'b00 && dirtyA_out == 1) begin
		write_dirty = 1;
	end else if(update_cache_out == 2'b01 && dirtyB_out == 1) begin	
		write_dirty = 1;
	end else if(update_cache_out == 2'b10 && dirtyC_out == 1) begin	
		write_dirty = 1;
	end else if(update_cache_out == 2'b11 && dirtyD_out == 1) begin	
		write_dirty = 1;
    end else begin
        write_dirty = 0;
    end
end

always_comb begin : state_actions
	data_w = 0;
	tag_w = 0;
	valid_w = 0;
	dirty_w = 0;
	
	dirty_in = 0;

    lru_W = 0;
    data_in_mux_sel = 0;
    mem_resp = 0;
    pmem_read = 0;
    pmem_write = 0;
	real_pmem_addr_mux_sel = 0;
	//not sure 
    update_cache_sel = 0; 
    unique case(state)
        ready: begin
            if(mem_read == 1 && hit == 1) begin // read hit
                mem_resp = 1;
                // set LRU
                lru_W = 1;
            end else if(mem_write == 1) begin // write
                if(hit == 1) begin // Hit write
                    mem_resp = 1;
                    data_in_mux_sel = 0;
                    // pick which array to write
                    data_w = 1'b1;
					update_cache_sel = 1;
                    // set dirty bit
                    dirty_in = 1;
                    dirty_w = 1;
                    // set LRU
                    lru_W = 1;
                end else if(write_dirty == 0) begin // Miss but not LRU not dirty
                    mem_resp = 1;
                    data_in_mux_sel = 0;
                    // pick which array to write
                    data_w = 1;
					tag_w = 1;
					valid_w = 1;
                    // set dirty bit
                    dirty_in = 1;
                    dirty_w = 1;
                    // set LRU
                    lru_W = 1;
                end
            end
        end
        R_write_back: begin
//          if(update_cache_out == 2'b00)
//                pmem_addr_mux_sel = 3'b001;
//			else if(update_cache_out == 2'b01)
//                pmem_addr_mux_sel = 3'b010;
//			else if(update_cache_out == 2'b10)
//                pmem_addr_mux_sel = 3'b011;
//			else if(update_cache_out = 2'b11)
//				pmem_addr_mux_sel = 3'b100;
			real_pmem_addr_mux_sel = 1;
            pmem_write = 1;
        end
        R_read_from_pmem: begin
            // set address for pmem
            pmem_read = 1;
            data_in_mux_sel = 1;
            if(pmem_resp == 1) begin
                // set array write
                data_w = 1;
                tag_w = 1;
                valid_w = 1;
                dirty_in = 0;
				dirty_w = 1;
                lru_W = 1;
            end
        end
        W_write_back: begin
//            if(lru_out == 0)
//                pmem_addr_mux_sel = 3'b001;	input real_pmem_addr_mux_sel;

//            else
//                pmem_addr_mux_sel = 3'b010;
            pmem_write = 1;
			real_pmem_addr_mux_sel = 1;
            if(pmem_resp == 1) begin
                dirty_in = 0;
                dirty_w = 1;
            end
        end
    endcase
end



always_comb begin : next_state_logic
    next_state = state;
    unique case(state)
        ready: begin
            if(mem_read == 1 && hit == 0) begin // read miss
//                if(lru_out == 0 && dirtyA_out == 1)
//                    next_state = R_write_back;
//                else if(lru_out == 1 && dirtyB_out == 1)
//                    next_state = R_write_back;
				if (write_dirty == 1)
					next_state = R_write_back;
                else
                    next_state = R_read_from_pmem;
            end else if(mem_write == 1 && hit == 0 && write_dirty == 1) // write miss and LRU dirty
                next_state = W_write_back;
        end
        R_write_back: begin
            if(pmem_resp == 1)
                next_state = R_read_from_pmem;
        end
        R_read_from_pmem: begin
            if(pmem_resp == 1)
                next_state = ready;
        end
        W_write_back: begin
            if(pmem_resp == 1)
                next_state = ready;
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

endmodule : L2_cache_control
