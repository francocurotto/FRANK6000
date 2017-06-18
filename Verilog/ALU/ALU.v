// Arithmetic logic unit for the FRANK5000 processor
`ifndef _ALU_macro_v_
`define _ALU_macro_v_
`include "ALU_macro.v"
`endif

module ALU (
    input  [3:0] opcode,
    input  [7:0] WREG, p,
    output [7:0] res,
    output [2:0] status);

    // status[0]: Zero flag
    // status[1]: Negative flag
    // status[2]: Carry out flag

    reg [7:0] r_res;
    reg       r_carry;

    always @* begin
        case (opcode)
            `ZEROW  : begin r_res <= 8'd0;           r_carry <= 1'b0; end
            `BNOTW  : begin r_res <= ~WREG;          r_carry <= 1'b0; end
            `NEGTW  : begin r_res <= -WREG;          r_carry <= 1'b0; end
            `INCRW  : begin r_res <= WREG + 8'd1;    r_carry <= 1'b0; end
            `DECRW  : begin r_res <= WREG - 8'd1;    r_carry <= 1'b0; end
            `ANDWP  : begin r_res <= WREG & p;       r_carry <= 1'b0; end
            `IORWP  : begin r_res <= WREG | p;       r_carry <= 1'b0; end
            `XORWP  : begin r_res <= WREG ^ p;       r_carry <= 1'b0; end 
            `ADDWP  : {r_carry, r_res} <= WREG + p;
            `SUBWP  : {r_carry, r_res} <= WREG - p;
            `CMPWP  : begin 
                           r_res   <= WREG < p ? -8'd1 : 
                                      WREG > p ?  8'd1 : 8'd0;
                           r_carry <= 1'b0;
                       end
            `SHFLW  : begin r_res <= WREG << p[2:0]; r_carry <= 1'b0; end
            `SHFRW  : begin r_res <= WREG >> p[2:0]; r_carry <= 1'b0; end
            default : begin r_res <= 8'd0;           r_carry <= 1'b0; end 
        endcase
    end

    assign res = r_res;
    assign status[0] = ~|res;
    assign status[1] = res[7];
    assign status[2] = r_carry;

endmodule
