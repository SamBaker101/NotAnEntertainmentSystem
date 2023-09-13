//Sam Baker
//07/2023
//Fanout module 1 to 8

`ifndef FAN
`define FAN

module fan138(clk, in, out0, out1, out2, out3, out4, out5, out6, out7, out8, 
			  out9, out10, out11, out12, out13, out14, out15 , selector
		);

		parameter SIGNAL_WIDTH = `REG_WIDTH;
		
		input clk;
		input [SIGNAL_WIDTH - 1 : 0] in;

		input [3:0] selector;

		output [SIGNAL_WIDTH - 1 : 0] out0;
        output [SIGNAL_WIDTH - 1 : 0] out1;
        output [SIGNAL_WIDTH - 1 : 0] out2;
        output [SIGNAL_WIDTH - 1 : 0] out3;
        output [SIGNAL_WIDTH - 1 : 0] out4;
        output [SIGNAL_WIDTH - 1 : 0] out5;
        output [SIGNAL_WIDTH - 1 : 0] out6;
        output [SIGNAL_WIDTH - 1 : 0] out7;
		output [SIGNAL_WIDTH - 1 : 0] out8;
        output [SIGNAL_WIDTH - 1 : 0] out9;
        output [SIGNAL_WIDTH - 1 : 0] out10;
        output [SIGNAL_WIDTH - 1 : 0] out11;
        output [SIGNAL_WIDTH - 1 : 0] out12;
        output [SIGNAL_WIDTH - 1 : 0] out13;
        output [SIGNAL_WIDTH - 1 : 0] out14;
        output [SIGNAL_WIDTH - 1 : 0] out15;

		assign out0  = (selector == 4'b0000) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out1  = (selector == 4'b0001) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out2  = (selector == 4'b0010) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out3  = (selector == 4'b0011) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out4  = (selector == 4'b0100) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out5  = (selector == 4'b0101) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out6  = (selector == 4'b0110) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out7  = (selector == 4'b0111) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out8  = (selector == 4'b1000) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out9  = (selector == 4'b1001) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out10 = (selector == 4'b1010) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out11 = (selector == 4'b1011) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out12 = (selector == 4'b1100) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out13 = (selector == 4'b1101) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out14 = (selector == 4'b1110) ? in : {SIGNAL_WIDTH{1'bz}};
		assign out15 = (selector == 4'b1111) ? in : {SIGNAL_WIDTH{1'bz}};

endmodule

`endif