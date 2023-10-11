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
	
	wire [`ADDR_WIDTH - 1: 0] iPC, oPC;
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

    ////////////////////////
    ////     Modules    ////
    ////////////////////////
	clock_module clk_mod(
			.phi0(phi0),
			.phi1(phi1_int),
			.phi2(phi2_int)
			);


	//Regs
	register #(.BIT_WIDTH(16), .RESET_VECTOR(`INSTRUCTION_BASE)) PC (.clk(phi2_int), .reset_n(reset_n), .we(we_pc), .din(iPC), .dout(oPC));
	register SP(.clk(phi2_int), .reset_n(reset_n), .we(we_sp), .din(iSP), .dout(oSP));
	register ADD(.clk(phi2_int), .reset_n(reset_n), .we(we_add), .din(iADD), .dout(oADD));
	register X(.clk(phi2_int), .reset_n(reset_n), .we(we_x), .din(iX), .dout(oX));
	register Y(.clk(phi2_int), .reset_n(reset_n), .we(we_y), .din(iY), .dout(oY));
	register STAT(.clk(phi2_int), .reset_n(reset_n), .we(we_stat), .din(iSTATUS), .dout(oSTATUS));	

	addr_bus abus(
        //IN
        .clk(phi1_int), 
		.reset_n(reset_n),
        .pc_in(), 
        .sp_in(), 
        .mem_in(), 
        .imm_in(),
        .fetch_in(),
        .decode_in(),
        .alu_in(),

        //SEL
        .in_selector(), 
        .out_selector(),   
        
        //OUT
        .out()
		);

    data_bus bus(
        //IN
        .clk(phi2_int), 
        .reset_n(reset_n),
        .pc_in(), 
        .sp_in(), 
        .add_in(), 
        .x_in(), 
        .y_in(), 
        .stat_in(),      
        .mem_in(), 
        .imm_in(), 
        .fetch_in(), 
        .decode_in(), 
        .alu_in(),            
        //SEL
        .pc_selector(), 
        .sp_selector(), 
        .add_selector(), 
        .x_selector(),
        .y_selector(), 
        .stat_selector(),         
        .mem_selector(), 
        .fetch_selector(), 
        .decode_selector(), 
        .alu0_selector(), 
        .alu1_selector(),   
        //OUT
        //.pc_out(iPC), 
        .sp_out(), 
        .add_out(), 
        .x_out(), 
        .y_out(), 
        .stat_out(), 
        .mem_out(), 
        .fetch_out(), 
        .decode_out(), 
        .alu0_out(), 
        .alu1_out() 
		);

	fetcher fetch(
        .phi1(phi1_int), 
		.phi2(phi2_int), 
		.reset_n(reset_n), 
		.get_next(),  
        .pc(),
        .sp(),
        .data_in(),

        .instruction_done(),
        .instruction_ready(), 
		.pc_wait(),
        .addr(), 
		.pc_next(),
        .imm(),
        .instruction_out(), 
		.reg_out(),

        .fetch_selector()
		);

	decoder decode(
        .clk(phi1_int), 
		.reset_n(reset_n),
        .addr_in(), 
		.pc_in(),
        .instruction_in(), 
		.status_in(), 
		.data_in(),
        .instruction_ready(), 
		.alu_done(),
        .imm_in(),

        .opp(),       
        .instruction_done(), 
		.carry_in(),

        .addr(),
        .jump_pc(),
        .we(),

        .pc_selector(),
        .sp_selector(), 
        .add_selector(), 
        .x_selector(), 
        .y_selector(), 
        .stat_selector(),     
        .mem_selector(), 
        .decode_selector(), 
        .alu0_selector(), 
        .alu1_selector(),    
		.addr_in_selector(),   

        .imm_out(),
        .alu_update_status(), 
		.invert_alu_b()
        );

	ALU alu0(
		.phi1(phi1_int), 
		.phi2(phi2_int), 
		.reset_n(reset_n),	
		.a_in(), 
		.b_in(), 
		.func(), 
		.status_in(), 
		.carry_in(), 
		.dec_mode(), 
		.invert(),
		.dout(), 
		.status_out(),
		.wout()
		);

endmodule

`endif