//Sam Baker
//07/2023
//Mux 8 to 1

// Its an 831 mux... some time I will parameterize it... some time later
`ifndef MUX
`define MUX

module mux831(clk, in0, in1, in2, in3,  in4, in5, in6, in7, 
				in8, in9, in10, in11, in12, in13, in14, in15,
				selector, out
		);
	
		parameter SIGNAL_WIDTH = `REG_WIDTH;
		parameter SELECTOR_WIDTH = 4;

		input clk;
		input [SIGNAL_WIDTH - 1 : 0] in0;
		input [SIGNAL_WIDTH - 1 : 0] in1;
		input [SIGNAL_WIDTH - 1 : 0] in2;
		input [SIGNAL_WIDTH - 1 : 0] in3;
		input [SIGNAL_WIDTH - 1 : 0] in4;
		input [SIGNAL_WIDTH - 1 : 0] in5;
		input [SIGNAL_WIDTH - 1 : 0] in6;
		input [SIGNAL_WIDTH - 1 : 0] in7;
		input [SIGNAL_WIDTH - 1 : 0] in8;
		input [SIGNAL_WIDTH - 1 : 0] in9;
		input [SIGNAL_WIDTH - 1 : 0] in10;
		input [SIGNAL_WIDTH - 1 : 0] in11;
		input [SIGNAL_WIDTH - 1 : 0] in12;
		input [SIGNAL_WIDTH - 1 : 0] in13;
		input [SIGNAL_WIDTH - 1 : 0] in14;
		input [SIGNAL_WIDTH - 1 : 0] in15;

		input [SELECTOR_WIDTH - 1 : 0] selector;

		output [SIGNAL_WIDTH - 1 : 0] out;

		assign out = (selector == 4'b0000) ? in0:
					 (selector == 4'b0001) ? in1:
					 (selector == 4'b0010) ? in2:
					 (selector == 4'b0011) ? in3:
					 (selector == 4'b0100) ? in4:
					 (selector == 4'b0101) ? in5:
					 (selector == 4'b0110) ? in6:
					 (selector == 4'b0111) ? in7:
					 (selector == 4'b1000) ? in8:
					 (selector == 4'b1001) ? in9:
					 (selector == 4'b1010) ? in10:
					 (selector == 4'b1011) ? in11:
					 (selector == 4'b1100) ? in12:
					 (selector == 4'b1101) ? in13:
					 (selector == 4'b1110) ? in14:
					 in15;

endmodule

`endif