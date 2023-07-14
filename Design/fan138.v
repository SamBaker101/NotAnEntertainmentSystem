//Sam Baker
//07/2023
//Fanout module 1 to 8

`ifndef FAN
`define FAN

module fan138(clk, in, out0, out1, out2, out3, out4, out5, out6, out7, selector
		);
	
		parameter SIGNAL_WIDTH = `REG_WIDTH;
		
		input clk;
		input [SIGNAL_WIDTH - 1 : 0] in;

		input [2:0] selector;

		output reg [SIGNAL_WIDTH - 1 : 0] out0;
        output reg [SIGNAL_WIDTH - 1 : 0] out1;
        output reg [SIGNAL_WIDTH - 1 : 0] out2;
        output reg [SIGNAL_WIDTH - 1 : 0] out3;
        output reg [SIGNAL_WIDTH - 1 : 0] out4;
        output reg [SIGNAL_WIDTH - 1 : 0] out5;
        output reg [SIGNAL_WIDTH - 1 : 0] out6;
        output reg [SIGNAL_WIDTH - 1 : 0] out7;

		always @(posedge clk) begin
			if (selector == 3'b000) out0 = in;
			if (selector == 3'b001) out1 = in;
			if (selector == 3'b010) out2 = in;
			if (selector == 3'b011) out3 = in;
			if (selector == 3'b100) out4 = in;
			if (selector == 3'b101) out5 = in;
			if (selector == 3'b110) out6 = in;
			if (selector == 3'b111) out7 = in;
		end

endmodule

`endif