// Debounce Switch for the FRANK6000 processor

module Debounce_Switch (
    input  i_clk,
    output i_switch,
    output o_switch);
     
    parameter DEBOUNCE_LIMIT = 250000; // 10 ms at 25 MHz
    
    reg        r_state = 1'b0;
    reg [17:0] r_count = 0;
    
    always @(posedge i_clk) begin
        if (i_switch !== r_state && r_count < DEBOUNCE_LIMIT) begin
            r_count <= r_count + 1;
        end
        else if (r_count == DEBOUNCE_LIMIT) begin
            r_count <= 0;
            r_state <= i_switch;
        end
        else  r_count <= 0;
    end
    
    assign o_switch = r_state;
    
endmodule 
