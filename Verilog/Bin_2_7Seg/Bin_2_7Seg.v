module Bin_2_7Seg (
    input        clk,
    input  [3:0] i_binary_num,
    output       o_segment_A,
    output       o_segment_B,
    output       o_segment_C,
    output       o_segment_D,
    output       o_segment_E,
    output       o_segment_F,
    output       o_segment_G);
    
    reg [6:0] r_hex_encoding = 7'h00;
    
    always @(posedge clk) begin
        case (i_binary_num)
            4'b0000 : r_hex_encoding <= 7'h7E;
            4'b0001 : r_hex_encoding <= 7'h30;
            4'b0010 : r_hex_encoding <= 7'h6D;
            4'b0011 : r_hex_encoding <= 7'h79;
            4'b0100 : r_hex_encoding <= 7'h33;
            4'b0101 : r_hex_encoding <= 7'h5B;
            4'b0110 : r_hex_encoding <= 7'h5F;
            4'b0111 : r_hex_encoding <= 7'h70;
            4'b1000 : r_hex_encoding <= 7'h7F;
            4'b1001 : r_hex_encoding <= 7'h7B;
            4'b1010 : r_hex_encoding <= 7'h77;
            4'b1011 : r_hex_encoding <= 7'h1F;
            4'b1100 : r_hex_encoding <= 7'h4E;
            4'b1101 : r_hex_encoding <= 7'h3D;
            4'b1110 : r_hex_encoding <= 7'h4F;
            4'b1111 : r_hex_encoding <= 7'h47;
        endcase
    end // always @(posedge i_Clk)
    
    // r_hex_encoding[7] is unused
    assign o_segment_A = r_hex_encoding[6]; 
    assign o_segment_B = r_hex_encoding[5]; 
    assign o_segment_C = r_hex_encoding[4]; 
    assign o_segment_D = r_hex_encoding[3]; 
    assign o_segment_E = r_hex_encoding[2]; 
    assign o_segment_F = r_hex_encoding[1]; 
    assign o_segment_G = r_hex_encoding[0];
    
endmodule // Bin_2_7Seg
    
    
