module cache_control
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
    
    input hit,
    input hitA,
    
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
    write_back,
    read_from_pmem
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
    mem_resp = 0;
    pmem_read = 0;
    pmem_write = 0;
    
    unique case(state)
        ready: begin
            if(mem_read == 1'b1 && hit == 1'b1) begin // read hit
                mem_resp = 1'b1;
                // set LRU
                lru_in = hitA;
                lru_W = 1'b1;
            end else if(mem_write == 1'b1 && hit == 1'b1) begin // write hit
                mem_resp = 1'b1;
                data_in_mux_sel = 1'b0;
                // pick which array to write
                dataA_W = hitA;
                dataB_W = ~hitA;
                // set dirty bit
                dirtyA_in = 1'b1;
                dirtyB_in = 1'b1;
                dirtyA_W = hitA;
                dirtyB_W = ~hitA;
                // set LRU
                lru_in = hitA;
                lru_W = 1'b1;
            end else if(mem_read == 1'b0 && mem_write == 1'b0) begin // Nothing happen
                mem_resp = 1'b0;
            end
        end
        write_back: begin
            if(lru_out == 1'b0)
                pmem_addr_mux_sel = 2'b01;
            else
                pmem_addr_mux_sel = 2'b10;
            pmem_write = 1'b1;
        end
        read_from_pmem: begin
            // set address for pmem
            pmem_addr_mux_sel = 2'b00;
            pmem_read = 1'b1;
            data_in_mux_sel = 1'b1;
            if(pmem_resp == 1'b1) begin
                // set array write
                dataA_W = ~lru_out;
                dataB_W = lru_out;
                tagA_W = ~lru_out;
                tagB_W = lru_out;
                validA_W = ~lru_out;
                validB_W = lru_out;
                dirtyA_in = 1'b0;
                dirtyB_in = 1'b0;
                dirtyA_W = ~lru_out;
                dirtyB_W = lru_out;
                lru_in = ~lru_out;
                lru_W = 1'b1;
            end
        end
    endcase
end



always_comb begin : next_state_logic
    next_state = state;
    unique case(state)
        ready: begin
            if((mem_read == 1'b1 || mem_write == 1'b1) && hit == 1'b0) begin // miss
                if(lru_out == 1'b0 && dirtyA_out == 1'b1) begin
                    next_state = write_back;
                end else if(lru_out == 1'b1 && dirtyB_out == 1'b1) begin
                    next_state = write_back;
                end else begin
                    next_state = read_from_pmem;
                end
            end
        end
        write_back: begin
            if(pmem_resp == 1'b1) begin
                next_state = read_from_pmem;
            end
        end
        read_from_pmem: begin
            if(pmem_resp == 1'b1) begin
                next_state = ready;
            end
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= next_state;
end

endmodule : cache_control

