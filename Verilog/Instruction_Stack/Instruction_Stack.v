// Instruction Stack for FRANK5000 processor
`include "../edge_macro.v"
`include "../RAM/RAM.v"

module Instruction_Stack #(
    parameter addr_width  = 4,
    parameter data_width  = 8,
    parameter active_edge = `POS_EDGE) (
    input  [data_width-1:0] i_PC,
    input                   call, rtrn, rst, clk,
    output [data_width-1:0] o_Stack);

    reg [addr_width-1:0] SP; // stack pointer

    wire [data_width-1:0] w_stack_in;
    wire [addr_width-1:0] w_stack_addr;

    assign w_stack_in   = i_PC + 'b1;
    assign w_stack_addr = call? SP :      // if call is used
                                SP - 'b1; // if rtrn is used

    RAM #(.addr_width(addr_width), .data_width(data_width), .active_edge(active_edge))
        Stack_RAM (.addr(w_stack_addr), .din(w_stack_in), .clk(clk), .we(call), .dout(o_Stack));


    wire local_clk = (active_edge==`POS_EDGE)? clk : !clk;

    always @(posedge local_clk, posedge rst) begin
        if (rst) SP = 'b0;
        
        else begin // clock posedge with rst=0
            if      (call) SP = SP + 'b1;
            else if (rtrn) SP = SP - 'b1;
        end
    end

endmodule
