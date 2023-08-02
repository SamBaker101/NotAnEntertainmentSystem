//Sam Baker
//07/2023
//6502 ALU module

`ifndef ALU
`define ALU

module ALU(
	input phi1, phi2, reset_n,	
		
	input [`REG_WIDTH - 1 : 0] a, 
	input [`REG_WIDTH - 1 : 0] b, 
	input [`OPP_WIDTH - 1 : 0] func, 
	input [`REG_WIDTH - 1 : 0] status_in, 
	input carry_in,
	input dec_mode, 
	
	output reg [`REG_WIDTH - 1 : 0] dout, //douter hold register
	output reg [`REG_WIDTH - 1 : 0] status_out,
	output reg wout,
	output reg wout_status,
	output overflow,
	output reg carry_out,
	output half_carry
	);
	
	//In the 6502 most of this logic is implemented with NANDs and NORs but Im not pressed about it
	always @(posedge phi1) begin
		if (!reset_n) begin
			dout = 8'h00;
		end else if (func == `SUM) begin
			if (carry_in)						//I know it's wierd, don't ask
				{carry_out, dout} = a + b + 1;	//This is lazy but it'll do for now
			else
				{carry_out, dout} = a + b;
			wout = 1'b1;
		end else if (func == `AND) begin
			dout = a&b;	
			wout = 1'b1;
		end else if (func == `OR) begin
			dout = a|b;		
			wout = 1'b1;
		end else if (func == `XOR) begin
			dout = ~(a & b) & (a | b);	
			wout = 1'b1;
		end else if (func == `SR) begin
			dout = a << b;		
			wout = 1'b1;
		end else begin
			dout = 8'hZZ;
			wout = 1'b0;
		end
		
	end
endmodule

`endif
