// Instruction Receiver for the FRANK6000 processor
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 25 MHz Clock, 115200 baud UART
// (25000000)/(115200) = 217
 
module Instr_RX #(
    parameter CLKS_PER_BIT = 217) (
    input         clk, rst, i_rx_serial,
    output        o_rx_dv,
    output [15:0] o_rx_instr);
   
    parameter IDLE         = 3'b000;
    parameter RX_START_BIT = 3'b001;
    parameter RX_DATA_BITS = 3'b010;
    parameter RX_STOP_BIT  = 3'b011;
    parameter CLEANUP      = 3'b100;
  
    reg  [7:0] r_clk_count = 0;
    reg  [3:0] r_bit_idx   = 0; // 16 bits total (=2 UART messages)
    reg [15:0] r_rx_instr  = 0;
    reg        r_rx_dv     = 0;
    reg  [2:0] r_state     = 0;
    reg        r_rx_dv2    = 0;
 
    // Purpose: Control RX state machine
    always @(posedge clk) begin
        if (rst) begin
            r_clk_count = 0;
            r_bit_idx   = 0;
            r_rx_instr  = 0;
            r_rx_dv     = 0;
            r_state     = IDLE; 
        end
        else begin
            r_rx_dv2 <= r_rx_dv;
            case (r_state)
                IDLE : begin
                    r_rx_dv     <= 1'b0;
                    r_clk_count <= 0;

                    if (i_rx_serial == 1'b0) r_state <= RX_START_BIT;  // Start bit detected
                    else r_state <= IDLE;
                end // case: IDLE
      
                // Check middle of start bit to make sure it's still low
                RX_START_BIT : begin
                    if (r_clk_count == (CLKS_PER_BIT-1)/2) begin
                        if (i_rx_serial == 1'b0) begin
                            r_clk_count <= 0;  // reset counter, found the middle
                            r_state     <= RX_DATA_BITS;
                        end
                        else r_state <= IDLE;
                    end
                    else begin
                        r_clk_count <= r_clk_count + 1;
                        r_state     <= RX_START_BIT;
                    end
                end // case: RX_START_BIT
      
                // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
                RX_DATA_BITS : begin
                    if (r_clk_count < CLKS_PER_BIT-1) begin
                        r_clk_count <= r_clk_count + 1;
                        r_state     <= RX_DATA_BITS;
                    end
                    else begin
                        r_clk_count           <= 0;
                        r_rx_instr[r_bit_idx] <= i_rx_serial;
            
                        // Check if we have received all bits
                        if (r_bit_idx == 15) begin
                            r_state <= RX_STOP_BIT;
                        end
                        else if (r_bit_idx == 7) begin
                            r_bit_idx <= r_bit_idx + 1;
                            r_state   <= RX_STOP_BIT;
                        end
                        else begin // r_bit_idx !=7 and r_bit_idx < 15
                            r_bit_idx <= r_bit_idx + 1;
                            r_state   <= RX_DATA_BITS;
                        end
                    end
                end // case: RX_DATA_BITS
     
                // Receive Stop bit.  Stop bit = 1
                RX_STOP_BIT : begin
                    // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                    if (r_clk_count < CLKS_PER_BIT-1) begin
                        r_clk_count <= r_clk_count + 1;
     	                r_state     <= RX_STOP_BIT;
                    end
                    else begin
       	                if (r_bit_idx == 15) begin 
                            r_rx_dv   <= 1'b1;
                            r_bit_idx <= 0;
                        end
                        r_clk_count <= 0;
                        r_state     <= CLEANUP;
                    end
                end // case: RX_STOP_BIT
      
                // Stay here 1 clock
                CLEANUP : begin
                    r_state <= IDLE;
                    r_rx_dv <= 1'b0;
                end // case : CLEANUP
      
                default : r_state <= IDLE;
            endcase
        end
    end
  
    assign o_rx_dv    = r_rx_dv;
    assign o_rx_instr = r_rx_instr;
  
endmodule // UART_RX
