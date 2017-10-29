// Pulse Generator for the FRANK6000 processor

module Pulse_Gen #(parameter WIDTH=24) (
    input  i_clk, i_rst, i_en,
    output o_pulse);

    reg [WIDTH-1:0] r_counter = 'b0;

    always @(posedge i_clk, posedge i_rst) begin
        if (i_rst)     r_counter = 'b0;
        else if (i_en) r_counter = r_counter + 'b1;
    end

    assign o_pulse = &r_counter;

endmodule
