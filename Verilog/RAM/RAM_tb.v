// RAM Testbench
`include "RAM.v"

module RAM_tb;

    reg  [7:0] addr;
    reg  [7:0] din;
    reg        clk, we;
    wire [7:0] dout;

    reg [7:0] ntest = 8'd1; 
    reg [7:0] i     = 8'd0;
    
    task run_test;
        input [103:0] res_name;
        input [7:0]  given_res;
        input [7:0]  expctd_res;
        begin
            if (given_res == expctd_res)
                $display("test %d for %s at %d[s] PASS", ntest, res_name, $realtime);
            else
                $display("test %d for %s at %d[s] FAILED, expected  dout=%h, got %h", 
                ntest, res_name, $realtime, expctd_res, given_res);
            ntest = ntest + 1;
        end
    endtask

    RAM #(.addr_width(8), .data_width(8))
        DUT (.addr(addr), .din(din), .clk(clk), .we(we), .dout(dout));

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
        @(posedge clk); // write in RAM
        @(posedge clk); // output RAM
        #1 run_test("read/write 1", dout, 8'd11);
        //
        #1 addr = 8'd6;
        #1 din  = 8'd22;
        @(posedge clk);
        @(posedge clk);
        #1 run_test("read/write 2", dout, 8'd22);
        //
        #1 we = 1'b0;
        #1 addr = 8'd3;
        #1 din  = 8'd33;
        @(posedge clk);
        @(posedge clk);
        #1 run_test("read/write 3", dout, 8'd11);
        //
        #1 addr = 8'd6;
        #1 din  = 8'd44;
        @(posedge clk);
        @(posedge clk);
        #1 run_test("read/write 4", dout, 8'd22);

        // loop test
        #1 we = 1'b1;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 addr = i;
            #1 din  = i*10;
            @(posedge clk);
        end
        #1 we = 1'b0;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 addr = i;
            @(posedge clk);
            #1 run_test({"loop write ", 8'h30+i}, dout, i*10);
        end

    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end
endmodule
