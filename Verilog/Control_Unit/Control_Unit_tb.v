// Contro Unit Testbench
`include "Control_Unit.v"
`include "../Tester/Tester.v"

module Control_Unit_tb;

    reg [3:0]   r_control_input  = 4'b0;
    reg         r_clk            = 1'b0;
    reg         r_rst            = 1'b0;
    reg         r_en             = 1'b0;
    wire [16:0] w_control_output;

    Tester #(.WIDTH( 2)) Tester2 ();
    Tester #(.WIDTH(17)) Tester17();

    Control_Unit DUT (
        .i_control_input (r_control_input),
        .i_clk           (r_clk),
        .i_rst           (r_rst),
        .i_en            (r_en),
        .o_jump          (w_control_output[16]),
        .o_j_mode        (w_control_output[15:14]),
        .o_call          (w_control_output[13]),
        .o_return        (w_control_output[12]),
        .o_ADDRin        (w_control_output[11]),
        .o_FRin          (w_control_output[10]),
        .o_WREGin        (w_control_output[9:8]),
        .o_ALUin1        (w_control_output[7]),
        .o_ALUin2        (w_control_output[6]),
        .o_FRr           (w_control_output[5]),
        .o_PCw           (w_control_output[4]),
        .o_ADDRw         (w_control_output[3]),
        .o_FRw           (w_control_output[2]),
        .o_WREGw         (w_control_output[1]),
        .o_STATUSw       (w_control_output[0]));

    always #10 r_clk <= !r_clk;

    // main testing
    initial begin
        // enable=0 test
        r_en     = 1'b0;
        #1 r_rst = 1'b1;
        #1 r_rst = 1'b0;
        Tester2.run_test("enable=0 state", DUT.r_state, 2'b00);
        Tester17.run_test("enable=0 out", w_control_output, 17'b0);
        
        // CALLS test (2 cycle instruction)
        r_control_input = `CALLS;
        #20;
        @(posedge r_clk) r_en = 1'b1;
        @(negedge r_clk)
        Tester2.run_test("CALLS_state1", DUT.r_state, 2'b01);
        Tester17.run_test("CALLS_out1", w_control_output, 17'b1_0110_0000_0001_0000);
        @(posedge r_clk) r_en = 1'b0;
        @(negedge r_clk)
        Tester2.run_test("CALLS_state2", DUT.r_state, 2'b01);
        Tester17.run_test("CALLS_out2", w_control_output, 17'b0_0000_0000_0000_0000);
        #20;
        @(posedge r_clk) r_en = 1'b1;
        @(negedge r_clk)
        Tester2.run_test("CALLS_state3", DUT.r_state, 2'b00);
        Tester17.run_test("CALLS_out3", w_control_output, 17'b0_0000_0000_0000_0000);
        @(posedge r_clk) r_en = 1'b0;
        
        // R2_FLR test (3 cycle instruction)
        r_control_input = `CPYRW;
        #20;
        @(posedge r_clk) r_en = 1'b1;
        @(negedge r_clk)
        Tester2.run_test("CPYRW_state1", DUT.r_state, 2'b10);
        Tester17.run_test("CPYRW_out1", w_control_output, 17'b0_0000_0100_0010_0000);
        @(posedge r_clk) r_en = 1'b0;
        @(negedge r_clk)
        Tester2.run_test("CPYRW_state2", DUT.r_state, 2'b10);
        Tester17.run_test("CPYRW_out2", w_control_output, 17'b0_0000_0000_0000_0000);
        #20;
        @(posedge r_clk) r_en = 1'b1;
        @(negedge r_clk)
        Tester2.run_test("CPYRW_state3", DUT.r_state, 2'b11);
        Tester17.run_test("CPYRW_out3", w_control_output, 17'b0_0000_0010_0001_0010);
        @(posedge r_clk) r_en = 1'b0;
        @(negedge r_clk)
        Tester2.run_test("CPYRW_state3", DUT.r_state, 2'b11);
        Tester17.run_test("CPYRW_out3", w_control_output, 17'b0_0000_0000_0000_0000);
        #20;
        @(posedge r_clk) r_en = 1'b1;
        @(negedge r_clk)
        Tester2.run_test("CPYRW_state3", DUT.r_state, 2'b00);
        Tester17.run_test("CPYRW_out3", w_control_output, 17'b0_0000_0000_0000_0000);
        @(posedge r_clk) r_en = 1'b0;

        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
