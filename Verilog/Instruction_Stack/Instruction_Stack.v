// Instruction Stack for FRANK6000 processor
`include "../RAM/RAM.v"

module Instruction_Stack #(
    parameter ADDR_WIDTH  = 4,
    parameter DATA_WIDTH  = 8) (
    input  [DATA_WIDTH-1:0] i_PC,
    input                   i_call, i_rtrn, i_clk, i_rst,
    output [DATA_WIDTH-1:0] o_stack);

    reg [ADDR_WIDTH-1:0] r_stack_pointer; 

    wire [DATA_WIDTH-1:0] w_stack_in;
    wire [ADDR_WIDTH-1:0] w_stack_addr;

    assign w_stack_in   = i_PC + 'b1;
    assign w_stack_addr = i_call? r_stack_pointer :      // if call is used
                                  r_stack_pointer - 'b1; // if rtrn is used

    RAM #(
        .ADDR_WIDTH (ADDR_WIDTH), 
        .DATA_WIDTH (DATA_WIDTH)) Stack_RAM (
            .i_addr  (w_stack_addr), 
            .i_data  (w_stack_in), 
            .i_clk   (i_clk), 
            .i_we    (i_call), 
            .i_re    (i_rtrn),
            .or_data (o_stack));

    always @(posedge i_clk, posedge i_rst) begin
        if (i_rst) r_stack_pointer = 'b0;
        
        else begin // clock posedge with rst=0
            if      (i_call) r_stack_pointer = r_stack_pointer + 'b1;
            else if (i_rtrn) r_stack_pointer = r_stack_pointer - 'b1;
        end
    end

endmodule
