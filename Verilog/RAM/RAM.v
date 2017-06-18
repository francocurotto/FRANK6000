// RAM for FRANK5000 processor
`include "../edge_macro.v"

`ifndef _RAM_v_
`define _RAM_v_

module RAM #(
    parameter addr_width  = 8,
    parameter data_width  = 8,
    parameter active_edge = `POS_EDGE) (
    input      [addr_width-1:0] addr,    
    input      [data_width-1:0] din,
    input                       clk, we,
    output reg [data_width-1:0] dout);
    
    reg [data_width-1:0] mem [(1<<addr_width)-1:0];

    wire local_clk = (active_edge==`POS_EDGE)? clk : !clk;

    always @(posedge local_clk) begin
        if (we) mem[addr] <= din;
        dout = mem[addr];
    end

endmodule

`endif
