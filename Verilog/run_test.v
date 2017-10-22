task run_test;
    parameter RES_SIZE = 8;
    input     [8*15-1:0] i_test_name;
    input [RES_SIZE-1:0] i_actual_res;
    input [RES_SIZE-1:0] i_expctd_res;
    begin
        if (i_actual_res == i_expctd_res)
            $display("test %s at %4d[s] PASS", i_test_name, $stime);
        else
            $display("test %s at %4d[s] FAILED, expected res=%h, got %h", 
            i_test_name, $stime, i_expctd_res, i_actual_res);
    end
endtask
