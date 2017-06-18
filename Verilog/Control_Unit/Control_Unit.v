// Control Unit for the FRANK5000 processor
`ifndef _Control_Unit_macro_v_
`define _Control_Unit_macro_v_
`include "Control_Unit_macro.v"
`endif

module Control_Unit(
    input  [3:0] control_input,
    output       jump,
    output [1:0] j_mode,
    output       call,
    output       return,
    output       ADDRin,
    output       FRin,
    output [1:0] WREGin,
    output       ALUin1,
    output       ALUin2,
    output       ADDRw,
    output       FRw,
    output       WREGw,
    output       STATUSw);

    reg [14:0] r_control_bus;

    always @* begin
        case (control_input)
            `CPYWA     : r_control_bus = 15'b001000000001000;
            `CPYAW     : r_control_bus = 15'b001000011000010;
            `CPYWR     : r_control_bus = 15'b001000100000100;
            `CPYRW     : r_control_bus = 15'b001000110000010;
            `CPYWP     : r_control_bus = 15'b001000000000100;
            `CPYPW_IMM : r_control_bus = 15'b001000001000010;
            `CPYPW_FLR : r_control_bus = 15'b001000010000010;
            `R0_Type_A : r_control_bus = 15'b001001000101001;
            `R2_IMM_BT : r_control_bus = 15'b001000000000011;
            `R2_FLR    : r_control_bus = 15'b001000000010011;
            `GOTO_jump : r_control_bus = 15'b110000000000000;
            `CALLS     : r_control_bus = 15'b110100000000000;
            `RETRN     : r_control_bus = 15'b011010000000000;
            `LOOPF     : r_control_bus = 15'b000000000000000;
            default    : r_control_bus = 15'b000000000000000;
        endcase
    end

    assign jump    = r_control_bus[14];
    assign j_mode  = r_control_bus[13:12];
    assign call    = r_control_bus[11];
    assign return  = r_control_bus[10];
    assign ADDRin  = r_control_bus[9];
    assign FRin    = r_control_bus[8];
    assign WREGin  = r_control_bus[7:6];
    assign ALUin1  = r_control_bus[5];
    assign ALUin2  = r_control_bus[4];
    assign ADDRw   = r_control_bus[3];
    assign FRw     = r_control_bus[2];
    assign WREGw   = r_control_bus[1];
    assign STATUSw = r_control_bus[0];

endmodule
