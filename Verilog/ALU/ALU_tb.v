// ALU Testbench
`include "ALU.v"

module ALU_tb;

    reg  [3:0] r_opcode;
    reg  [7:0] r_oper1, r_oper2;
    wire [7:0] w_res;
    wire [2:0] w_status;

    // w_status[0]: Zero flag
    // w_status[1]: Negative flag
    // w_status[2]: Carry out flag
    
    reg  [5:0] r_ntest = 1;
    reg [39:0] r_opnames [0:12];
    initial begin
        r_opnames[`ZEROW] = "ZEROW";
        r_opnames[`BNOTW] = "BNOTW";
        r_opnames[`NEGTW] = "NEGTW";
        r_opnames[`INCRW] = "INCRW";
        r_opnames[`DECRW] = "DECRW";
        r_opnames[`ANDWP] = "ANDWP";
        r_opnames[`IORWP] = "IORWP";
        r_opnames[`XORWP] = "XORWP";
        r_opnames[`ADDWP] = "ADDWP";
        r_opnames[`SUBWP] = "SUBWP";
        r_opnames[`CMPWP] = "CMPWP";
        r_opnames[`SHFLW] = "SHFLW";
        r_opnames[`SHFRW] = "SHFRW";
    end

    task run_test; 
        input [7:0] i_expctd_res;
        input [2:0] i_expctd_status;
        begin
            #1;
            if (w_res == i_expctd_res && w_status == i_expctd_status)
                $display("test %d for %s PASS", r_ntest, r_opnames[r_opcode]);
            else
                $display("test %d for %s FAILED, r_oper1:%h, p:%h, res:%h, status:%h.", 
                r_ntest, r_opnames[r_opcode], r_oper1, r_oper2, w_res, w_status); 
            r_ntest = r_ntest + 1;
        end
    endtask
    

    ALU DUT (
        .i_opcode (r_opcode), 
        .i_oper1  (r_oper1), 
        .i_oper2  (r_oper2), 
        .o_res    (w_res), 
        .o_status (w_status));

    initial begin
        // ZEROW tests
        r_opcode = `ZEROW;
        r_oper1  = 8'hff;
        run_test(8'd0, 3'b001);
        
        // BNOTW tests
        r_opcode = `BNOTW;
        r_oper1  = 8'b01010101;
        run_test(8'b10101010, 3'b010);
        //
        r_oper1 = 8'b10101010;
        run_test(8'b01010101, 3'b000);

        // NEGTW tests
        r_opcode = `NEGTW;
        r_oper1  = 8'd10;
        run_test(-8'd10, 3'b010);
        //
        r_oper1 = -8'd20;
        run_test(8'd20, 3'b000);
        //
        r_oper1 = -8'd128;
        run_test(-8'd128, 3'b010);

        // INCRW tests
        r_opcode = `INCRW;
        r_oper1  = 8'd100;
        run_test(8'd101, 3'b000);
        //
        r_oper1 = -8'd100;
        run_test(-8'd99, 3'b010);
        //
        r_oper1 = 8'd255;
        run_test(8'd0, 3'b001);

        // DERCW tests
        r_opcode = `DECRW;
        r_oper1  = 8'd50;
        run_test(8'd49, 3'b000);
        //
        r_oper1 = -8'd50;
        run_test(-8'd51, 3'b010);
        //
        r_oper1 = -8'd128;
        run_test(8'd127, 3'b000);

        // ANDWP tests
        r_opcode = `ANDWP;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'b10101010;
        run_test(8'b10001000, 3'b010);

        // IORWP tests
        r_opcode = `IORWP;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'b10101010;
        run_test(8'b11101110, 3'b010);

        // XORWP tests
        r_opcode = `XORWP;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'b10101010;
        run_test(8'b01100110, 3'b000);

        // ADDWP tests
        r_opcode = `ADDWP;
        r_oper1  = 8'd33;
        r_oper2  = 8'd44;
        run_test(8'd77, 3'b000);
        //
        r_oper1 = 8'd90;
        r_oper2 = 8'd80;
        run_test(8'd170, 3'b010);
        //
        r_oper1 = 8'd200;
        r_oper2 = 8'd100;
        run_test(8'd300, 3'b100);

        // SUBWP tests
        r_opcode = `SUBWP;
        r_oper1  = 8'd75;
        r_oper2  = 8'd50;
        run_test(8'd25, 3'b000);
        //
        r_oper1 =  8'd75;
        r_oper2 = -8'd50;
        run_test(8'd125, 3'b100);
        //
        r_oper1 = -8'd75;
        r_oper2 =  8'd50;
        run_test(-8'd125, 3'b010);
        //
        r_oper1 = -8'd75;
        r_oper2 = -8'd50;
        run_test(-8'd25, 3'b110);

        // CMPWP tests
        r_opcode = `CMPWP;
        r_oper1  = 8'd80;
        r_oper2  = 8'd70;
        run_test(8'd1, 3'b000);
        //
        r_oper1 = 8'd80;
        r_oper2 = 8'd90;
        run_test(-8'd1, 3'b010);
        //
        r_oper1 = 8'd80;
        r_oper2 = 8'd80;
        run_test(8'd0, 3'b001);

        // SHFLW tests
        r_opcode =  `SHFLW;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'd3;
        run_test(8'b01100000, 3'b000);

        // SHFRW tests
        r_opcode = `SHFRW;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'd3;
        run_test(8'b00011001, 3'b000);
    end
endmodule

