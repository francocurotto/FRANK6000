// Control Unit for the FRANK6000 processor
`ifndef _Control_Unit_macro_v_
`define _Control_Unit_macro_v_
`include "Control_Unit_macro.v"
`endif

module Control_Unit(
    input        clk, rst,
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
    output       PCw,
    output       ADDRw,
    output       FRw,
    output       WREGw,
    output       STATUSw);
    
    reg  [1:0] r_unit_state;
    reg [15:0] r_control_bus;

    // next state logic
    always @(posedge clk, posedge rst) begin
        if (rst) r_unit_state = `CYCLE2_INSTR;
        else begin
            case (r_unit_state)
                `INSTR_FETCH  : r_unit_state = `CYCLE1_INSTR;
                `CYCLE1_INSTR : begin
                    if (control_input == `CPYRW | 
                        control_input == `CPYPW_FLR | 
                        control_input == `R2_FLR | 
                        control_input == `RETRN) 
                            r_unit_state = `CYCLE2_INSTR;
                    else
                            r_unit_state = `INSTR_FETCH;
                end
                `CYCLE2_INSTR : r_unit_state = `INSTR_FETCH;
            endcase
        end
    end
    
    // output logic
    always @(control_input, r_unit_state) begin
        case (r_unit_state)
            `INSTR_FETCH  :
                case (control_input)
                    `CPYWA     : r_control_bus = 16'b0000_0000_0001_1000;
                    `CPYAW     : r_control_bus = 16'b0000_0001_1001_0010;
                    `CPYWR     : r_control_bus = 16'b0000_0010_0001_0100;
                    `CPYRW     : r_control_bus = 16'b0000_0010_0000_0000;
                    `NOOPR     : r_control_bus = 16'b0000_0000_0001_0000;
                    `CPYWP     : r_control_bus = 16'b0000_0000_0001_0100;
                    `CPYPW_IMM : r_control_bus = 16'b0000_0000_1001_0010;
                    `CPYPW_FLR : r_control_bus = 16'b0000_0000_0000_0000;
                    `R0_Type_A : r_control_bus = 16'b0000_0100_0101_1001;
                    `R2_IMM_BT : r_control_bus = 16'b0000_0000_0001_0011;
                    `R2_FLR    : r_control_bus = 16'b0000_0000_0000_0000;
                    `GOTO_jump : r_control_bus = 16'b1010_0000_0001_0000;
                    `CALLS     : r_control_bus = 16'b1011_0000_0001_0000;
                    `RETRN     : r_control_bus = 16'b0000_1000_0000_0000;
                    `LOOPF     : r_control_bus = 16'b0000_0000_0000_0000;
                    default    : r_control_bus = 16'b0000_0000_0000_0000;
                endcase
            `CYCLE1_INSTR :
                case (control_input)
                    `CPYRW     : r_control_bus = 16'b0000_0001_0001_0010;
                    `CPYPW_FLR : r_control_bus = 16'b0000_0001_0001_0010;
                    `R2_FLR    : r_control_bus = 16'b0000_0000_0011_0011;
                    `RETRN     : r_control_bus = 16'b0100_0000_0001_0000;
                    default    : r_control_bus = 16'b0000_0000_0000_0000;
                endcase
            `CYCLE2_INSTR : r_control_bus = 16'b0000_0000_0000_0000;
        endcase
    end

    assign jump    = r_control_bus[15];
    assign j_mode  = r_control_bus[14:13];
    assign call    = r_control_bus[12];
    assign return  = r_control_bus[11];
    assign ADDRin  = r_control_bus[10];
    assign FRin    = r_control_bus[9];
    assign WREGin  = r_control_bus[8:7];
    assign ALUin1  = r_control_bus[6];
    assign ALUin2  = r_control_bus[5];
    assign PCw     = r_control_bus[4];
    assign ADDRw   = r_control_bus[3];
    assign FRw     = r_control_bus[2];
    assign WREGw   = r_control_bus[1];
    assign STATUSw = r_control_bus[0];

endmodule
