// Regiter for FRANK6000 processor

module Register #(parameter width=8) (
    input      [width-1:0] D,
    input                  clk, rst, we,
    output reg [width-1:0] Q);
    
    always @(posedge clk, posedge rst) begin
        if (rst) Q <= 'b0;
        else if (we) Q <= D;
    end

endmodule
