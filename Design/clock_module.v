// This is the top
`ifndef CLK
`define CLK

module clock_module(
		input phi0, reset_n,
		output phi1, phi2
		);
	
	//These clocks *should* have a slightly reduced duty cycle to avoid overlap
		assign phi2 = phi0;
		assign phi1 = ~phi0;
	
endmodule

`endif