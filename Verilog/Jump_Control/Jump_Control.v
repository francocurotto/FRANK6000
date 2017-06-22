// Jump Control for FRANK6000

module Jump_Control(
    input  [1:0] opcode,
    input  [2:0] status,
    output       jump);

    // status[0]: Zero flag
    // status[1]: Negative flag
    // status[2]: Carry out flag

    reg r_jump;

    always @* begin
        casex ({opcode, status}) 
            5'b00_xxx : r_jump = 1; // GOTOI jump
            5'b01_xx1 : r_jump = 1; // GTIFZ jump
            5'b10_x1x : r_jump = 1; // GTIFN jump
            5'b11_1xx : r_jump = 1; // GTIFC jump
            default   : r_jump = 0; // no jump
        endcase
    end

    assign jump = r_jump;

endmodule
