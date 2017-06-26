// Contro Unit Testbench
`include "Control_Unit.v"

module Control_Unit_tb;

    reg  [3:0]  control_input;
    reg         clk, rst;
    wire [15:0] control_output;
    reg  [15:0] expctd_res;

    reg [7:0] ntest = 8'd1; 

    Control_Unit DUT (.control_input(control_input),
        .rst    (rst),
        .clk    (clk),
        .jump   (control_output[15]),
        .j_mode (control_output[14:13]),
        .call   (control_output[12]),
        .return (control_output[11]),
        .ADDRin (control_output[10]),
        .FRin   (control_output[9]),
        .WREGin (control_output[8:7]),
        .ALUin1 (control_output[6]),
        .ALUin2 (control_output[5]),
        .PCw    (control_output[4]),
        .ADDRw  (control_output[3]),
        .FRw    (control_output[2]),
        .WREGw  (control_output[1]),
        .STATUSw(control_output[0]));

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

    // Test initialization
    initial begin
        clk  = 1'b0;
        control_input = 4'b0;
        rst = 1'b0;
        repeat (100) #10 clk = !clk;
    end

    // test core
    initial begin
        #1 rst = 1'b1;
        #1 rst = 1'b0;

        // state 0 test
        run_test("state zero, state", DUT.r_unit_state, 2'b0);
        run_test("state zero, out", control_output, 16'b0);

        // fetch test
        @(posedge clk);
        #1 run_test("state fetch", DUT.r_unit_state, 2'b1);
        control_input = `CALLS;
        #1 run_test("output fetch", control_output, 16'b1011_0000_0001_0000);
        
        // cycle1 test
        @(posedge clk);
        #1 run_test("state cycle1", DUT.r_unit_state, 2'b10);
        #1 run_test("out cycle1", control_output, 16'b0);
        
        // fetch test
        @(posedge clk);
        #1 run_test("state fetch", DUT.r_unit_state, 2'b1);
        control_input = `R2_FLR;
        #1 run_test("output fetch", control_output, 16'b0000_0000_0000_0000);

        // cycle1 test
        @(posedge clk);
        #1 run_test("state cycle1", DUT.r_unit_state, 2'b10);
        #1 run_test("out cycle1", control_output, 16'b0000_0000_0011_0011);

        // cycle2 test
        @(posedge clk);
        #1 run_test("state cycle1", DUT.r_unit_state, 2'b00);
        #1 run_test("out cycle1", control_output, 16'b0);

        // fetch test
        @(posedge clk);
        #1 run_test("state fetch", DUT.r_unit_state, 2'b1);


    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
