// Instr_RX testbench
// It sends out instruction 0xAB37 (divided in two UART messages,
// 0x37 and 0xAB), and ensures the RX receives it correctly.
`timescale 1ns/10ps
`include "Instr_RX.v"

module instr_RX_tb();

    // Testbench uses a 25 MHz clock (same as Go Board)
    // Want to interface to 115200 baud UART
    // 25000000 / 115200 = 217 Clocks Per Bit.
    parameter CLOCK_PERIOD_NS = 40;
    parameter CLKS_PER_BIT    = 217;
    parameter BIT_PERIOD      = 8600;
  
    reg         r_rx_serial = 1;
    reg         r_clk       = 0;
    wire [15:0] w_rx_instr;
  
    // takes in input byte and serializes it 
    task UART_WRITE_BYTE;
        input [7:0] i_data;
        integer     ii;
        begin 
            // send start bit
            r_rx_serial <= 1'b0;
            #(BIT_PERIOD);
            #1000;
      
            // send data byte
            for (ii=0; ii<8; ii=ii+1) begin
                r_rx_serial <= i_data[ii];
                #(BIT_PERIOD);
            end
      
            // send stop bit
            r_rx_serial <= 1'b1;
            #(BIT_PERIOD);
        end
    endtask 

    Instr_RX #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX_INST (
        .i_clk(r_clk),
        .i_rx_serial(r_rx_serial),
        .o_rx_instr(w_rx_instr),
        .o_rx_dv());
  
    always #(CLOCK_PERIOD_NS/2) r_clk <= !r_clk;
    
    // main testing
    initial begin
        // send a command to the UART (exercise Rx)
        @(posedge r_clk);
        UART_WRITE_BYTE(8'h37);
        @(posedge r_clk);
        #(BIT_PERIOD*10);
        @(posedge r_clk);
        UART_WRITE_BYTE(8'hAB);
        @(posedge r_clk);
            
        // check that the correct command was received
        if (w_rx_instr == 16'hAB37) $display("Test Passed - Correct Instruction Received");
        else $display("Test Failed - Incorrect Instruction Received");
        $finish();
    end
  
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
  
endmodule

