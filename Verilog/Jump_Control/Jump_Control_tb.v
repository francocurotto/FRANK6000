// Jump Control testbench
`include "Jump_Control.v"

module Jump_Control_tb;

    reg [1:0] opcode;
    reg [2:0] status;
    wire      jump;

    task run_test;
        input expctd_res;
        begin
            #1;
            if (jump == expctd_res)
                $display("test for input %b PASS", {opcode, status});
            else
                $display("test for input %b FAILED, expected %b, got %b", 
                {opcode, status}, expctd_res, jump);
        end
    endtask
    
    Jump_Control DUT (.opcode(opcode),
        .status(status),
        .jump(jump));

    initial begin
        //
        {opcode, status} = 5'b00_000;
        run_test(1'b1);
        //
        {opcode, status} = 5'b00_111;
        run_test(1'b1);
        //
        {opcode, status} = 5'b01_001;
        run_test(1'b1);
        //
        {opcode, status} = 5'b01_110;
        run_test(1'b0);
        //
        {opcode, status} = 5'b10_010;
        run_test(1'b1);
        //
        {opcode, status} = 5'b10_101;
        run_test(1'b0);
        //
        {opcode, status} = 5'b11_100;
        run_test(1'b1);
        //
        {opcode, status} = 5'b11_011;
        run_test(1'b0);
    end
endmodule

