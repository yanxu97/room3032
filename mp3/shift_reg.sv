module shift_reg #(parameter width = 8)
(
    input clk,
    input enable,
    input in,
    output logic [width-1:0] out
);

logic [width-1:0] out_in;

/* Altera device registers are 0 at power on. Specify this
 * so that Modelsim works as expected.
 */
initial begin
    out = 0;
end

always_ff @(posedge clk) begin
    out = out_in;
end

always_comb
begin
    out_in = out;
    if(enable)
        out_in = {in,out[width-1:1]};
end

endmodule : shift_reg
