// CPU Testbench
`include "CPU.v"

module CPU_tb;

    reg   [7:0] r_instr_addr =  7'b0;
    reg  [15:0] r_instr      = 16'b0;
    reg         r_ON         =  1'b1;
    reg         r_instr_we   =  1'b0;
    reg         r_clk        =  1'b0;
    reg         r_rst        =  1'b0;
    wire        w_control_en;
    wire  [7:0] w_WREG;
    wire        w_loopf;

    CPU DUT (
        .i_instr_addr (r_instr_addr), 
        .i_instr      (r_instr), 
        .i_ON         (r_ON), 
        .i_instr_we   (r_instr_we), 
        .i_control_en (w_control_en), 
        .i_clk        (r_clk), 
        .i_rst        (r_rst), 
        .o_WREG       (w_WREG),
        .o_loopf      (w_loopf));

    always #10 r_clk <= !r_clk;

    reg [1:0] r_counter = 2'b0;
    always @(posedge r_clk) r_counter <= r_counter+1;
    assign w_control_en = ~|r_counter;

    // main testing
    initial begin
        $readmemh("../../Tests/01_move.hex",       DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/02_add.hex",        DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/03_clear.hex",      DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/04_loop.hex",       DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/05_fibonacci.hex",  DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/06_collatz.hex",    DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/07_mult.hex",       DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/08_call.hex",       DUT.Instruction_Memory.mem);
        //$readmemh("../../Tests/09_multi_call.hex", DUT.Instruction_Memory.mem);
        
        #1 r_rst = 1'b1;
        #1 r_rst = 1'b0;
        #8 r_clk = 1'b0;
        
        @(posedge w_loopf);
        $finish();
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule
