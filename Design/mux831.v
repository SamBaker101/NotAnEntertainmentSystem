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

		output reg [SIGNAL_WIDTH - 1 : 0] out;

		always @(posedge clk) begin
			if (selector == 3'b000) out = in0;
			if (selector == 3'b001) out = in1;
			if (selector == 3'b010) out = in2;
			if (selector == 3'b011) out = in3;
			if (selector == 3'b100) out = in4;
			if (selector == 3'b101) out = in5;
			if (selector == 3'b110) out = in6;
			if (selector == 3'b111) out = in7;
		end

endmodule

`endif