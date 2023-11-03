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
        stat_model = 8'h00;
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
            stat_model[`CARRY] = 1'b1;
            mem_model[8'h0E] = stat_model;


            mem_model[4] = 8'h02;
            mem_model[5] = 8'hF2;
            stat_model[`NEG] = 1'b1;
            stat_model[`CARRY] = 1'b1;
            mem_model[8'h0F] = stat_model;

            mem_model[6] = 8'hA0;
            mem_model[7] = 8'h5A;
            mem_model[8] = 8'hFA;
            mem_model[9] = 8'h3C;
            stat_model = 8'h00;
            
            mem_model[8'h10] = stat_model;

            mem_model[8'h0A] = 8'h3C;
            mem_model[8'h0B] = 8'hE0;
            mem_model[8'h0C] = 8'h87;
            stat_model[`CARRY]      = 1'b1;
            stat_model[`V_OVERFLOW] = 1'b1;
            stat_model[`NEG]        = 1'b1;
            mem_model[8'h11] = stat_model;
            mem_model[`STACK_BASE] = mem_model[8'h11];

            //Compare tests
            stat_model = 8'h00;
            stat_model[`ZERO]  = 1'b1;
            mem_model[8'h0D] = stat_model;

            stat_model = 8'h00;
            mem_model[8'h12] = stat_model;

            stat_model = 8'h00;
            stat_model[`CARRY]  = 1'b1;
            stat_model[`NEG]  = 1'b1;
            mem_model[8'h13] = stat_model;

            stat_model = 8'h00;
            stat_model[`ZERO]  = 1'b1;
            mem_model[8'h14] = stat_model;

            stat_model = 8'h00;
            mem_model[8'h15] = stat_model;

            stat_model = 8'h00;
            stat_model[`CARRY]  = 1'b1;
            stat_model[`NEG]  = 1'b1;
            mem_model[8'h16] = stat_model;

            stat_model = 8'h00;
            stat_model[`ZERO]  = 1'b1;
            mem_model[8'h17] = stat_model;

            stat_model = 8'h00;
            mem_model[8'h18] = stat_model;

            stat_model = 8'h00;
            stat_model[`CARRY]  = 1'b1;
            stat_model[`NEG]  = 1'b1;
            mem_model[8'h19] = stat_model;

            mem_model[`STACK_BASE] = stat_model;

        end else if (this.test_name == "inc_dec_test") begin
            mem_model[1] = 8'h00;
            mem_model[2] = 8'h01;
            mem_model[3] = 8'h02;
            mem_model[4] = 8'hFF;

            mem_model[5] = 8'h04;
            mem_model[6] = 8'h05;
            mem_model[7] = 8'h06;
            mem_model[8] = 8'h01;

        end else if (this.test_name == "stack_test") begin
            mem_model[0] = 0;

            mem_model[1] = 2;

            mem_model[`STACK_BASE] = 8'h05;
            mem_model[`STACK_BASE + 1] = 8'h02;

            mem_model[2] = 8'h02;
            mem_model[3] = 8'h05;

            stat_model[`CARRY] = 1'b1;
            stat_model[`ZERO] = 1'b0;
            stat_model[`NEG] = 1'b0;

            mem_model[`STACK_BASE] = 8'h01;

        end else if (this.test_name == "set_clear_test") begin
            mem_model[`STACK_BASE]  = (8'h01 << `CARRY);
            mem_model[0]            = (8'h01 << `CARRY);

            mem_model[`STACK_BASE]  = (8'h01 << `INT_DIS);
            mem_model[1]            = (8'h01 << `INT_DIS);

            mem_model[`STACK_BASE]  = (8'h01 << `DEC);
            mem_model[2]            = (8'h01 << `DEC);

            mem_model[`STACK_BASE]  = (8'h01 << `V_OVERFLOW) | (8'h01 << `NEG);
            mem_model[3]            = (8'h01 << `V_OVERFLOW) | (8'h01 << `NEG);

            mem_model[`STACK_BASE]  = (8'h01 << `NEG);
            mem_model[4]            = (8'h01 << `NEG);
            
            stat_model[`NEG] = 1'b1;
        
        end else if (this.test_name == "branch_test") begin

            mem_model[0]            = 8'h00;
            mem_model[2]            = 8'h02;

            mem_model[3]            = 8'h03;
            mem_model[5]            = 8'h05;

            mem_model[6]            = 8'h06;
            mem_model[8]            = 8'h08;

            mem_model[9]            = 8'h09;
            mem_model[8'h0B]        = 8'h0B;

            mem_model[8'h0C]        = 8'h0C;
            mem_model[8'h0E]        = 8'h0E;

            mem_model[8'h0F]        = 8'h0F;
            mem_model[8'h11]        = 8'h11;

            mem_model[8'h12]        = 8'h12;
            mem_model[8'h14]        = 8'h14;

            mem_model[8'h15]        = 8'h15;
            mem_model[8'h17]        = 8'h17;

        end else if (this.test_name == "jump_test") begin

            mem_model[1]            = 8'h01;

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