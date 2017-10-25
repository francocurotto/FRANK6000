// Instruction Stack Testbench
`include "Instruction_Stack.v"
`include "../Tester/Tester.v"

module Instruction_Stack_tb;

    reg  [15:0] r_PC;
    reg         r_call = 1'b0;
    reg         r_rtrn = 1'b0;
    reg         r_clk  = 1'b0;
    reg         r_rst  = 1'b0;
    wire [15:0] w_stack;

    reg [7:0] i;
    
    Tester #(.WIDTH(16)) Tester16();

    Instruction_Stack #(
        .ADDR_WIDTH  (4), 
        .DATA_WIDTH (16)) DUT (
            .i_PC(r_PC), 
            .i_call  (r_call), 
            .i_rtrn  (r_rtrn), 
            .i_rst   (r_rst), 
            .i_clk   (r_clk), 
            .o_stack (w_stack));

    always #10 r_clk <= !r_clk;

    // main testing
    initial begin
        #1 r_rst = 1'b1;
        #1 r_rst = 1'b0;

        // call/rtrn test
        r_PC = 16'd10;
        r_call = 1'b1;
        @(posedge r_clk); // call in line 10 saved
        #1 r_call = 1'b0;
        r_rtrn    = 1'b1;
        r_PC      = 16'd0;
        @(posedge r_clk); // rtrn to line 10+1 
        #1 Tester16.run_test("call/rtrn", w_stack, 16'd11);

        // multiple call/rtrn test
        #1 r_rst = 1'b1;
        #1 r_rst = 1'b0;
        // call loop
        r_call = 1'b1;
        r_rtrn = 1'b0;
        for (i=8'd1; i<8'd10; i=i+1) begin
            #1 r_PC = i*'h10;
            @(posedge r_clk);
        end
        // return loop
        #1
        r_call = 1'b0;
        r_rtrn = 1'b1;
        for (i=8'h91; i>8'h10; i=i-'h10) begin
            @(posedge r_clk);
            #1 Tester16.run_test({"multi_call/rtrn"}, w_stack, i);
        end
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
