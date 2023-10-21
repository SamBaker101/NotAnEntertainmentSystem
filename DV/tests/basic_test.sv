//Sam Baker
//10/2023
//Basic test to be used with tb_6502_top

`ifndef BASIC_TEST
`define BASIC_TEST

`include "PKG/pkg.v"

class basic_test;
    string test_name;

    function new(string test);
        this.test_name = test;
        $display("Basic_Test new called: %s : %s", test, this.test_name);
    endfunction

    function void modify_mem_model();
        if (this.test_name == "load_store_test") begin
            mem_model[2] = 8'h04;
            mem_model[3] = 8'h06;
        end else begin
            $display("ERROR: Test %s not found in modify_mem_model", this.test_name);
        end
    endfunction
endclass

`endif