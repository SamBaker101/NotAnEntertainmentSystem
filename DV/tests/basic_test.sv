//Sam Baker
//10/2023
//Basic test to be used with tb_6502_top

`ifndef BASIC_TEST
`define BASIC_TEST

`include "PKG/pkg.v"

class basic_test;
    string test_name;
    byte stat_model;

    function new(string test);
        this.test_name = test;
        $display("Basic_Test new called: %s : %s", test, this.test_name);
    endfunction

    function void modify_mem_model();
        if (this.test_name == "load_store_test") begin
            mem_model[2] = 8'h04;
            mem_model[5] = mem_model[4]; 
            mem_model[1] = mem_model[2] + 3; 
            mem_model[3] = 8'h05;
            
            mem_model[4] = 8'h1F;
            mem_model[12] = mem_model[8];

            mem_model[6] = 8'hFF;
            mem_model['h70] = mem_model[6];
        end else if (this.test_name == "alu_test") begin
            mem_model[2] = 8'h14;
            mem_model[3] = 8'h0F;
            stat_check = 1'b1;

            //TODO: Need a checker for stat reg
        end else begin
            $display("ERROR: Test %s not found in modify_mem_model", this.test_name);
        end
    endfunction

    function check_stat(byte stat_tap, int bit_to_check);
        if (stat_tap[bit_to_check] != stat_model[bit_to_check])
            $display("ERROR: Stat bit %d: stat_tap = %b, stat_model = %b", bit_to_check, stat_tap[bit_to_check], stat_model[bit_to_check]);
    endfunction
endclass

`endif