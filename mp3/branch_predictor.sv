module branch_predictor
(
    input clk,
    
    // Signals for updating new branch info
    input new_branch_enable,
    input branch_result, // T/NT
    input [7:0] prev_hist_table_idx,
    input [1:0] prev_lbht_result,
    
    
    // Signals for output result
    input [7:0] pc_9_2,
    output [7:0] hist_table_idx_out,
    output logic [1:0] lbht_result
);

logic [7:0] gbhr_out;
logic [1:0] lbht_in;

shift_reg gbhr
(
    .clk(clk),
    .enable(new_branch_enable),
    .in(branch_result),
    .out(gbhr_out)
);

assign hist_table_idx_out = gbhr_out ^ pc_9_2;

array_rw lbht
(
    .clk(clk),
    .write(new_branch_enable),
    .index(hist_table_idx_out),
    .write_idx(prev_hist_table_idx),
    .datain(lbht_in),
    .dataout(lbht_result)
);

always_comb begin
    if(branch_result)
        lbht_in = prev_lbht_result + 2'b01;
    else
        lbht_in = prev_lbht_result + 2'b11;
    if(branch_result == 1 && prev_lbht_result == 2'b11)
        lbht_in = 2'b11;
    if(branch_result == 0 && prev_lbht_result == 2'b00)
        lbht_in = 2'b00;
end

endmodule : branch_predictor
