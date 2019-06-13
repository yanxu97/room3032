module pc_register #(parameter width = 32)
(
    input clk,
    input [width-1:0] a,
    input [width-1:0] b,
    input [width-1:0] c,
    input [width-1:0] d,
    input [width-1:0] e,
    input [width-1:0] f,
    input branch,
    input predict_taken,
    input btb_jump,
    input EX_branch_mispredict,
    input jal,
    input jalr,
    input enable,
    output logic [width-1:0] out
);

logic [width-1:0] data;
logic [width-1:0] data_in;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial
begin
    data = 32'h00000060;
end

always_ff @(posedge clk)
begin
    data = data_in;
end

always_comb
begin
    out = data;
    data_in = b;
    if (EX_branch_mispredict) begin
        if (branch | jal) data_in = c;
        else if (jalr) data_in = d;
        else data_in = f; // (EX_br_en == 0 && EX_branch_mispredict == 1)
    end else if (predict_taken) begin
        data_in = e; // Will be changed either with logic on the outside later, but just take BTB value if valid
    end
     
     // enable here has the highest priority
    if(enable == 1'b0) begin
        data_in = a;
    end 
     
end

endmodule : pc_register

