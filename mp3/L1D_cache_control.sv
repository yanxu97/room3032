module L1D_cache_control
(
    input clk,
    
    output logic dirtyA_in,
    output logic dirtyA_W,
    output logic validA_W,
    output logic tagA_W,
    output logic dataA_W,
    output logic dirtyB_in,
    output logic dirtyB_W,
    output logic validB_W,
    output logic tagB_W,
    output logic dataB_W,
    output logic lru_in,
    output logic lru_W,
    
    input validA_out,
    input validB_out,
    input dirtyA_out,
    input dirtyB_out,
    input lru_out,
    
    output logic data_in_mux_sel,
    output logic [1:0] pmem_addr_mux_sel,
    output logic load_mdr,
    output logic load_pmem_data_out,
    
    input hit,
    input hitA,
    
    // Memory signals
    input mem_read,
    input mem_write,
    output logic mem_resp,
    output logic pmem_read,
    output logic pmem_write,
    input pmem_resp,
    
    // Counter signals
    input L1D_hit_clear,
    input L1D_miss_clear,
    output logic [31:0] L1D_hit_count,
    output logic [31:0] L1D_miss_count
);

enum int unsigned {
    // List of states
    ready,
    write_back_1,
    write_back_2,
    read_from_pmem_1,
    read_from_pmem_2
} state, next_state;


always_comb begin : state_actions
    dirtyA_in = 0;
    dirtyA_W = 0;
    validA_W = 0;
    tagA_W = 0;
    dataA_W = 0;
    dirtyB_in = 0;
    dirtyB_W = 0;
    validB_W = 0;
    tagB_W = 0;
    dataB_W = 0;
    lru_in = 0;
    lru_W = 0;
    data_in_mux_sel = 0;
    pmem_addr_mux_sel = 0;
    load_mdr = 0;
    load_pmem_data_out = 0;
    mem_resp = 0;
    pmem_read = 0;
    pmem_write = 0;
    
    unique case(state)
        ready: begin
            if(mem_read == 1 && hit == 1) begin // read hit
                mem_resp = 1;
                // set LRU
                lru_in = hitA;
                lru_W = 1;
            end else if(mem_write == 1 && hit == 1) begin // write hit
                mem_resp = 1;
                data_in_mux_sel = 0;
                // pick which array to write
                dataA_W = hitA;
                dataB_W = ~hitA;
                // set dirty bit
                dirtyA_in = 1;
                dirtyB_in = 1;
                dirtyA_W = hitA;
                dirtyB_W = ~hitA;
                // set LRU
                lru_in = hitA;
                lru_W = 1;
            end
        end
        write_back_1: begin
            load_pmem_data_out = 1;
        end
        write_back_2: begin
            if(lru_out == 0)
                pmem_addr_mux_sel = 2'b01;
            else
                pmem_addr_mux_sel = 2'b10;
            pmem_write = 1;
        end
        read_from_pmem_1: begin
            // set address for pmem
            pmem_addr_mux_sel = 2'b00;
            pmem_read = 1;
            if(pmem_resp == 1)
                load_mdr = 1;
        end
        read_from_pmem_2: begin
            data_in_mux_sel = 1;
            // set array write
            dataA_W = ~lru_out;
            dataB_W = lru_out;
            tagA_W = ~lru_out;
            tagB_W = lru_out;
            validA_W = ~lru_out;
            validB_W = lru_out;
            dirtyA_in = 0;
            dirtyB_in = 0;
            dirtyA_W = ~lru_out;
            dirtyB_W = lru_out;
            lru_in = ~lru_out;
            lru_W = 1;
        end
    endcase
end



always_comb begin : next_state_logic
    next_state = state;
    unique case(state)
        ready: begin
            if((mem_read == 1 || mem_write == 1) && hit == 0) begin // miss
                if(lru_out == 0 && dirtyA_out == 1) begin
                    next_state = write_back_1;
                end else if(lru_out == 1 && dirtyB_out == 1) begin
                    next_state = write_back_1;
                end else begin
                    next_state = read_from_pmem_1;
                end
            end
        end
        write_back_1: begin
            next_state = write_back_2;
        end
        write_back_2: begin
            if(pmem_resp == 1) begin
                next_state = read_from_pmem_1;
            end
        end
        read_from_pmem_1: begin
            if(pmem_resp == 1) begin
                next_state = read_from_pmem_2;
            end
        end
        read_from_pmem_2: begin
            next_state = ready;
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

counter L1D_hit_reg
(
    .clk(clk),
    .enable((mem_read & hit) | (mem_write & hit)),
    .clear(L1D_hit_clear),
    .out(L1D_hit_count)
);

counter L1D_miss_reg
(
    .clk(clk),
    .enable(state == read_from_pmem_2),
    .clear(L1D_miss_clear),
    .out(L1D_miss_count)
);

endmodule : L1D_cache_control
