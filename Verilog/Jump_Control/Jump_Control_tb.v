// Jump Control testbench
`include "Jump_Control.v"

module Jump_Control_tb;

    reg [1:0] r_opcode;
    reg [2:0] r_status;
    wire      w_jump;

    task run_test;
        input i_expctd_res;
        begin
            #1;
            if (w_jump == i_expctd_res)
                $display("test for input %b PASS", {r_opcode, r_status});
            else
                $display("test for input %b FAILED, expected %b, got %b", 
                {r_opcode, r_status}, i_expctd_res, w_jump);
        end
    endtask
    
    Jump_Control DUT (
        .i_opcode (r_opcode),
        .i_status (r_status),
        .o_jump   (w_jump));

    initial begin
        //
        {r_opcode, r_status} = 5'b00_000;
        run_test(1'b1);
        //
        {r_opcode, r_status} = 5'b00_111;
        run_test(1'b1);
        //
        {r_opcode, r_status} = 5'b01_001;
        run_test(1'b1);
        //
        {r_opcode, r_status} = 5'b01_110;
        run_test(1'b0);
        //
        {r_opcode, r_status} = 5'b10_010;
        run_test(1'b1);
        //
        {r_opcode, r_status} = 5'b10_101;
        run_test(1'b0);
        //
        {r_opcode, r_status} = 5'b11_100;
        run_test(1'b1);
        //
        {r_opcode, r_status} = 5'b11_011;
        run_test(1'b0);
    end
endmodule

