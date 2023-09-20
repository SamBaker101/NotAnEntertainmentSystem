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
////  Declarations  ////          
////////////////////////

	wire phi1_int, phi2_int;
	wire [`OPP_WIDTH - 1 : 0] opp;
	wire [`REG_WIDTH - 1: 0] ialu_a, ialu_b;

    wire [`ADDR_WIDTH - 1 : 0] addr;
    wire [`REG_WIDTH - 1 : 0] d_to_fetch, d_from_fetch;
    wire [`REG_WIDTH - 1 : 0] d_to_mem, d_from_mem;

    wire get_next;
    wire instruction_ready;

    wire [`WE_WIDTH - 1 : 0] we;
    wire we_pc, we_sp, we_add, we_x, we_y, we_stat;
	
	wire [`REG_WIDTH - 1: 0] iPC, oPC;
	wire [`REG_WIDTH - 1: 0] iSP, oSP;
	wire [`REG_WIDTH - 1: 0] iADD, oADD;
	wire [`REG_WIDTH - 1: 0] iX, oX;
	wire [`REG_WIDTH - 1: 0] iY, oY;
	wire [`REG_WIDTH - 1: 0] iSTATUS, oSTATUS;
    wire [`REG_WIDTH - 1: 0] instruction;
    
    wire [`ADDR_WIDTH - 1: 0] pc, pc_next;
    wire [`REG_WIDTH - 1: 0] imm;
    ////////////////////////
    ////   TL Assigns   ////
    ////////////////////////

	//Pin assignments
	assign A = addr;
	assign D = d_to_mem;
	assign d_from_mem = D;
	assign R_W_n = !we[6];

	//Others
    assign we_pc 	= we[`WE_PC];
	assign we_sp 	= we[`WE_SP];
	assign we_add 	= we[`WE_ADD];
	assign we_x 	= we[`WE_X];
	assign we_y 	= we[`WE_Y];
	assign we_stat 	= we[`WE_STAT];

	assign pc = oPC;
	assign we[0] = (pc != pc_next) ? 1'b1 : 0;
	assign iPC 	 = (pc != pc_next) ? pc_next : pc;


//This module needs updating to use the data bus, 
//will do so once tb_instruction_flow is passing again

/*
	fetcher fetch(
		.phi1(phi1_int), 
		.phi2(phi2_int),
		.reset_n(reset_n), 
		.get_next(get_next), 
		.pc(pc), 
		.data_in(d_to_fetch), 
		.instruction_out(instruction), 
		.pc_next(pc_next), 
		.addr(addr), 
		.imm(imm),
		.instruction_ready(instruction_ready),
		.reg_out(d_from_fetch),
		.fetch_source_selector(fetch_selector)
		);

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.address_in(addr),
		.instruction_in(instruction), 
		.opp(),
		.we(we),
		.source_selector_0(source_selector_0),
		.target_selector_0(target_selector_0),
		.source_selector_1(source_selector_1),
		.target_selector_1(target_selector_1),
		.instruction_ready(instruction_ready)
		);

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
*/	
endmodule

`endif