// RAM Testbench
`include "RAM.v"

module RAM_tb;

    reg  [7:0] r_addr;
    reg  [7:0] r_data;
    reg        r_clk   = 1'b0;
    reg        r_we    = 1'b0;
    wire [7:0] w_data;

    reg  [7:0] ntest = 1; 
    reg [15:0] curr_time;
    reg  [7:0] i;
    
    task run_test;
        input [8*13-1:0] i_test_name;
        input      [7:0] i_expctd_res;
        begin
            #1;
            curr_time = $realtime;
            if (w_data == i_expctd_res)
                $display("test %d for %s at %d[s] PASS", ntest, i_test_name, curr_time);
            else
                $display("test %d for %s at %d[s] FAILED, expected  w_data=%h, got %h", 
                ntest, i_test_name, curr_time, i_expctd_res, w_data);
            ntest = ntest + 1;
        end
    endtask

    RAM #(
        .ADDR_WIDTH (8), 
        .DATA_WIDTH (8)) DUT (
            .i_addr (r_addr), 
            .i_data (r_data), 
            .i_clk  (r_clk),
            .i_we   (r_we), 
            .or_data (w_data));

    always #10 r_clk <= !r_clk;

    // test core
    initial begin
        // write/read in r_address test
        #1 r_addr = 8'd3;
        #1 r_data = 8'd11;
        #1 r_we   = 1'b1;
        @(posedge r_clk); // write in RAM
        @(posedge r_clk); // output RAM
        run_test("read/write 1", 8'd11);
        //
        #1 r_addr = 8'd6;
        #1 r_data = 8'd22;
        @(posedge r_clk);
        @(posedge r_clk);
        #1 run_test("read/write 2", 8'd22);
        //
        #1 r_addr = 8'd3;
        #1 r_data = 8'd33;
        #1 r_we   = 1'b0;
        @(posedge r_clk);
        @(posedge r_clk);
        run_test("read/write 3", 8'd11);
        //
        #1 r_addr = 8'd6;
        #1 r_data = 8'd44;
        @(posedge r_clk);
        @(posedge r_clk);
        run_test("read/write 4", 8'd22);

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
            #1 run_test({"loop write ", 8'h30+i}, i*10);
        end
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule
