// Jump Control for the FRANK6000 processor

module Jump_Control(
    input  [1:0] i_opcode,
    input  [2:0] i_status,
    output       o_jump);

    // i_status[0]: Zero flag
    // i_status[1]: Negative flag
    // i_status[2]: Carry out flag

    reg r_jump;

    always @* begin
        casex ({i_opcode, i_status}) 
            5'b00_xxx : r_jump = 1; // GOTOI jump
            5'b01_xx1 : r_jump = 1; // GTIFZ jump
            5'b10_x1x : r_jump = 1; // GTIFN jump
            5'b11_1xx : r_jump = 1; // GTIFC jump
            default   : r_jump = 0; // no jump
        endcase
    end

    assign o_jump = r_jump;

endmodule
