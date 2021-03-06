`define _Control_Unit_macro_v_

`define INSTR_SELECT  2'b00
`define INSTR1_CYCLE1 2'b01
`define INSTR2_CYCLE1 2'b10
`define INSTR2_CYCLE2 2'b11

`define LOOPF     4'b0000
`define GOTO_jump 4'b0001
`define CALLS     4'b0010
`define RETRN     4'b0011
`define R2_IMM_BT 4'b0100
`define R2_FLR    4'b0101
`define R0_Type_A 4'b0110
`define NOOPR     4'b0111
`define CPYWA     4'b1000
`define CPYWR     4'b1001

`define CPYWP     4'b1011
`define CPYRW     4'b1100
`define CPYAW     4'b1101
`define CPYPW_IMM 4'b1110
`define CPYPW_FLR 4'b1111
