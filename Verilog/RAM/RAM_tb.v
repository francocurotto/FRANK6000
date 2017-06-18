// RAM Testbench
`include "../edge_macro.v"
`include "RAM.v"

module RAM_tb;

    reg  [7:0] addr;
    reg  [7:0] din;
    reg        clk, we;
    wire [7:0] dout_pos, dout_neg;

    reg [7:0] ntest = 8'd1; 
    reg [7:0] i     = 8'd0;
    
    task run_test;
        input [63:0] res_name;
        input [7:0]  given_res;
        input [7:0]  expctd_res;
        begin
            if (given_res == expctd_res)
                $display("test %d for %s at %d[s] PASS", ntest, res_name, $time);
            else
                $display("test %d for %s at %d[s] FAILED, expected  dout=%h, got %h", 
                ntest, res_name, $time, expctd_res, given_res);
            ntest = ntest + 1;
        end
    endtask

    RAM #(.addr_width(8), .data_width(8), .active_edge(`POS_EDGE))
        DUT1 (.addr(addr), .din(din), .clk(clk), .we(we), .dout(dout_pos));
    RAM #(.addr_width(8), .data_width(8), .active_edge(`NEG_EDGE))
        DUT2 (.addr(addr), .din(din), .clk(clk), .we(we), .dout(dout_neg));

    // test initialization
    initial begin 
        clk  = 1'b0;
        we   = 1'b0;
        addr = 9'b0;
        din  = 8'b0;
        repeat (100) #10 clk = !clk;
    end

    // test core
    initial begin
        // write/read in address test
        #1 we   = 1'b1;
        #1 addr = 8'd3;
        #1 din  = 8'd11;
        @(negedge clk); // write in neg_RAM
        @(posedge clk); // write in pos RAM
        @(negedge clk); // output in neg_RAM
        #1 run_test("dout_neg", dout_neg, 8'd11);
        @(posedge clk); // output in pos_RAM
        #1 run_test("dout_pos", dout_pos, 8'd11);
        //
        #1 addr = 8'd6;
        #1 din  = 8'd22;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        #1 run_test("dout_neg", dout_neg, 8'd22);
        @(posedge clk);
        #1 run_test("dout_pos", dout_pos, 8'd22);
        //
        #1 we = 1'b0;
        #1 addr = 8'd3;
        #1 din  = 8'd33;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        #1 run_test("dout_neg", dout_neg, 8'd11);
        @(posedge clk);
        #1 run_test("dout_pos", dout_pos, 8'd11);
        //
        #1 addr = 8'd6;
        #1 din  = 8'd44;
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        #1 run_test("dout_neg", dout_neg, 8'd22);
        @(posedge clk);
        #1 run_test("dout_pos", dout_pos, 8'd22);

        // loop test
        #1 we = 1'b1;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 addr = i;
            #1 din  = i*10;
            @(negedge clk);
            @(posedge clk);
        end
        #1 we = 1'b0;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 addr = i;
            @(negedge clk);
            #1 run_test("dout_neg", dout_neg, i*10);
            @(posedge clk);
            #1 run_test("dout_pos", dout_pos, i*10);
        end

    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule
