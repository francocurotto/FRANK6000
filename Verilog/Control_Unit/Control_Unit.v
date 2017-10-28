// Control Unit for the FRANK6000 processor
`ifndef _Control_Unit_macro_v_
`define _Control_Unit_macro_v_
`include "Control_Unit_macro.v"
`endif

module Control_Unit (
    input  [3:0] i_control_input,
    input        i_clk, i_rst, i_en,
    output       o_jump,
    output [1:0] o_j_mode,
    output       o_call,
    output       o_return,
    output       o_ADDRin,
    output       o_FRin,
    output [1:0] o_WREGin,
    output       o_ALUin1,
    output       o_ALUin2,
    output       o_PCw,
    output       o_ADDRw,
    output       o_FRw,
    output       o_WREGw,
    output       o_STATUSw);
    
    reg  [1:0] r_state;
    reg [15:0] r_control_bus;

    // next state logic
    always @(posedge i_clk, posedge i_rst) begin
        if (i_rst) r_state <= `CYCLE2_INSTR;
        else if (i_en) begin
            case (r_state)
                `INSTR_FETCH  : r_state <= `CYCLE1_INSTR;
                `CYCLE1_INSTR : begin
                    if (i_control_input == `CPYRW | 
                        i_control_input == `CPYPW_FLR | 
                        i_control_input == `R2_FLR | 
                        i_control_input == `RETRN) begin
                            r_state <= `CYCLE2_INSTR;
                    end
                    else r_state <= `INSTR_FETCH;
                end
                `CYCLE2_INSTR : r_state <= `INSTR_FETCH;
            endcase
        end
    end
    
    // output logic
    always @(i_en, r_state, i_control_input) begin
        if (i_en) begin
            case (r_state)
                `INSTR_FETCH  :
                    case (i_control_input)
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
                    case (i_control_input)
                        `CPYRW     : r_control_bus = 16'b0000_0001_0001_0010;
                        `CPYPW_FLR : r_control_bus = 16'b0000_0001_0001_0010;
                        `R2_FLR    : r_control_bus = 16'b0000_0000_0011_0011;
                        `RETRN     : r_control_bus = 16'b0100_0000_0001_0000;
                        default    : r_control_bus = 16'b0000_0000_0000_0000;
                    endcase
                `CYCLE2_INSTR : r_control_bus = 16'b0000_0000_0000_0000;
            endcase
        end
        else r_control_bus = 16'b0;
    end

    assign o_jump    = r_control_bus[15];
    assign o_j_mode  = r_control_bus[14:13];
    assign o_call    = r_control_bus[12];
    assign o_return  = r_control_bus[11];
    assign o_ADDRin  = r_control_bus[10];
    assign o_FRin    = r_control_bus[9];
    assign o_WREGin  = r_control_bus[8:7];
    assign o_ALUin1  = r_control_bus[6];
    assign o_ALUin2  = r_control_bus[5];
    assign o_PCw     = r_control_bus[4];
    assign o_ADDRw   = r_control_bus[3];
    assign o_FRw     = r_control_bus[2];
    assign o_WREGw   = r_control_bus[1];
    assign o_STATUSw = r_control_bus[0];

endmodule
