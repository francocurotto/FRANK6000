// Instruction Stack Testbench
`include "Instruction_Stack.v"

module Instruction_Stack_tb;

    reg [15:0] i_PC;
    reg        call, rtrn, rst, clk;

    wire [15:0] o_Stack;

    reg [7:0] ntest = 8'd1; 
    reg [7:0] i     = 8'd0;
    
    task run_test;
        input [143:0] test_name;
        input [7:0]  given_res;
        input [7:0]  expctd_res;
        begin
            if (given_res == expctd_res)
                $display("test %d %s at %d[s] PASS", ntest, test_name, $realtime);
            else
                $display("test %d %s at %d[s] FAILED, expected %h, got %h", 
                ntest, test_name, $realtime, expctd_res, given_res);
            ntest = ntest + 1;
        end
    endtask

    Instruction_Stack #(.addr_width(4), .data_width(16)) 
        DUT1 (.i_PC(i_PC), .call(call), .rtrn(rtrn), .rst(rst), .clk(clk), .o_Stack(o_Stack));

    // Test initialization
    initial begin
        clk  = 1'b0;
        call = 1'b0;
        rtrn = 1'b0;
        i_PC = 16'b0;
        rst = 1'b0;
        repeat (100) #10 clk = !clk;
    end

    // test core
    initial begin
        #1 rst = 1'b1;
        #1 rst = 1'b0;

        // call/rtrn test
        i_PC = 16'd10;
        call = 1'b1;
        @(posedge clk); // call in line 10 saved
        #1 call = 1'b0;
        rtrn = 1'b1;
        i_PC = 16'd0;
        @(posedge clk); // rtrn to line 10+1 
        #1 run_test("call/rtrn", o_Stack, 16'd11);

        // multiple call/rtrn test
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        // call loop
        call = 1'b1;
        rtrn = 1'b0;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 i_PC = i*'h10;
            @(posedge clk);
        end
        // return loop
        #1
        call = 1'b0;
        rtrn = 1'b1;
        for (i=8'h91; i>8'h10; i=i-'h10) begin
            @(posedge clk);
            #1 run_test({"multiple call/rtrn"}, o_Stack, i);
        end

    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
