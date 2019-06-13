module L1I_cache_control
(
    input clk,
    
    output logic validA_W,
    output logic tagA_W,
    output logic dataA_W,
    output logic validB_W,
    output logic tagB_W,
    output logic dataB_W,
    output logic lru_in,
    output logic lru_W,
    
    output logic load_mdr,
    output logic load_mar,
    output logic addr_mux_sel,
    
    input validA_out,
    input validB_out,
    input lru_out,
    
    input hit,
    input hitA,
    
    // Memory signals
    input mem_read,
    output logic mem_resp,
    output logic pmem_read,
    input pmem_resp,
    
    // Counter signals
    input L1I_hit_clear,
    input L1I_miss_clear,
    output logic [31:0] L1I_hit_count,
    output logic [31:0] L1I_miss_count
);

enum int unsigned {
    // List of states
    ready,
    read_from_pmem_1,
    read_from_pmem_2
} state, next_state;


always_comb begin : state_actions
    validA_W = 0;
    tagA_W = 0;
    dataA_W = 0;
    validB_W = 0;
    tagB_W = 0;
    dataB_W = 0;
    lru_in = 0;
    lru_W = 0;
    load_mdr = 0;
    mem_resp = 0;
    pmem_read = 0;
    load_mar = 0;
    addr_mux_sel = 0;
    
    unique case(state)
        ready: begin
            if(mem_read == 1 && hit == 1) begin // read hit
                mem_resp = 1;
                // set LRU
                lru_in = hitA;
                lru_W = 1;
            end else if(mem_read == 1 && hit == 0) // read miss
                load_mar = 1;
        end
        read_from_pmem_1: begin
            pmem_read = 1;
            addr_mux_sel = 1;
            if(pmem_resp == 1)
                load_mdr = 1;
        end
        read_from_pmem_2: begin
            // set array write
            addr_mux_sel = 1;
            dataA_W = ~lru_out;
            dataB_W = lru_out;
            tagA_W = ~lru_out;
            tagB_W = lru_out;
            validA_W = ~lru_out;
            validB_W = lru_out;
            lru_in = ~lru_out;
            lru_W = 1;
        end
    endcase
end



always_comb begin : next_state_logic
    next_state = state;
    unique case(state)
        ready: begin
            if(mem_read == 1 && hit == 0) // read miss
                next_state = read_from_pmem_1;
        end
        read_from_pmem_1: begin
            if(pmem_resp == 1)
                next_state = read_from_pmem_2;
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

counter L1I_hit_reg
(
    .clk(clk),
    .enable(mem_read == 1 && hit == 1),
    .clear(L1I_hit_clear),
    .out(L1I_hit_count)
);

counter L1I_miss_reg
(
    .clk(clk),
    .enable(dataA_W | dataB_W),
    .clear(L1I_miss_clear),
    .out(L1I_miss_count)
);

endmodule : L1I_cache_control
