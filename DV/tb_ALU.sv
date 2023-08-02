//This is a testbench
`ifndef TB_ALU
`define TB_ALU

`timescale 1ns/1ns
`include "PKG/test_program_macros.v"
`include "PKG/pkg.v"


`define SEED   		33551
`define CYCLES 		30

module tb_alu;
    	reg phi1, phi2, reset_n;	
		
	    reg [`REG_WIDTH - 1 : 0] a; 
	    reg [`REG_WIDTH - 1 : 0] b; 
	    reg [`OPP_WIDTH - 1 : 0] func; 
	    reg carry_in;
	    reg dec_mode; 
	
	    wire [`REG_WIDTH - 1 : 0] add; 
	    wire [`REG_WIDTH - 1 : 0] status;
	    wire wout;
	    wire wout_status;
	    wire overflow;
	    wire carry_out;
	    wire half_carry;

		reg [31:0] seed, i, j;

	ALU alu(.reset_n(reset_n), 
			.phi1(phi1),
			.phi2(phi2),
			.func(func), 
			.carry_in(carry_in),
			.a(a), 
			.b(b), 
			.dout(add),
			.wout(wout),
			.carry_out(carry_out)
			);

	initial begin
		phi1 = 1'b0;
        phi2 = 1'b1;
		forever begin
			#1; 
            phi1 = ~phi1;
            phi2 = ~phi2;
		end
	end

	initial begin
		$dumpfile("Out/ALU.vcd");
		$dumpvars(0, tb_alu);

		seed = `SEED;

		reset_n = 1'b1;
		#4;
		reset_n = 1'b0;
		#4;
		reset_n = 1'b1;
		#4;

		for (i = 0; i < `CYCLES; i++) begin
			$display("New cycle %0d", i);
			for (j = 0; j < 6; j++) begin

				func = `REG_WIDTH'b1 << j;

				carry_in = $urandom(seed);
				a = $urandom(seed);
				b = $urandom(seed);
				//$display("X = %0d, Y = %0d, Opp = %b, j = %0d", a, b, opp, j);

				#10;
				case (func)
					`SUM: begin
						$display("%0h + %0h + %0d = %0h %h", a, b, carry_in, carry_out, add);
						if ((add + carry_out*9'h100) != (a + b + carry_in)) $fatal(1, "Sum operation incorrect");
					end
					`AND: begin
						$display("%0h & %0h = %0h", a, b, add);
						if (add != (a & b)) $fatal(1, "And operation incorrect");
					end
					`OR: begin
						$display("%0h | %0h = %0h", a, b, add);
						if (add != (a | b)) $fatal(1, "Or operation incorrect");
					end
					`XOR: begin
						$display("%0h ^ %0h = %0h", a, b, add);
						if (add != (a ^ b)) $fatal(1, "Xor operation incorrect");
					end
					`SR: begin
						$display("%0h << %0h = %0h", a, b, add);
						if (add != (a << b)) $fatal(1, "Sr operation incorrect");
					end
				endcase
				#10;
			end
		end

		$finish;
	end

endmodule

`endif