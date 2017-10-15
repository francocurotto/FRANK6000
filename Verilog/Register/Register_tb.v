// Register Testbench
`include "Register.v"

module Register_tb;
    
    reg  [7:0] r_D   = 8'd0;
    reg        r_clk = 1'b0;
    reg        r_rst = 1'b0;
    reg        r_we  = 1'b0;
    wire [7:0] w_Q;

    reg  [7:0] ntest = 1;
    reg [15:0] curr_time;
    reg  [7:0] i;

    task run_test;
        input [8*7-1:0] i_test_name;
        input     [7:0] i_expctd_res;
        begin
            #1;
            curr_time = $realtime;
            if (w_Q == i_expctd_res)
                $display("test %d %s at %d[s] PASS", ntest, i_test_name, curr_time);
            else
                $display("test %d %s at %d[s] FAILED, expected  Q=%h, got %h", 
                ntest, i_test_name, $stime, i_expctd_res, w_Q);
            ntest = ntest + 1;
        end
    endtask
    
    Register #(.WIDTH(8)) DUT1 (
            .i_D   (r_D), 
            .i_clk (r_clk), 
            .i_rst (r_rst), 
            .i_we  (r_we),
            .or_Q  (w_Q));
    
    always #10 r_clk <= !r_clk;
        
    // main testing
    initial begin
        // reset test
        @(posedge r_clk);
        #1 r_rst = 1'b1;
        #1 r_rst = 1'b0;
        run_test("reset1", 8'b0);
        
        // we=0 test
        #1 r_D = 8'b1;
        @(posedge r_clk);
        run_test("we=0", 8'b0); 
        
        // we=1 test
        #1 r_we = 1'b1;
        @(posedge r_clk);
        run_test("we=1", 8'b1); 
        
        // 2nd reset test
        @(posedge r_clk);
        #1 r_rst = 1'b0;
        #1 r_rst = 1'b1;
        run_test("reset2", 8'b0); 
        
        // loop test
        #1 r_we  = 1'b1;
           r_D   = 8'b0;
           r_rst = 1'b0;
        #1 r_rst = 1'b1;
        #1 r_rst = 1'b0;
        for (i=0; i<10; i=i+1) begin
            @(posedge r_clk);
            run_test({"loop ", 8'h30+i}, i);
            r_D = r_D + 8'b1;
        end
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
