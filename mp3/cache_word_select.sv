module cache_word_select
(
    input [4:0] offset,
    input [255:0] in,
    output logic [31:0] out
);

always_comb begin
    case(offset[4:2])
        3'b000: out = in[31:0];
        3'b001: out = in[63:32];
        3'b010: out = in[95:64];
        3'b011: out = in[127:96];
        3'b100: out = in[159:128];
        3'b101: out = in[191:160];
        3'b110: out = in[223:192];
        3'b111: out = in[255:224];
    endcase
    case(offset[1:0])
        2'b00: out = out;
        2'b01: out = out >> 8;
        2'b10: out = out >> 16;
        2'b11: out = out >> 24;
    endcase
end

endmodule : cache_word_select
