module eviction_write_buffer
(
    input clk,
    
    input [31:0] L2_addr,
    output logic [31:0] pmem_addr,
    
    input [255:0] L2_wdata,
    output logic [255:0] pmem_wdata,
    
    input L2_read,
    input L2_write,
    output logic pmem_read,
    output logic pmem_write,
    
    input pmem_resp,
    output logic L2_resp
);

logic addr_mux_sel;
logic load_reg;
logic [31:0] addr_reg_out;

enum int unsigned {
    idle,
    write_into_EWB, 
    fulfill_read,
    write_back,
    serve_read
} state, next_state;


always_comb begin : state_actions
    addr_mux_sel = 0;
    load_reg = 0;
    L2_resp = 0;
    pmem_read = 0;
    pmem_write = 0;
    
    unique case(state)
        idle: begin
            
        end
        write_into_EWB: begin
            load_reg = 1;
            L2_resp = 1;
        end
        fulfill_read: begin
            if(L2_read == 1)
                pmem_read = 1;
            addr_mux_sel = 1;
            if(pmem_resp == 1)
                L2_resp = 1;
        end
        write_back: begin
            pmem_write = 1;
            addr_mux_sel = 0;
        end
        serve_read: begin
            pmem_read = 1;
            addr_mux_sel = 1;
            L2_resp = pmem_resp;
        end
    endcase
end


always_comb begin : next_state_logic
    next_state = state;
    unique case(state)
        idle: begin
            if(L2_read == 1)
                next_state = serve_read;
            else if(L2_write == 1)
                next_state = write_into_EWB;
        end
        write_into_EWB: begin
            next_state = fulfill_read;
        end
        fulfill_read: begin
            if(pmem_resp == 1)
                next_state = write_back;
        end
        write_back: begin
            if(pmem_resp == 1)
                next_state = idle;
        end
        serve_read: begin
            if(pmem_resp == 1)
                next_state = idle;
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

register addr_reg
(
    .clk(clk),
    .load(load_reg),
    .in(L2_addr),
    .out(addr_reg_out)
);

register #(256) data_reg
(
    .clk(clk),
    .load(load_reg),
    .in(L2_wdata),
    .out(pmem_wdata)
);

mux2 addr_mux
(
    .sel(addr_mux_sel),
    .a(addr_reg_out),
    .b(L2_addr),
    .f(pmem_addr)
);

endmodule : eviction_write_buffer
