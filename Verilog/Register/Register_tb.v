// Register Testbench
`include "../edge_macro.v"
`include "Register.v"

module Register_tb;
    
    reg  [7:0] D;
    reg        clk, rst, we;
    wire [7:0] Q_pos, Q_neg;

    reg  [7:0] ntest = 8'd1;
    reg  [7:0] i;

    task run_test;
        input [39:0] res_name;
        input [7:0]  given_res;
        input [7:0]  expctd_res;
        begin
            if (given_res == expctd_res)
                $display("test %d for %s at %d[s] PASS", ntest, res_name, $time);
            else
                $display("test %d for %s at %d[s] FAILED, expected  Q=%h, got %h", 
                ntest, res_name, $time, expctd_res, given_res);
            ntest = ntest + 1;
        end
    endtask
    
    Register #(.width(8), .active_edge(`POS_EDGE)) 
         DUT1 (.D(D), .clk(clk), .rst(rst), .we(we), .Q(Q_pos));

    Register #(.width(8), .active_edge(`NEG_EDGE)) 
         DUT2 (.D(D), .clk(clk), .rst(rst), .we(we), .Q(Q_neg));
        
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
        #1 run_test("Q_neg", Q_neg, 8'b0);
        #1 run_test("Q_pos", Q_pos, 8'b0);

        // we=0 test
        #1 D = 8'b1;
        @(negedge clk);
        #1 run_test("Q_neg", Q_neg, 8'b0); 
        @(posedge clk);
        #1 run_test("Q_pos", Q_pos, 8'b0); 
        
        // we=1 test
        #1 we = 1'b1;
        @(negedge clk);
        #1 run_test("Q_neg", Q_neg, 8'b1); 
        @(posedge clk);
        #1 run_test("Q_pos", Q_pos, 8'b1); 
        
        // 2nd reset test
        @(posedge clk);
        #1 rst = 1'b0;
        #1 rst = 1'b1;
        #1 run_test("Q_neg", Q_neg, 8'b0); 
        #1 run_test("Q_pos", Q_pos, 8'b0); 
        
        // loop test
        #1 we = 1'b1;
        D  = 8'b0;
        rst = 1'b0;
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        for (i=8'd0; i<8'd10; i=i+1) begin
            $display("i=%d", i);
            @(negedge clk);
            #1 run_test("Q_neg", Q_neg, i);
            @(posedge clk);
            #1 run_test("Q_pos", Q_pos, i);
            D = D + 8'b1;
        end
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule
