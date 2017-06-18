// Program Counter plus Instruction Memory for FRANK5000 processor
`include "../edge_macro.v"
`include "../RAM/RAM.v"

module PC_Instr_Mem #(
    parameter addr_width  = 8,
    parameter data_width  = 16,
    parameter active_edge = `POS_EDGE) (
    input      [addr_width-1:0] i_PC,
    input      [data_width-1:0] din,
    input                       rst, clk, we,
    output reg [addr_width-1:0] r_PC,
    output     [data_width-1:0] dout);

    RAM #(.addr_width(addr_width), .data_width(data_width), .active_edge(active_edge))
        Instr_RAM (.addr(r_PC), .din(din), .clk(clk), .we(we), .dout(dout));

    wire local_clk = (active_edge==`POS_EDGE)? clk : !clk;

    always @(posedge local_clk, posedge rst) begin
        if (rst) r_PC = 0;
        else     r_PC <= i_PC;
    end

endmodule
