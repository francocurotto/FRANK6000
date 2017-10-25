// Contro Unit Testbench
`include "Control_Unit.v"
`include "../Tester/Tester.v"

module Control_Unit_tb;

    reg  [3:0]  r_control_input  = 4'b0;
    reg         r_clk            = 1'b0;
    reg         r_rst            = 1'b0;
    wire [15:0] w_control_output;

    Tester #(.WIDTH( 2)) Tester2 ();
    Tester #(.WIDTH(16)) Tester16();

    Control_Unit DUT (
        .i_control_input (r_control_input),
        .i_clk           (r_clk),
        .i_rst           (r_rst),
        .o_jump          (w_control_output   [15]),
        .o_j_mode        (w_control_output[14:13]),
        .o_call          (w_control_output   [12]),
        .o_return        (w_control_output   [11]),
        .o_ADDRin        (w_control_output   [10]),
        .o_FRin          (w_control_output    [9]),
        .o_WREGin        (w_control_output  [8:7]),
        .o_ALUin1        (w_control_output    [6]),
        .o_ALUin2        (w_control_output    [5]),
        .o_PCw           (w_control_output    [4]),
        .o_ADDRw         (w_control_output    [3]),
        .o_FRw           (w_control_output    [2]),
        .o_WREGw         (w_control_output    [1]),
        .o_STATUSw       (w_control_output    [0]));

    always #10 r_clk <= !r_clk;

    // main testing
    initial begin
        #1 r_rst = 1'b1;
        #1 r_rst = 1'b0;

        // state 0 test
        Tester2.run_test("initial_state", DUT.r_state, 2'b0);
        Tester16.run_test("initial_out", w_control_output, 16'b0);

        // fetch test
        @(posedge r_clk);
        #1 Tester2.run_test("state_fetch", DUT.r_state, 2'b1);
        r_control_input = `CALLS;
        #1 Tester16.run_test("output_fetch", w_control_output, 16'b1011_0000_0001_0000);
        
        // cycle1 test
        @(posedge r_clk);
        #1 Tester2.run_test("state_cycle1", DUT.r_state, 2'b10);
        #1 Tester16.run_test("output_cycle1", w_control_output, 16'b0);
        
        // fetch test
        @(posedge r_clk);
        #1 Tester2.run_test("state_fetch", DUT.r_state, 2'b1);
        r_control_input = `R2_FLR;
        #1 Tester16.run_test("output_fetch", w_control_output, 16'b0000_0000_0000_0000);

        // cycle1 test
        @(posedge r_clk);
        #1 Tester2.run_test("state_cycle1", DUT.r_state, 2'b10);
        #1 Tester16.run_test("output_cycle1", w_control_output, 16'b0000_0000_0011_0011);

        // cycle2 test
        @(posedge r_clk);
        #1 Tester2.run_test("state_cycle1", DUT.r_state, 2'b00);
        #1 Tester16.run_test("out_cycle1", w_control_output, 16'b0);

        // fetch test
        @(posedge r_clk);
        #1 Tester2.run_test("state_fetch", DUT.r_state, 2'b1);
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
