module mux4 #(parameter width = 32)
(
    input [1:0] sel,
    input [width-1:0] a, b, c, d,
    output logic [width-1:0] out
);

always_comb begin
    case(sel)
        2'b00: out = a;
        2'b01: out = b;
        2'b10: out = c;
        2'b11: out = d;
    endcase
end

endmodule : mux4
