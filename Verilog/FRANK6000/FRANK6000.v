// FRANK6000
`include "../Debounce_Switch/Debounce_Switch.v"
`include "../Instr_RX/Instr_RX.v"
`include "../CPU/CPU.v"
`include "../Bin_2_7Seg/Bin_2_7Seg.v"

module FRANK6000 (
    input  i_Clk,      // master clock
    input  i_Switch_1, // master reset
    input  i_Switch_2, // CPU switch
    input  i_UART_RX,  // UART RX Data
    output o_LED_1,    // CPU ON LED
    output o_LED_2,    // CPU finish LED
    // Segment1 is the upper digit, Segment2 is the lower digit
    output o_Segment1_A,
    output o_Segment1_B,
    output o_Segment1_C,
    output o_Segment1_D,
    output o_Segment1_E,
    output o_Segment1_F,
    output o_Segment1_G,
    //
    output o_Segment2_A,
    output o_Segment2_B,
    output o_Segment2_C,
    output o_Segment2_D,
    output o_Segment2_E,
    output o_Segment2_F,
    output o_Segment2_G);
    
    reg       r_CPU_switch = 1'b0;
    reg       r_CPU_ON     = 1'b0;
    reg [7:0] r_count      = 8'b0;
    reg       r_count_rst  = 1'b0;

    wire        w_rst;
    wire        w_CPU_switch;
    wire        w_rx_dv;
    wire [15:0] w_rx_instr;
    wire        w_loopf;
    wire  [7:0] w_WREG;
    wire        w_rx_dv2;
    
    wire w_Segment1_A, w_Segment2_A;
    wire w_Segment1_B, w_Segment2_B;
    wire w_Segment1_C, w_Segment2_C;
    wire w_Segment1_D, w_Segment2_D;
    wire w_Segment1_E, w_Segment2_E;
    wire w_Segment1_F, w_Segment2_F;
    wire w_Segment1_G, w_Segment2_G;

    wire [7:0] w_debug;

    Debounce_Switch Rst_Debounce (
        .clk(i_Clk),
        .i_switch(i_Switch_1),
        .o_switch(w_rst));

    Debounce_Switch CPU_ON_Debounce (
        .clk(i_Clk),
        .i_switch(i_Switch_2),
        .o_switch(w_CPU_switch));

    // 25,000,000 / 115,200 = 217
    Instr_RX #(.CLKS_PER_BIT(217)) Instr_RX (
        .clk(i_Clk),
        .rst(w_rst),
        .i_rx_serial(i_UART_RX),
        .o_rx_dv(w_rx_dv),
        .o_rx_instr(w_rx_instr));
    
    wire w_we;
    assign w_we = ~r_CPU_ON & w_rx_dv;
    //assign w_we = w_rx_dv;

    CPU CPU (
        .i_instr_addr(r_count),
        .i_instr(w_rx_instr),
        .i_ON(r_CPU_ON),
        .i_we(w_we),
        .i_rst(w_rst),
        .i_clk(i_Clk),
        .o_WREG(w_WREG),
        .o_loopf(w_loopf),
        .o_debug(w_debug));

    always @(posedge i_Clk, posedge w_rst) begin
        if (w_rst) begin
            r_CPU_ON <= 0;
            r_count <= 0;
        end
        else begin
            r_CPU_switch <= w_CPU_switch;
            // Falling edge
            if (~w_CPU_switch && r_CPU_switch) r_CPU_ON <= ~r_CPU_ON;
            r_count_rst <= r_CPU_ON;
            if (~r_CPU_ON && r_count_rst) r_count <= 0;
            else if (~r_CPU_ON && w_rx_dv) r_count <= r_count + 1;
        end
    end

    assign o_LED_1 = r_CPU_ON;
    assign o_LED_2 = w_loopf;
        
    // Binary to 7-Segments Converter for Upper Digit
    Bin_2_7Seg SSeg1 (
        .clk(i_Clk),
        .i_binary_num(w_WREG[7:4]),
        .o_segment_A(w_Segment1_A),
        .o_segment_B(w_Segment1_B),
        .o_segment_C(w_Segment1_C),
        .o_segment_D(w_Segment1_D),
        .o_segment_E(w_Segment1_E),
        .o_segment_F(w_Segment1_F),
        .o_segment_G(w_Segment1_G));
        
    assign o_Segment1_A = ~w_Segment1_A;
    assign o_Segment1_B = ~w_Segment1_B;
    assign o_Segment1_C = ~w_Segment1_C;
    assign o_Segment1_D = ~w_Segment1_D;
    assign o_Segment1_E = ~w_Segment1_E;
    assign o_Segment1_F = ~w_Segment1_F;
    assign o_Segment1_G = ~w_Segment1_G;
        
    // Binary to 7-Segments Converter for Lower Digit
    Bin_2_7Seg SSeg_2 (
        .clk(i_Clk),
        .i_binary_num(w_WREG[3:0]),
        .o_segment_A(w_Segment2_A),
        .o_segment_B(w_Segment2_B),
        .o_segment_C(w_Segment2_C),
        .o_segment_D(w_Segment2_D),
        .o_segment_E(w_Segment2_E),
        .o_segment_F(w_Segment2_F),
        .o_segment_G(w_Segment2_G));
        
    assign o_Segment2_A = ~w_Segment2_A;
    assign o_Segment2_B = ~w_Segment2_B;
    assign o_Segment2_C = ~w_Segment2_C;
    assign o_Segment2_D = ~w_Segment2_D;
    assign o_Segment2_E = ~w_Segment2_E;
    assign o_Segment2_F = ~w_Segment2_F;
    assign o_Segment2_G = ~w_Segment2_G;
    
endmodule
