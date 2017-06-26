// CPU Testbench
`include "CPU.v"

module CPU_tb;

    reg  [15:0] instr;
    reg         clk, rst, we;
    wire  [7:0] WREG;

    CPU DUT (.i_instr(instr), .i_clk(clk), .i_rst(rst), .i_we(we), .o_WREG(WREG));

    // Test initialization
    initial begin
        instr = 16'b0;
        clk = 1'b0;
        we  = 1'b0;
        rst = 1'b0;
        //$readmemh("../../Tests/01_move.hex", DUT.Instr_Mem.mem);
        //$readmemh("../../Tests/02_add.hex", DUT.Instr_Mem.mem);
        //$readmemh("../../Tests/04_loop.hex", DUT.Instr_Mem.mem);
        //$readmemh("../../Tests/05_fibonacci.hex", DUT.Instr_Mem.mem);
        //$readmemh("../../Tests/06_collatz.hex", DUT.Instr_Mem.mem);
        //$readmemh("../../Tests/07_mult.hex", DUT.Instr_Mem.mem);
        //$readmemh("../../Tests/08_call.hex", DUT.Instr_Mem.mem);
        $readmemh("../../Tests/09_multi_call.hex", DUT.Instr_Mem.mem);
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        #8 clk = 1'b0;
        repeat (2000) #10 clk = !clk;
    end

    // test core
    initial begin
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
