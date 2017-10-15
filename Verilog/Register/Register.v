// Register for the FRANK6000 processor

module Register #(parameter WIDTH=8) (
    input      [WIDTH-1:0] i_D,
    input                  i_clk, i_rst, i_we,
    output reg [WIDTH-1:0] or_Q);
    
    always @(posedge i_clk, posedge i_rst) begin
        if (i_rst)     or_Q <= 'b0;
        else if (i_we) or_Q <= i_D;
    end

endmodule
