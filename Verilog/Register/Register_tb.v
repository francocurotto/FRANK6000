// Register Testbench
`include "Register.v"

module Register_tb;
    
    reg  [7:0] D;
    reg        clk, rst, we;
    wire [7:0] Q;

    reg  [7:0] ntest = 8'd1;
    reg  [7:0] i;

    task run_test;
        input [63:0] test_name;
        input [7:0]  given_res;
        input [7:0]  expctd_res;
        begin
            if (given_res == expctd_res)
                $display("test %d %s at %d[s] PASS", ntest, test_name, $realtime);
            else
                $display("test %d %s at %d[s] FAILED, expected  Q=%h, got %h", 
                ntest, test_name, $stime, expctd_res, given_res);
            ntest = ntest + 1;
        end
    endtask
    
    Register #(.width(8)) DUT1 (.D(D), .clk(clk), .rst(rst), .we(we), .Q(Q));

    // test initialization
    initial begin 
        clk = 1'b0;
        rst = 1'b0;
        we  = 1'b0;
        D   = 8'b0;
        repeat (100) #10 clk = !clk;
    end
    
    // test core
    initial begin
        #20;
        // reset test
        @(posedge clk);
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        #1 run_test("reset", Q, 8'b0);

        // we=0 test
        #1 D = 8'b1;
        @(posedge clk);
        #1 run_test("we=0", Q, 8'b0); 
        
        // we=1 test
        #1 we = 1'b1;
        @(posedge clk);
        #1 run_test("we=1", Q, 8'b1); 
        
        // 2nd reset test
        @(posedge clk);
        #1 rst = 1'b0;
        #1 rst = 1'b1;
        #1 run_test("reset2", Q, 8'b0); 
        
        // loop test
        #1 we = 1'b1;
        D  = 8'b0;
        rst = 1'b0;
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        for (i=8'd0; i<8'd10; i=i+1) begin
            @(posedge clk);
            #1 run_test({"loop ", 8'h30+i}, Q, i);
            D = D + 8'b1;
        end
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule
