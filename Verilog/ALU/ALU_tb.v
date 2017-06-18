// ALU Testbench
`include "ALU.v"

module ALU_tb;

    reg  [3:0] opcode;
    reg  [7:0] WREG, p;
    wire [7:0] res;
    wire [2:0] status;

    // status[0]: Zero flag
    // status[1]: Negative flag
    // status[2]: Carry out flag
    
    reg [39:0] opnames [0:12];
    initial begin
        opnames[`ZEROW] = "ZEROW";
        opnames[`BNOTW] = "BNOTW";
        opnames[`NEGTW] = "NEGTW";
        opnames[`INCRW] = "INCRW";
        opnames[`DECRW] = "DECRW";
        opnames[`ANDWP] = "ANDWP";
        opnames[`IORWP] = "IORWP";
        opnames[`XORWP] = "XORWP";
        opnames[`ADDWP] = "ADDWP";
        opnames[`SUBWP] = "SUBWP";
        opnames[`CMPWP] = "CMPWP";
        opnames[`SHFLW] = "SHFLW";
        opnames[`SHFRW] = "SHFRW";
    end

    task run_test; 
        input [2:0] ntest;
        input [7:0] expctd_res;
        input [2:0] expctd_status;
        begin
            #1;
            if (res == expctd_res && status == expctd_status)
                $display("test %d for %s PASS", ntest, opnames[opcode]);
            else
                $display("test %d for %s FAILED, WREG:%h, p:%h, res:%h, status:%h.", 
                ntest, opnames[opcode], WREG, p, res, status); 
        end
    endtask
    

    ALU DUT (.opcode(opcode), 
        .WREG(WREG), 
        .p(p), 
        .res(res), 
        .status(status));

    initial begin
        // ZEROW tests
        opcode = `ZEROW;
        WREG = 8'hff;
        run_test(1, 8'd0, 3'b001);
        
        // BNOTW tests
        opcode = `BNOTW;
        WREG = 8'b01010101;
        run_test(1, 8'b10101010, 3'b010);
        //
        WREG = 8'b10101010;
        run_test(2, 8'b01010101, 3'b000);

        // NEGTW tests
        opcode = `NEGTW;
        WREG = 8'd10;
        run_test(1, -8'd10, 3'b010);
        //
        WREG = -8'd20;
        run_test(2, 8'd20, 3'b000);
        //
        WREG = -8'd128;
        run_test(3, -8'd128, 3'b010);

        // INCRW tests
        opcode = `INCRW;
        WREG = 8'd100;
        run_test(1, 8'd101, 3'b000);
        //
        WREG = -8'd100;
        run_test(2, -8'd99, 3'b010);
        //
        WREG = 8'd255;
        run_test(3, 8'd0, 3'b001);

        // DERCW tests
        opcode = `DECRW;
        WREG = 8'd50;
        run_test(1, 8'd49, 3'b000);
        //
        WREG = -8'd50;
        run_test(2, -8'd51, 3'b010);
        //
        WREG = -8'd128;
        run_test(3, 8'd127, 3'b000);

        // ANDWP tests
        opcode = `ANDWP;
        WREG = 8'b11001100;
        p    = 8'b10101010;
        run_test(1, 8'b10001000, 3'b010);

        // IORWP tests
        opcode = `IORWP;
        WREG = 8'b11001100;
        p    = 8'b10101010;
        run_test(1, 8'b11101110, 3'b010);

        // XORWP tests
        opcode = `XORWP;
        WREG = 8'b11001100;
        p    = 8'b10101010;
        run_test(1, 8'b01100110, 3'b000);

        // ADDWP tests
        opcode = `ADDWP;
        WREG = 8'd33;
        p    = 8'd44;
        run_test(1, 8'd77, 3'b000);
        //
        WREG = 8'd90;
        p    = 8'd80;
        run_test(2, 8'd170, 3'b010);
        //
        WREG = 8'd200;
        p    = 8'd100;
        run_test(3, 8'd300, 3'b100);

        // SUBWP tests
        opcode = `SUBWP;
        WREG = 8'd75;
        p    = 8'd50;
        run_test(1, 8'd25, 3'b000);
        //
        WREG = 8'd75;
        p    = -8'd50;
        run_test(2, 8'd125, 3'b100);
        //
        WREG = -8'd75;
        p    = 8'd50;
        run_test(3, -8'd125, 3'b010);
        //
        WREG = -8'd75;
        p    = -8'd50;
        run_test(4, -8'd25, 3'b110);

        // CMPWP tests
        opcode = `CMPWP;
        WREG = 8'd80;
        p    = 8'd70;
        run_test(1, 8'd1, 3'b000);
        //
        WREG = 8'd80;
        p    = 8'd90;
        run_test(2, -8'd1, 3'b010);
        //
        WREG = 8'd80;
        p    = 8'd80;
        run_test(3, 8'd0, 3'b001);

        // SHFLW tests
        opcode =  `SHFLW;
        WREG = 8'b11001100;
        p    = 8'd3;
        run_test(1, 8'b01100000, 3'b000);

        // SHFRW tests
        opcode = `SHFRW;
        WREG = 8'b11001100;
        p    = 8'd3;
        run_test(1, 8'b00011001, 3'b000);
    end
endmodule

