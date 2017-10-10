module Debounce_Switch(
    input  clk,
    output i_switch,
    output o_switch);
     
    parameter c_DEBOUNCE_LIMIT = 250000; // 10 ms at 25 MHz
    
    reg        r_state = 1'b0;
    reg [17:0] r_count = 0;
    
    always @(posedge clk) begin
        if (i_switch !== r_state && r_count < c_DEBOUNCE_LIMIT)
            r_count <= r_count + 1;
        else if (r_count == c_DEBOUNCE_LIMIT) begin
            r_count <= 0;
            r_state <= i_switch;
        end
        else 
            r_count <= 0;
    end
    
    assign o_switch = r_state;
    
endmodule // Debounce_Switch
