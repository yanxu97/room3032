module counter #(parameter width = 32)
(
    input clk,
    input enable,
    input clear,
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
        out_in = out + 1;
    if(clear)
        out_in = 0;
end

endmodule : counter
