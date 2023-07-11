// This is the top
`ifndef CPU
`define CPU
	
`include "PKG/pkg.v"

module top(
		input phi0, reset_n,
		input [`REG_WIDTH - 1: 0] tb_instruction,
		input [3:0] tb_we, 
		input [`REG_WIDTH - 1: 0] tb_iPC, 
		input [`REG_WIDTH - 1: 0] tb_iX,
		input [`REG_WIDTH - 1: 0] tb_iY,
		input [1:0] tb_selector_a, tb_selector_b,
		input tb_carry_in,

		output phi1, phi2,
		output [`REG_WIDTH - 1: 0] tb_oPC,
		output [`REG_WIDTH - 1: 0] tb_oSP,
		output [`REG_WIDTH - 1: 0] tb_oADD,
		output [`REG_WIDTH - 1: 0] tb_oSTATUS,
		output tb_carry_out
		);
	
/////////////////////////
////TB specific stuff////
/////////////////////////

		assign  we_pc  = tb_we[0];
		assign  we_x   = tb_we[2];
		assign  we_y   = tb_we[3];
		 
		assign iPC  		= tb_iPC;
		assign iX   		= tb_iX;
		assign iY   		= tb_iY;
		assign selector_a 	= tb_selector_a;
		assign selector_b 	= tb_selector_b;
		assign carry_in 	= tb_carry_in;
		assign read_in  	= tb_instruction;

		assign tb_oPC  		= oPC;
		assign tb_oSP  		= oSP;
		assign tb_oADD 		= oADD;
		assign tb_oSTATUS 	= oSTATUS;
		assign tb_carry_out = carry_out;

////////////////////////
////     Design     ////          
////////////////////////

	wire phi1_int, phi2_int;
	
	assign phi1 = phi1_int;
	assign phi2 = phi2_int;
	
	wire [4:0] func;

	wire we_pc, we_sp, we_add, we_x, we_y, we_stat;
	wire [`REG_WIDTH - 1: 0] iPC, oPC;
	wire [`REG_WIDTH - 1: 0] iSP, oSP;
	wire [`REG_WIDTH - 1: 0] iADD, oADD;
	wire [`REG_WIDTH - 1: 0] iX, oX;
	wire [`REG_WIDTH - 1: 0] iY, oY;
	wire [`REG_WIDTH - 1: 0] iSTATUS, oSTATUS;

	wire [`REG_WIDTH - 1: 0] Imm;

	wire [`REG_WIDTH - 1: 0] ialu_a, ialu_b;

	wire [`REG_WIDTH - 1: 0] read_in;	

	wire carry_in, carry_out;

	wire [2:0] selector_a, selector_b;

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.read(read_in), 
		.dec_func(func),
		.reg_sel_a(selector_a),
		.reg_sel_b(selector_b),
		.imm(Imm)
		);
	
	register PC(.clk(phi2_int), .reset_n(reset_n), .we(we_pc), .din(iPC), .dout(oPC));
	register SP(.clk(phi2_int), .reset_n(reset_n), .we(we_sp), .din(iSP), .dout(oSP));
	register ADD(.clk(phi2_int), .reset_n(reset_n), .we(we_add), .din(iADD), .dout(oADD));
	register X(.clk(phi2_int), .reset_n(reset_n), .we(we_x), .din(iX), .dout(oX));
	register Y(.clk(phi2_int), .reset_n(reset_n), .we(we_y), .din(iY), .dout(oY));
	register STAT(.clk(phi2_int), .reset_n(reset_n), .we(we_stat), .din(iSTATUS), .dout(oSTATUS));	

	mux831 alu_a(.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_a), .out(ialu_a));
	mux831 alu_b(.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_b), .out(ialu_b));

	clock_module clk_mod(
			.phi0(phi0),
			.phi1(phi1_int),
			.phi2(phi2_int)
			);
	
	ALU alu(.reset_n(reset_n), 
			.phi1(phi1_int),
			.phi2(phi2_int),
			.func(func), 
			.carry_in(carry_in),
			.a(ialu_a), 
			.b(ialu_b), 
			.add(iADD),
			.wout(we_add),
			.carry_out(carry_out)
			);
	
endmodule

`endif