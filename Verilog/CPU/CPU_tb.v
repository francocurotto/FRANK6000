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
        $readmemh("../../Tests/01_move.hex", DUT.PC_Instr_Mem.Instr_RAM.mem);
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        #1 clk = 1'b1;
        #1 clk = 1'b0;
        #1 rst = 1'b1;
        #1 rst = 1'b0;
        #4 clk = 1'b1;
        #10 clk =1'b0;
        repeat (100) #10 clk = !clk;
    end

    // test core
    initial begin
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
