// FRANK6000
`include "../Debounce_Switch/Debounce_Switch.v"
`include "../Instr_RX/Instr_RX.v"
`include "../Pulse_Gen/Pulse_Gen.v"
`include "../CPU/CPU.v"
`include "../Bin_2_7Seg/Bin_2_7Seg.v"

module FRANK6000 (
    input  i_clk,     // master clock
    input  i_switch1, // master reset
    input  i_switch2, // CPU switch
    input  i_UART_RX, // UART RX Data
    output o_LED1,    // CPU ON LED
    output o_LED2,    // CPU finish LED
    // Segment1 is the upper digit, Segment2 is the lower digit
    output o_segment1_A,
    output o_segment1_B,
    output o_segment1_C,
    output o_segment1_D,
    output o_segment1_E,
    output o_segment1_F,
    output o_segment1_G,
    //
    output o_segment2_A,
    output o_segment2_B,
    output o_segment2_C,
    output o_segment2_D,
    output o_segment2_E,
    output o_segment2_F,
    output o_segment2_G);
    
    // Reset Debounce Switch
    wire w_rst;
    Debounce_Switch Reset_Debounce (
        .i_clk    (i_clk),
        .i_switch (i_switch1),
        .o_switch (w_rst));

    // CPU Debounce Switch
    wire w_CPU_switch;
    Debounce_Switch CPU_ON_Debounce (
        .i_clk    (i_clk),
        .i_switch (i_switch2),
        .o_switch (w_CPU_switch));

    // Instruction Receiver
    wire [15:0] w_rx_instr;
    wire        w_rx_dv;
    // 25,000,000 / 115,200 = 217
    Instr_RX #(.CLKS_PER_BIT(217)) Instr_RX (
        .i_clk       (i_clk),
        .i_rst       (w_rst),
        .i_rx_serial (i_UART_RX),
        .o_rx_instr  (w_rx_instr),
        .o_rx_dv     (w_rx_dv));

    // Pulse Generator
    reg  r_CPU_ON     = 1'b0;
    wire w_control_en;
    Pulse_Gen #(.WIDTH(20)) Pulse_Gen (
        .i_clk   (i_clk),
        .i_rst   (w_rst),
        .i_en    (r_CPU_ON),
        .o_pulse (w_control_en));

    // FRANK6000 CPU
    reg  [7:0] r_instr_addr = 8'b0;
    wire       w_instr_we   = ~r_CPU_ON & w_rx_dv;
    wire [7:0] w_WREG;
    CPU CPU (
        .i_instr_addr (r_instr_addr),
        .i_instr      (w_rx_instr),
        .i_ON         (r_CPU_ON),
        .i_instr_we   (w_instr_we),
        .i_control_en (w_control_en),
        .i_clk        (i_clk),
        .i_rst        (w_rst),
        .o_WREG       (w_WREG),
        .o_loopf      (o_LED2));

    assign o_LED1 = r_CPU_ON;

    reg r_CPU_switch  = 1'b0;
    reg r_CPU_ON_prev = 1'b0;
    always @(posedge i_clk, posedge w_rst) begin
        if (w_rst) begin
            r_CPU_ON      <= 0;
            r_CPU_ON_prev <= 0;
            r_instr_addr <= 0;

        end
        else begin
            // Toggle r_CPU_ON in falling edge of r_CPU_switch
            r_CPU_switch <= w_CPU_switch;
            if (~w_CPU_switch && r_CPU_switch) r_CPU_ON <= ~r_CPU_ON;
            // reset r_instr_addr in falling edge of r_CPU_ON
            r_CPU_ON_prev <= r_CPU_ON;
            if (~r_CPU_ON && r_CPU_ON_prev) r_instr_addr <= 0;
            // increase instruction address when instruction is written in CPU
            else if (~r_CPU_ON && w_rx_dv) r_instr_addr <= r_instr_addr + 1;
        end
    end
        
    // Binary to 7-Segments Converter for Upper Digit
    wire w_segment1_A;
    wire w_segment1_B;
    wire w_segment1_C;
    wire w_segment1_D;
    wire w_segment1_E;
    wire w_segment1_F;
    wire w_segment1_G;
    Bin_2_7Seg SSeg1 (
        .i_clk(i_clk),
        .i_binary_num(w_WREG[7:4]),
        .o_segment_A(w_segment1_A),
        .o_segment_B(w_segment1_B),
        .o_segment_C(w_segment1_C),
        .o_segment_D(w_segment1_D),
        .o_segment_E(w_segment1_E),
        .o_segment_F(w_segment1_F),
        .o_segment_G(w_segment1_G));
        
    assign o_segment1_A = ~w_segment1_A;
    assign o_segment1_B = ~w_segment1_B;
    assign o_segment1_C = ~w_segment1_C;
    assign o_segment1_D = ~w_segment1_D;
    assign o_segment1_E = ~w_segment1_E;
    assign o_segment1_F = ~w_segment1_F;
    assign o_segment1_G = ~w_segment1_G;
        
    // Binary to 7-Segments Converter for Lower Digit
    wire w_segment2_A;
    wire w_segment2_B;
    wire w_segment2_C;
    wire w_segment2_D;
    wire w_segment2_E;
    wire w_segment2_F;
    wire w_segment2_G;
    Bin_2_7Seg SSeg_2 (
        .i_clk(i_clk),
        .i_binary_num(w_WREG[3:0]),
        .o_segment_A(w_segment2_A),
        .o_segment_B(w_segment2_B),
        .o_segment_C(w_segment2_C),
        .o_segment_D(w_segment2_D),
        .o_segment_E(w_segment2_E),
        .o_segment_F(w_segment2_F),
        .o_segment_G(w_segment2_G));
        
    assign o_segment2_A = ~w_segment2_A;
    assign o_segment2_B = ~w_segment2_B;
    assign o_segment2_C = ~w_segment2_C;
    assign o_segment2_D = ~w_segment2_D;
    assign o_segment2_E = ~w_segment2_E;
    assign o_segment2_F = ~w_segment2_F;
    assign o_segment2_G = ~w_segment2_G;
    
endmodule
