// Regiter for FRANK5000 processor
`include "../edge_macro.v"

module Register #(
    parameter width=8,
    parameter active_edge=`POS_EDGE) (
    input      [width-1:0] D,
    input                  clk, rst, we,
    output reg [width-1:0] Q);
    
    wire local_clk = (active_edge==`POS_EDGE)? clk : !clk;

    always @(posedge local_clk, posedge rst) begin
        if (rst) Q <= 'b0;
        else if (we) Q <= D;
    end

endmodule
