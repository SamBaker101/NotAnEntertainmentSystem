//This is a testbench
`ifndef TB
`define TB

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30

module tb_top;
		reg phi0, reset_n;
		reg [`REG_WIDTH - 1: 0] instruction;
		reg [3:0] tb_we; 
		reg [`REG_WIDTH - 1: 0] tb_iPC; 
		reg [`REG_WIDTH - 1: 0] tb_iX;
		reg [`REG_WIDTH - 1: 0] tb_iY;
		reg [1:0] tb_selector_a, tb_selector_b;
		reg tb_carry_in;

		wire phi1, phi2;
		wire [`REG_WIDTH - 1: 0] tb_oPC;
		wire [`REG_WIDTH - 1: 0] tb_oSP;
		wire [`REG_WIDTH - 1: 0] tb_oADD;
		wire [`REG_WIDTH - 1: 0] tb_oSTATUS;
		wire tb_carry_out;

		reg [7:0] i, j;
		reg [`REG_WIDTH - 1: 0] opp;
		
		reg [31:0] seed;

	top dut(
		.phi0(phi0), 
		.reset_n(reset_n),
		.tb_instruction(instruction),
		.tb_we(tb_we), 
		.tb_iPC(tb_iPC), 
		.tb_iX(tb_iX),
		.tb_iY(tb_iY),
		.tb_selector_a(tb_selector_a), 
		.tb_selector_b(tb_selector_b),
		.tb_carry_in(tb_carry_in),

		.phi1(phi1), 
		.phi2(phi2),
		.tb_oPC(tb_oPC),
		.tb_oSP(tb_oSP),
		.tb_oADD(tb_oADD),
		.tb_oSTATUS(tb_oSTATUS),
		.tb_carry_out(tb_carry_out)
	);

	initial begin
		phi0 = 1'b0;
		forever begin
			#1 phi0 = ~phi0;
		end
	end

	initial begin
		$dumpfile("Out/6502_test_out.vcd");
		$dumpvars(0, tb_top);

		seed = `SEED;

		phi0 = 1'b0;
		reset_n = 1'b1;
		#4;
		reset_n = 1'b0;
		#4;
		reset_n = 1'b1;
		#4;

		for (i = 0; i < `CYCLES; i++) begin
			$display("New cycle %0d", i);
			for (j = 0; j < 6; j++) begin
				
				opp = `REG_WIDTH'b1 << j;

				tb_carry_in = $urandom(seed);
				tb_iX = $urandom(seed);
				tb_iY = $urandom(seed);
				tb_we = 4'b1100;
				//$display("X = %0d, Y = %0d, Opp = %b, j = %0d", tb_iX, tb_iY, opp, j);
				#10;

				instruction = opp;
				tb_selector_a = `SELECTOR_X;
				tb_selector_b = `SELECTOR_Y;
				tb_we = 0;

				#10;
				case (opp)
					`SUM: begin
						$display("%0h + %0h + %0d = %0h %h", tb_iX, tb_iY, tb_carry_in, tb_carry_out, tb_oADD);
						if ((tb_oADD + tb_carry_out*9'h100) != (tb_iX + tb_iY + tb_carry_in)) $fatal(1, "Sum operation incorrect");
					end
					`AND: begin
						$display("%0h & %0h = %0h", tb_iX, tb_iY, tb_oADD);
						if (tb_oADD != (tb_iX & tb_iY)) $fatal(1, "And operation incorrect");
					end
					`OR: begin
						$display("%0h | %0h = %0h", tb_iX, tb_iY, tb_oADD);
						if (tb_oADD != (tb_iX | tb_iY)) $fatal(1, "Or operation incorrect");
					end
					`XOR: begin
						$display("%0h ^ %0h = %0h", tb_iX, tb_iY, tb_oADD);
						if (tb_oADD != (tb_iX ^ tb_iY)) $fatal(1, "Xor operation incorrect");
					end
					`SR: begin
						$display("%0h << %0h = %0h", tb_iX, tb_iY, tb_oADD);
						if (tb_oADD != (tb_iX << tb_iY)) $fatal(1, "Sr operation incorrect");
					end
				endcase
				#10;
			end
		end
		
		$finish;
	end
	
endmodule

`endif
