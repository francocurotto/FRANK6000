// RAM for the FRANK6000 processor

`ifndef _RAM_v_
`define _RAM_v_

module RAM #(
    parameter ADDR_WIDTH  = 8,
    parameter DATA_WIDTH  = 8) (
    input      [ADDR_WIDTH-1:0] i_addr,    
    input      [DATA_WIDTH-1:0] i_data,
    input                       i_clk, i_we, i_re,
    output reg [DATA_WIDTH-1:0] or_data);
    
    reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];

    always @(posedge i_clk) begin
        if (i_we) mem[i_addr] <= i_data;
        if (i_re) or_data = mem[i_addr];
    end

endmodule

`endif
