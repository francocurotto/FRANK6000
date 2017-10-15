// Arithmetic Logic Unit for the FRANK6000 processor
`ifndef _ALU_macro_v_
`define _ALU_macro_v_
`include "ALU_macro.v"
`endif

module ALU (
    input  [3:0] i_opcode,
    input  [7:0] i_oper1, i_oper2,
    output [7:0] o_res,
    output [2:0] o_status);

    // o_status[0]: Zero flag
    // o_status[1]: Negative flag
    // o_status[2]: Carry out flag

    reg [7:0] r_res;
    reg       r_carry;

    always @* begin
        case (i_opcode)
            `ZEROW  : begin r_res <= 8'd0;                   r_carry <= 1'b0; end
            `BNOTW  : begin r_res <= ~i_oper1;               r_carry <= 1'b0; end
            `NEGTW  : begin r_res <= -i_oper1;               r_carry <= 1'b0; end
            `INCRW  : begin r_res <= i_oper1 + 8'd1;         r_carry <= 1'b0; end
            `DECRW  : begin r_res <= i_oper1 - 8'd1;         r_carry <= 1'b0; end
            `ANDWP  : begin r_res <= i_oper1 & i_oper2;      r_carry <= 1'b0; end
            `IORWP  : begin r_res <= i_oper1 | i_oper2;      r_carry <= 1'b0; end
            `XORWP  : begin r_res <= i_oper1 ^ i_oper2;      r_carry <= 1'b0; end 
            `ADDWP  : {r_carry, r_res} <= i_oper1 + i_oper2;
            `SUBWP  : {r_carry, r_res} <= i_oper1 - i_oper2;
            `CMPWP  : begin 
                           r_res   <= i_oper1 < i_oper2 ? -8'd1 : 
                                      i_oper1 > i_oper2 ?  8'd1 : 8'd0;
                           r_carry <= 1'b0;
                      end
            `SHFLW  : begin r_res <= i_oper1 << i_oper2[2:0]; r_carry <= 1'b0; end
            `SHFRW  : begin r_res <= i_oper1 >> i_oper2[2:0]; r_carry <= 1'b0; end
            default : begin r_res <= 8'd0;                    r_carry <= 1'b0; end 
        endcase
    end

    assign o_res = r_res;
    assign o_status[0] = ~|o_res;
    assign o_status[1] = o_res[7];
    assign o_status[2] = r_carry;

endmodule
