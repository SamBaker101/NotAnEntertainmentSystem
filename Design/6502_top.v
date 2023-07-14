// This is the top
`ifndef CPU
`define CPU
	
`include "PKG/pkg.v"

module cpu_top(
		input phi0, reset_n, rdy, irq_n, NMI_n, overflow_set_n,
            
		output phi1, phi2, sync, R_W_n,

		inout [`REG_WIDTH - 1: 0] D,
		inout [`ADDR_WIDTH - 1 : 0] A
		);

////////////////////////
////     Design     ////          
////////////////////////
	wire phi1_int, phi2_int;
	
	assign phi1 = phi1_int;
	assign phi2 = phi2_int;
	
	wire [`OPP_WIDTH - 1 : 0] opp;

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

	wire [2:0] selector_PC, selector_SP, selector_ADD, selector_X, selector_Y, selector_STAT;
	wire [2:0] selector_A, selector_D;

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.read(read_in), 
		.opp(opp),
		.reg_sel_a(selector_a),
		.reg_sel_b(selector_b),
		.imm(Imm)
		);
	
	//Inputs to these muxes are not accurate
	//REG MUXES
	mux831 mux_PC  (.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_PC), .out(iPC));
	mux831 mux_SP  (.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_SP), .out(iSP));
	mux831 mux_ADD (.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_ADD), .out(iADD));
	mux831 mux_X   (.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_X), .out(iX));
	mux831 mux_Y   (.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_Y), .out(iY));
	mux831 mux_STAT(.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_STAT), .out(iSTATUS));

	//D and A muxes
	mux831 #(.SIGNAL_WIDTH(16)) mux_A (.clk(phi1_int), .in0(16'h0000), .in1(16'hFFFF), .selector(selector_A), .out(A));
	mux831 mux_D   (.clk(phi1_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(Imm), .selector(selector_D), .out(D));

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
			.func(opp), 
			.carry_in(carry_in),
			.a(ialu_a), 
			.b(ialu_b), 
			.add(iADD),
			.wout(we_add),
			.carry_out(carry_out)
			);
	
endmodule

`endif