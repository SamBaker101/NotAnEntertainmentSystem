//Sam Baker
//07/2023
//Mux 8 to 1

// Its an 831 mux... some time I will parameterize it... some time later
`ifndef MUX
`define MUX

module mux831(clk, in0, in1, in2, in3,  in4, in5, in6, in7, selector, out
		);
	
		parameter SIGNAL_WIDTH = `REG_WIDTH;
		
		input clk;
		input [SIGNAL_WIDTH - 1 : 0] in0;
		input [SIGNAL_WIDTH - 1 : 0] in1;
		input [SIGNAL_WIDTH - 1 : 0] in2;
		input [SIGNAL_WIDTH - 1 : 0] in3;
		input [SIGNAL_WIDTH - 1 : 0] in4;
		input [SIGNAL_WIDTH - 1 : 0] in5;
		input [SIGNAL_WIDTH - 1 : 0] in6;
		input [SIGNAL_WIDTH - 1 : 0] in7;

		input [2:0] selector;

		output [SIGNAL_WIDTH - 1 : 0] out;

		assign out = (selector == 3'b000) ? in0:
					 (selector == 3'b001) ? in1:
					 (selector == 3'b010) ? in2:
					 (selector == 3'b011) ? in3:
					 (selector == 3'b100) ? in4:
					 (selector == 3'b101) ? in5:
					 (selector == 3'b110) ? in6:
					 in7;

endmodule

`endif