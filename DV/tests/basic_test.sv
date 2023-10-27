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
            mem_model[7] = mem_model[8];

            mem_model[6] = 8'hFF;
            mem_model['h70] = mem_model[6];

            //Transfers
            mem_model[8] = 8'hAA;
            mem_model[9] = 8'hAA;
            mem_model['h0A] = 8'hAA;
            mem_model['h0B] = 8'hAA;
            mem_model['h0C] = 8'hAA;

        end else if (this.test_name == "alu_test") begin
            mem_model[2] = 8'h14;
            mem_model[3] = 8'h0F;
            stat_model = (stat_model || (8'h01 << `CARRY));

            mem_model[4] = 8'h02;
            mem_model[5] = 8'hF2;
            stat_model = (stat_model || (8'h01 << `CARRY));

            mem_model[6] = 8'hA0;
            mem_model[7] = 8'h5A;
            mem_model[8] = 8'hFA;
            mem_model[9] = 8'h3C;
            stat_model = (stat_model & (8'hFF ^ (8'h01 << `CARRY)));
            mem_model[8'h0A] = 8'h3C;
            mem_model[8'h0B] = 8'hE0;
            mem_model[8'h0C] = 8'h87;
            stat_model = (stat_model || (8'h01 << `CARRY));

        end else begin
            $display("ERROR: Test %s not found in modify_mem_model", this.test_name);
        end
    endfunction

    function void check_stat(byte stat_tap, int bit_to_check);
        if (stat_tap[bit_to_check] != stat_model[bit_to_check])
            $display("ERROR: Stat bit %0d: stat_tap = %b, stat_model = %b", bit_to_check, stat_tap[bit_to_check], stat_model[bit_to_check]);
    endfunction
endclass

`endif