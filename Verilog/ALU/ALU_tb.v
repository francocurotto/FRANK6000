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

    `include "../run_test.v"

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
        #1;
        run_test("ZEROW_o1", w_res, 8'd0);
        run_test("ZEROW_s1", w_status, 3'b001);
        
        // BNOTW tests
        r_opcode = `BNOTW;
        r_oper1  = 8'b01010101;
        #1;
        run_test("BNOTW_o1", w_res, 8'b10101010); 
        run_test("BNOTW_s1", w_status, 3'b010);
        //
        r_oper1 = 8'b10101010;
        #1;
        run_test("BNOTW_o2", w_res, 8'b01010101); 
        run_test("BNOTW_s2", w_status, 3'b000);

        // NEGTW tests
        r_opcode = `NEGTW;
        r_oper1  = 8'd10;
        #1;
        run_test("NEGTW_o1", w_res, -8'd10); 
        run_test("NEGTW_s1", w_status, 3'b010);
        //
        r_oper1 = -8'd20;
        #1;
        run_test("NEGTW_o2", w_res, 8'd20); 
        run_test("NEGTW_s2", w_status, 3'b000);
        //
        r_oper1 = -8'd128;
        #1;
        run_test("NEGTW_o3", w_res, -8'd128); 
        run_test("NEGTW_s3", w_status, 3'b010);

        // INCRW tests
        r_opcode = `INCRW;
        r_oper1  = 8'd100;
        #1;
        run_test("INCRW_o1", w_res, 8'd101); 
        run_test("INCRW_s1", w_status, 3'b000);
        //
        r_oper1 = -8'd100;
        #1;
        run_test("INCRW_o2", w_res, -8'd99); 
        run_test("INCRW_s2", w_status, 3'b010);
        //
        r_oper1 = 8'd255;
        #1;
        run_test("INCRW_o2", w_res, 8'd0); 
        run_test("INCRW_s2", w_status, 3'b001);

        // DERCW tests
        r_opcode = `DECRW;
        r_oper1  = 8'd50;
        #1;
        run_test("DECRW_o1", w_res, 8'd49); 
        run_test("DECRW_s1", w_status, 3'b000);
        //
        r_oper1 = -8'd50;
        #1;
        run_test("DECRW_o2", w_res, -8'd51); 
        run_test("DECRW_s2", w_status, 3'b010);
        //
        r_oper1 = -8'd128;
        #1;
        run_test("DECRW_o3", w_res, 8'd127); 
        run_test("DECRW_s3", w_status, 3'b000);

        // ANDWP tests
        r_opcode = `ANDWP;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'b10101010;
        #1;
        run_test("ANDWP_o1", w_res, 8'b10001000); 
        run_test("ANDWP_s1", w_status, 3'b010);

        // IORWP tests
        r_opcode = `IORWP;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'b10101010;
        #1;
        run_test("IORWP_o1", w_res, 8'b11101110); 
        run_test("IORWP_s1", w_status, 3'b010);

        // XORWP tests
        r_opcode = `XORWP;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'b10101010;
        #1;
        run_test("XORWP_o1", w_res, 8'b01100110); 
        run_test("XORWP_s1", w_status, 3'b000);

        // ADDWP tests
        r_opcode = `ADDWP;
        r_oper1  = 8'd33;
        r_oper2  = 8'd44;
        #1;
        run_test("ADDWP_o1", w_res, 8'd77); 
        run_test("ADDWP_s1", w_status, 3'b000);
        //
        r_oper1 = 8'd90;
        r_oper2 = 8'd80;
        #1;
        run_test("ADDWP_o2", w_res, 8'd170); 
        run_test("ADDWP_s2", w_status, 3'b010);
        //
        r_oper1 = 8'd200;
        r_oper2 = 8'd100;
        #1;
        run_test("ADDWP_o3", w_res, 8'd300); 
        run_test("ADDWP_s3", w_status, 3'b100);

        // SUBWP tests
        r_opcode = `SUBWP;
        r_oper1  = 8'd75;
        r_oper2  = 8'd50;
        #1;
        run_test("SUBWP_o1", w_res, 8'd25); 
        run_test("SUBWP_s1", w_status, 3'b000);
        //
        r_oper1 =  8'd75;
        r_oper2 = -8'd50;
        #1;
        run_test("SUBWP_o2", w_res, 8'd125); 
        run_test("SUBWP_s2", w_status, 3'b100);
        //
        r_oper1 = -8'd75;
        r_oper2 =  8'd50;
        #1;
        run_test("SUBWP_o3", w_res, -8'd125); 
        run_test("SUBWP_s3", w_status, 3'b010);
        //
        r_oper1 = -8'd75;
        r_oper2 = -8'd50;
        #1;
        run_test("SUBWP_o4", w_res, -8'd25); 
        run_test("SUBWP_s4", w_status, 3'b110);

        // CMPWP tests
        r_opcode = `CMPWP;
        r_oper1  = 8'd80;
        r_oper2  = 8'd70;
        #1;
        run_test("CMPWP_o1", w_res, 8'd1); 
        run_test("CMPWP_s1", w_status, 3'b000);
        //
        r_oper1 = 8'd80;
        r_oper2 = 8'd90;
        #1;
        run_test("CMPWP_o2", w_res, -8'd1); 
        run_test("CMPWP_s2", w_status, 3'b010);
        //
        r_oper1 = 8'd80;
        r_oper2 = 8'd80;
        #1;
        run_test("CMPWP_o3", w_res, 8'd0); 
        run_test("CMPWP_s3", w_status, 3'b001);

        // SHFLW tests
        r_opcode =  `SHFLW;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'd3;
        #1;
        run_test("SHFLW_o1", w_res, 8'b01100000); 
        run_test("SHFLW_s1", w_status, 3'b000);

        // SHFRW tests
        r_opcode = `SHFRW;
        r_oper1  = 8'b11001100;
        r_oper2  = 8'd3;
        #1;
        run_test("SHFRW_o1", w_res, 8'b00011001); 
        run_test("SHFRW_s1", w_status, 3'b000);
    end
endmodule

