module arbiter_control
(
    input clk,
    
    /* Input signals to arbiter control */
    input L2_resp, 
    input dmem_read, 
    input dmem_write, 
    input imem_read,
    
    /* Port B */
    output logic resp_to_dmem, 
    output logic resp_to_imem,
    output logic L2_read, 
    output logic L2_write, 
    output logic serving_data
);

enum int unsigned {
    // List of states
    idle,
    serve_inst, 
    serve_data
} state, next_state;


always_comb begin : state_actions
    resp_to_dmem = 0;
    resp_to_imem = 0;
    L2_read = 0;
    L2_write = 0;
    serving_data = 0;
    
    unique case(state)
        idle: begin
            // Simply placing this here to have something to write.
            serving_data = 0; 
        end
        serve_inst: begin
            // Set the read signal to high. 
            // Is only read, since the instruction cache only has read abilities. 
            L2_read = imem_read;
            if(L2_resp == 1'b1) begin
                // set response to the instruction cache
                resp_to_imem = 1'b1;
            end 
        end
        serve_data: begin
            serving_data = 1'b1;
            L2_read = dmem_read; 
            L2_write = dmem_write;          
            if(L2_resp == 1'b1) begin
                // set response to the instruction cache
                resp_to_dmem = 1'b1;
            end
        end
    endcase
end



always_comb begin : next_state_logic
    next_state = state;
    unique case(state)
        idle: begin
            // Please do not confuse these signals with the ones that are given to the L1 caches! 
            // These are output by the L1 caches instead when there is a miss. 
            // The arbiter itself does not check if a miss happens. 
            // Realistically, in the memory hierarchy, dmem_read will route to something like dmem_read_from_L2. 
            if (dmem_read || dmem_write) next_state = serve_data;
            else if(imem_read) next_state = serve_inst;
        end
        serve_inst: begin
            if(L2_resp && (dmem_read || dmem_write)) next_state = serve_data;
            else if (L2_resp) next_state = idle;
        end
        serve_data: begin 
            if(L2_resp && imem_read) next_state = serve_inst;
            else if (L2_resp) next_state = idle;
        end
    endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    state <= next_state;
end

endmodule : arbiter_control
