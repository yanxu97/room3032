
module array_rw #(parameter width = 2)
(
    input clk,
    input write,
    input [7:0] index,
    input [7:0] write_idx,
    input [width-1:0] datain,
    output logic [width-1:0] dataout
);

logic [width-1:0] data [255:0] /* synthesis ramstyle = "logic" */;

/* Initialize array */
initial
begin
    for (int i = 0; i < $size(data); i+=2)
    begin
        data[i] = 0;
    end
	 for (int i = 1; i < $size(data); i+=2)
    begin
        data[i] = 1;
    end
end

always_ff @(posedge clk)
begin
    if (write == 1)
    begin
        data[write_idx] = datain;
    end
end

assign dataout = data[index];

endmodule : array_rw

