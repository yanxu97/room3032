import rv32i_types::*;

module cmp #(parameter width = 32)
(
    input branch_funct3_t cmpop,
    input [width-1:0] a, b,
    output logic br_en
);

always_comb begin
    case(cmpop)
        beq: begin
            if(a == b)
                br_en = 1'b1;
            else
                br_en = 1'b0;
        end
        bne: begin
            if(a == b)
                br_en = 1'b0;
            else
                br_en = 1'b1;
        end
        blt: begin
            if($signed(a) < $signed(b))
                br_en = 1'b1;
            else
                br_en = 1'b0;
        end
        bge: begin
            if($signed(a) >= $signed(b))
                br_en = 1'b1;
            else
                br_en = 1'b0;
        end
        bltu: begin
            if(a < b)
                br_en = 1'b1;
            else
                br_en = 1'b0;
        end
        bgeu: begin
            if(a >= b)
                br_en = 1'b1;
            else
                br_en = 1'b0;
        end
    endcase
end

endmodule : cmp
