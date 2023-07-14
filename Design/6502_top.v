//Sam Baker
//07/2023
//6502 top level module

//The intention here is not to make a bit perfect version of the NES but
//to try to dessign and implement my own version of the device which as closely
//Matches the specs and behavior of the original as possible

//Full disclosure, as this is still very much a work in progress things are a bit of a mess
//I will be cleaning up, refactoring and adding tests as the project progresses

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

	wire [`WE_WIDTH - 1 : 0] we;
	wire we_pc, we_sp, we_add, we_x, we_y, we_stat;
	
	assign we_pc 	= we[`WE_PC];
	assign we_sp 	= we[`WE_SP];
	assign we_add 	= we[`WE_ADD];
	assign we_x 	= we[`WE_X];
	assign we_y 	= we[`WE_Y];
	assign we_stat 	= we[`WE_STAT];

	wire [`REG_WIDTH - 1: 0] iPC, oPC;
	wire [`REG_WIDTH - 1: 0] iSP, oSP;
	wire [`REG_WIDTH - 1: 0] iADD, oADD;
	wire [`REG_WIDTH - 1: 0] iX, oX;
	wire [`REG_WIDTH - 1: 0] iY, oY;
	wire [`REG_WIDTH - 1: 0] iSTATUS, oSTATUS;

	wire [`REG_WIDTH - 1: 0] imm_addr;

	wire [`REG_WIDTH - 1: 0] ialu_a, ialu_b;

	wire [`REG_WIDTH - 1: 0] read_in, fetch_reg_in, fetch_reg_out;

	wire [`REG_WIDTH - 1: 0] instruction;
	wire instruction_ready;	

	assign read_in = D;
	assign A = imm_addr;

	wire carry_in, carry_out;
	wire get_next;

	fetcher fetch(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.get_next(get_next), 
		.pc(oPC), 
		.data_in(fetch_reg_in), 
		.instruction_out(instruction), 
		.pc_next(iPC), 
		.we_pc(we_pc), 
		.addr(A), 
		.instruction_ready(instruction_ready),
		.reg_out(fetch_reg_out),
		.fetch_source_selector(fetch_selector)
		);

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.instruction_in(instruction), 
		.opp(opp),
		.we(we),
		.read_write(R_W_n),
		.source_selector_0(source_selector_0),
		.target_selector_0(target_selector_0),
		.source_selector_1(source_selector_1),
		.target_selector_1(target_selector_1),
		.imm_addr(imm_addr),
		.get_next(get_next),
		.instruction_ready(instruction_ready)
		);

	//Selectors  --  Generalize these selectors and set up some defines
	wire [`REG_WIDTH - 1: 0] reg_connect_0, reg_connect_1;
	wire [2:0] source_selector_0, target_selector_0, source_selector_1, target_selector_1, fetch_selector;
	reg  [2:0] source_selector_01, target_selector_01;
	
	//make this a switch
	always @(posedge phi2_int) begin
		if (fetch_selector) begin
			source_selector_01 = fetch_selector;
			target_selector_01 = `SELECTOR_FETCH;
		end
		else begin
			source_selector_01 = source_selector_0;
			target_selector_01 = target_selector_0;
		end
	end

	mux831 reg_mux0  (.clk(phi2_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(imm_addr), .in5(D), .in6(8'h00), .in7(fetch_reg_out), .selector(source_selector_01), .out(reg_connect_0));
	fan138 reg_fan0  (.clk(phi2_int), .in(reg_connect_0), .out0(iPC), .out1(iADD), .out2(iX), .out3(iY), .out5(D), .out6(ialu_a), .out7(fetch_reg_in),  .selector(target_selector_01));

	mux831 reg_mux1  (.clk(phi2_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(imm_addr), .in5(D), .in6(8'h00), .in7(fetch_reg_out), .selector(source_selector_1), .out(reg_connect_1));
	fan138 reg_fan1  (.clk(phi2_int), .in(reg_connect_1), .out0(iPC), .out1(iADD), .out2(iX), .out3(iY), .out5(D), .out6(ialu_b), .out7(fetch_reg_in), .selector(target_selector_1));

	//Regs
	register PC(.clk(phi2_int), .reset_n(reset_n), .we(we_pc), .din(iPC), .dout(oPC));
	register SP(.clk(phi2_int), .reset_n(reset_n), .we(we_sp), .din(iSP), .dout(oSP));
	register ADD(.clk(phi2_int), .reset_n(reset_n), .we(we_add), .din(iADD), .dout(oADD));
	register X(.clk(phi2_int), .reset_n(reset_n), .we(we_x), .din(iX), .dout(oX));
	register Y(.clk(phi2_int), .reset_n(reset_n), .we(we_y), .din(iY), .dout(oY));
	register STAT(.clk(phi2_int), .reset_n(reset_n), .we(we_stat), .din(iSTATUS), .dout(oSTATUS));	


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