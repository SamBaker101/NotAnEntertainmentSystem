//This is an ALU

`ifndef ALU
`define ALU

module ALU(
	input phi1, phi2, reset_n,	
		
	input [`REG_WIDTH - 1 : 0] a, 
	input [`REG_WIDTH - 1 : 0] b, 
	input [4:0] func, 
	input carry_in,
	input dec_mode, 
	
	output reg [`REG_WIDTH - 1 : 0] add, //adder hold register
	output reg [`REG_WIDTH - 1 : 0] status,
	output reg wout,
	output reg wout_status,
	output overflow,
	output reg carry_out,
	output half_carry
	);
	
	//In the 6502 most of this logic is implemented with NANDs and NORs but Im not pressed about it
	always @(posedge phi1) begin
		if (!reset_n) begin
			add = 8'h00;
		end else if (func == `SUM) begin
			if (carry_in)						//I know it's wierd, don't ask
				{carry_out, add} = a + b + 1;	//This is lazy but it'll do for now
			else
				{carry_out, add} = a + b;
			wout = 1'b1;
		end else if (func == `AND) begin
			add = a&b;	
			wout = 1'b1;
		end else if (func == `OR) begin
			add = a|b;		
			wout = 1'b1;
		end else if (func == `XOR) begin
			add = ~(a & b) & (a | b);	
			wout = 1'b1;
		end else if (func == `SR) begin
			add = a << b;		
			wout = 1'b1;
		end else begin
			add = 8'hZZ;
			wout = 1'b0;
		end
		
	end
endmodule

`endif
