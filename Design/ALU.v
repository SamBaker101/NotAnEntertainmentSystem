//Sam Baker
//07/2023
//6502 ALU module

`ifndef ALU
`define ALU

module ALU(
	input phi1, phi2, reset_n,	
		
	input [`REG_WIDTH - 1 : 0] a_in, 
	input [`REG_WIDTH - 1 : 0] b_in, 
	input [`OPP_WIDTH - 1 : 0] func, 
	input [`REG_WIDTH - 1 : 0] status_in, 
	input carry_in, 
	input invert,
	
	output reg [`REG_WIDTH - 1 : 0] dout, //douter hold register
	output reg [`REG_WIDTH - 1 : 0] status_out,
	output reg wout
	);
	
	wire [`REG_WIDTH - 1 : 0] a, b;

	reg opp_reg;
	
	//STATUS REGS
	reg carry_out;
	reg interrupt_mask_out;
	reg decimal_out;
	reg break_out;
	//--//
	reg overflow_out;
	reg negative_out;

	assign b = (invert) ? (b_in ^ {`REG_WIDTH{1'b1}}) : b_in;
	assign a = a_in;

	//FIXME: Theres a bug in how I handle status
	// Z and N should be updated by any transfer to reg (including inc, dec)
	// Since Im setting the status within the ALU and the we on stat from the decoder this isnt happening
	always @(wout) begin		
		status_out = status_in;

		status_out[`CARRY] 		= (invert)? !(carry_out === 1'b1) : (carry_out === 1'b1);
		status_out[`ZERO] 		= (dout 				=== `REG_WIDTH'h0);
		status_out[`INT_DIS] 	= (interrupt_mask_out 	=== 1'b1);
		status_out[`DEC] 		= (decimal_out 			=== 1'b1);
		status_out[`BREAK] 		= (break_out 			=== 1'b1);
		//--//
		status_out[`V_OVERFLOW] = ((a[`REG_WIDTH-1] === b[`REG_WIDTH-1]) && (a[`REG_WIDTH-1] !== dout[`REG_WIDTH-1]));
		status_out[`NEG] 		= (dout[`REG_WIDTH - 1] === 1'b1); 
		
	end

	always @(posedge phi1) begin
		if (opp_reg !== func) begin
			wout = 1'b0;
			opp_reg = func;
		end

		if (!reset_n) begin
			dout = 8'h00;
			status_out = 8'h00;
			carry_out = 1'b0;

		end else if (func == `NO_OPP) begin
			wout = 1'b0;
			dout = 8'hZZ;

		end else if (wout == 0) begin
			if (func == `SUM) begin
				if (carry_in != invert)						
					{carry_out, dout} = a + b + 1;	
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
				if (carry_in)
					dout = (a >> 1) + 8'h80;
				else
					dout = (a >> 1);
				wout = 1'b1;
			end else begin
				dout = 8'hZZ;
				wout = 1'b0;
			end
		end
	end

endmodule

`endif
