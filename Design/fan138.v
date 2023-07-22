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

		output [SIGNAL_WIDTH - 1 : 0] out0;
        output [SIGNAL_WIDTH - 1 : 0] out1;
        output [SIGNAL_WIDTH - 1 : 0] out2;
        output [SIGNAL_WIDTH - 1 : 0] out3;
        output [SIGNAL_WIDTH - 1 : 0] out4;
        output [SIGNAL_WIDTH - 1 : 0] out5;
        output [SIGNAL_WIDTH - 1 : 0] out6;
        output [SIGNAL_WIDTH - 1 : 0] out7;

		assign out0 = (selector == 3'b000) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out1 = (selector == 3'b001) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out2 = (selector == 3'b010) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out3 = (selector == 3'b011) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out4 = (selector == 3'b100) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out5 = (selector == 3'b101) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out6 = (selector == 3'b110) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out7 = (selector == 3'b111) ? in : {SIGNAL_WIDTH{1'bz}};

endmodule

`endif