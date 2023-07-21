//Sam Baker
//07/2023
// 2 to 2 async switch

`ifndef FAN
`define FAN

module fan138(in0, in1, out0, out1, in_select, out_select
		);
	
		parameter SIGNAL_WIDTH = `REG_WIDTH;
		
		input [SIGNAL_WIDTH - 1 : 0] in1, in2;
		input in_selector, out_selector;
		output [SIGNAL_WIDTH - 1 : 0] out0, out1;
 
        wire [SIGNAL_WIDTH - 1 : 0] connect;

        assign connect  = in_select     ? in1 : in0;
        assign out0     = out_select    ? {SIGNAL_WIDTH{1'bz}} : connect;
        assign out1     = out_select    ? connect : {SIGNAL_WIDTH{1'bz}}; 

endmodule

`endif