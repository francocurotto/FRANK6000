// Contro Unit Testbench
`include "Control_Unit.v"

module Control_Unit_tb;

    reg  [3:0]  control_input;
    wire [14:0] control_output;
    reg  [14:0] expctd_res;

    Control_Unit DUT (.control_input(control_input),
        .jump   (control_output[14]),
        .j_mode (control_output[13:12]),
        .call   (control_output[11]),
        .return (control_output[10]),
        .ADDRin (control_output[9]),
        .FRin   (control_output[8]),
        .WREGin (control_output[7:6]),
        .ALUin1 (control_output[5]),
        .ALUin2 (control_output[4]),
        .ADDRw  (control_output[3]),
        .FRw    (control_output[2]),
        .WREGw  (control_output[1]),
        .STATUSw(control_output[0]));

    initial begin
        // test R2-Type p:File Register
        control_input = `R2_FLR;
        expctd_res = 15'b001000000010011;
        #1
        if (control_output == expctd_res)
            $display("test R2_FLR PASS");
        else
            $display("test R2_FLR Failed, expected: %b, got: %b.", expctd_res, control_output);

        // test LOOPF
        control_input = `LOOPF;
        expctd_res = 15'b000000000000000;
        #1
        if (control_output == expctd_res)
            $display("test LOOPF PASS");
        else
            $display("test LOOPF Failed, expected: %b, got: %b.", expctd_res, control_output);
    end
endmodule
