// Instruction Stack for FRANK6000 processor
`include "../RAM/RAM.v"

module Instruction_Stack #(
    parameter addr_width  = 4,
    parameter data_width  = 8) (
    input  [data_width-1:0] i_PC,
    input                   call, rtrn, rst, clk,
    output [data_width-1:0] o_Stack);

    reg [addr_width-1:0] SP; // stack pointer

    wire [data_width-1:0] w_stack_in;
    wire [addr_width-1:0] w_stack_addr;

    assign w_stack_in   = i_PC + 'b1;
    assign w_stack_addr = call? SP :      // if call is used
                                SP - 'b1; // if rtrn is used

    RAM #(.addr_width(addr_width), .data_width(data_width))
        Stack_RAM (.addr(w_stack_addr), .din(w_stack_in), .clk(clk), .we(call), .dout(o_Stack));

    always @(posedge clk, posedge rst) begin
        if (rst) SP = 'b0;
        
        else begin // clock posedge with rst=0
            if      (call) SP = SP + 'b1;
            else if (rtrn) SP = SP - 'b1;
        end
    end

endmodule
