// RAM Testbench
`include "RAM.v"
`include "../Tester/Tester.v"

module RAM_tb;

    reg  [7:0] r_addr;
    reg  [7:0] r_data;
    reg        r_clk   = 1'b0;
    reg        r_we    = 1'b0;
    wire [7:0] w_data;

    reg  [7:0] i;
    
    Tester #(.WIDTH(8)) Tester8();

    RAM #(
        .ADDR_WIDTH (8), 
        .DATA_WIDTH (8)) DUT (
            .i_addr  (r_addr), 
            .i_data  (r_data), 
            .i_clk   (r_clk),
            .i_we    (r_we), 
            .or_data (w_data));

    always #10 r_clk <= !r_clk;

    // main testing
    initial begin
        // write/read in r_address test
        #1 r_addr = 8'd3;
        #1 r_data = 8'd11;
        #1 r_we   = 1'b1;
        @(posedge r_clk); // write in RAM
        @(posedge r_clk); // output RAM
        #1 Tester8.run_test("read/write 1", w_data, 8'd11);
        //
        #1 r_addr = 8'd6;
        #1 r_data = 8'd22;
        @(posedge r_clk);
        @(posedge r_clk);
        #1 Tester8.run_test("read/write 2", w_data, 8'd22);
        //
        #1 r_addr = 8'd3;
        #1 r_data = 8'd33;
        #1 r_we   = 1'b0;
        @(posedge r_clk);
        @(posedge r_clk);
        #1 Tester8.run_test("read/write 3", w_data, 8'd11);
        //
        #1 r_addr = 8'd6;
        #1 r_data = 8'd44;
        @(posedge r_clk);
        @(posedge r_clk);
        #1 Tester8.run_test("read/write 4", w_data, 8'd22);

        // loop test
        #1 r_we = 1'b1;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 r_addr = i;
            #1 r_data = i*10;
            @(posedge r_clk);
        end
        #1 r_we = 1'b0;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 r_addr = i;
            @(posedge r_clk);
            #1 Tester8.run_test({"loop_write_", 8'h30+i}, w_data, i*10);
        end
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule
