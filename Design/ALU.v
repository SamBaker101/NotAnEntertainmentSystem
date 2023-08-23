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
	output reg wout
	);
	
	reg opp_reg;
	
	//STATUS REGS
	reg carry_out;
	reg interrupt_mask_out;
	reg decimal_out;
	reg break_out;
	//--//
	reg overflow_out;
	reg negative_out;
	
	//STATUS ASSIGNS

	always @(phi2) begin
		status_out = status_in;

		status_out[`CARRY] 		= (carry_out 			=== 1'b1);
		status_out[`ZERO] 		= (dout 				=== `REG_WIDTH'h0);
		status_out[`INT_DIS] 	= (interrupt_mask_out 	=== 1'b1);
		status_out[`DEC] 		= (decimal_out 			=== 1'b1);
		status_out[`BREAK] 		= (break_out 			=== 1'b1);
		//--//
		status_out[`V_OVERFLOW] = (overflow_out 		=== 1'b1);
		status_out[`NEG] 		= (dout[`REG_WIDTH - 1] === 1'b1); 
	end

	//In the 6502 most of this logic is implemented with NANDs and NORs but Im not pressed about it
	always @(posedge phi1) begin
		if (opp_reg !== func) begin
			wout = 1'b0;
			opp_reg = func;
		end

		if (!reset_n) begin
			dout = 8'h00;
			status_out = 8'h00;

		end else if (wout == 0) begin
			if (func == `SUM) begin
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
				carry_out = a[0];
				dout = a >> 1;		
				wout = 1'b1;
			end else begin
				dout = 8'hZZ;
				wout = 1'b0;
			end
		end
	end

endmodule

`endif
