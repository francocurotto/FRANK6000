// Tester for the FRANK6000 processor

module Tester #(parameter WIDTH=8);

    task run_test;
        input  [8*15-1:0] i_test_name;
        input [WIDTH-1:0] i_actual_res;
        input [WIDTH-1:0] i_expctd_res;
        begin
            if (i_actual_res == i_expctd_res)
                $display("test %s at %4d[s] PASS", i_test_name, $stime);
            else
                $display("test %s at %4d[s] FAILED, expected res=%h, got %h", 
                i_test_name, $stime, i_expctd_res, i_actual_res);
        end
    endtask

endmodule
