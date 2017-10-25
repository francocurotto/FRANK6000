// Jump Control testbench
`include "Jump_Control.v"
`include "../Tester/Tester.v"

module Jump_Control_tb;

    reg [1:0] r_opcode;
    reg [2:0] r_status;
    wire      w_jump;

    Tester #(.WIDTH(8)) Tester8();
    
    Jump_Control DUT (
        .i_opcode (r_opcode),
        .i_status (r_status),
        .o_jump   (w_jump));

    initial begin
        //
        {r_opcode, r_status} = 5'b00_000;
        #1 Tester8.run_test("test_1", w_jump, 1'b1);
        //
        {r_opcode, r_status} = 5'b00_111;
        #1 Tester8.run_test("test_2", w_jump, 1'b1);
        //
        {r_opcode, r_status} = 5'b01_001;
        #1 Tester8.run_test("test_3", w_jump, 1'b1);
        //
        {r_opcode, r_status} = 5'b01_110;
        #1 Tester8.run_test("test_4", w_jump, 1'b0);
        //
        {r_opcode, r_status} = 5'b10_010;
        #1 Tester8.run_test("test_5", w_jump, 1'b1);
        //
        {r_opcode, r_status} = 5'b10_101;
        #1 Tester8.run_test("test_6", w_jump, 1'b0);
        //
        {r_opcode, r_status} = 5'b11_100;
        #1 Tester8.run_test("test_7", w_jump, 1'b1);
        //
        {r_opcode, r_status} = 5'b11_011;
        #1 Tester8.run_test("test_8", w_jump, 1'b0);
    end
endmodule

