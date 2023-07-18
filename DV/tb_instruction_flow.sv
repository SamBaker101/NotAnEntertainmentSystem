//Sam Baker
//07/2023
//Memory TB

`ifndef TB_IFLOW
`define TB_IFLOW

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		        33551
`define CYCLES 		        30
`define MEM_DEPTH           32
`define INSTRUCTION_BASE    16

module tb_iflow;

    ////////////////////////
    ////       TB       ////
    ////////////////////////
    reg [31:0] i, seed; 
    reg [`ADDR_WIDTH - 1 : 0] addr_in;
    reg [`REG_WIDTH - 1 : 0] d_in;

    /////////////////////////
    ////  Top Level I/O  ////
    /////////////////////////
    //  IN
    reg phi0, reset_n;
    reg mem_write;

    //  OUT
    wire [`REG_WIDTH - 1 : 0] ialu_a, ialu_b;

    ////////////////////////
    ////    Internal    ////
    ////////////////////////
    wire phi1_int, phi2_int;

    wire [`REG_WIDTH - 1 : 0] d_to_mem, d_from_mem;
    wire [`ADDR_WIDTH - 1 : 0] addr;
    wire [`REG_WIDTH - 1 : 0] d_to_fetch, d_from_fetch;

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

    wire [`REG_WIDTH - 1: 0] reg_connect_0, reg_connect_1;
	wire [2:0] source_selector_0, target_selector_0;
    wire [2:0] source_selector_1, target_selector_1;
    wire [2:0] fetch_selector;
	reg  [2:0] source_selector_01, target_selector_01;
    
    wire [`REG_WIDTH - 1: 0] pc, pc_next;
    wire [`REG_WIDTH - 1: 0] imm;
    ////////////////////////
    ////   TL Assigns   ////
    ////////////////////////
    assign we_pc 	= we[`WE_PC];
	assign we_sp 	= we[`WE_SP];
	assign we_add 	= we[`WE_ADD];
	assign we_x 	= we[`WE_X];
	assign we_y 	= we[`WE_Y];
	assign we_stat 	= we[`WE_STAT];

    //These probably need a switch
    assign we[`WE_DOUT] = mem_write;
    assign addr = addr_in;
    assign d_to_mem = d_in;

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

	assign pc = oPC;
	assign we[0] = (pc != pc_next) ? 1'b1 : 0;
	assign iPC 	 = (pc != pc_next) ? pc_next : pc;

//Tests functionality with single bit inputs
    mem #(.DEPTH(`MEM_DEPTH)) mem_test(
		.clk(phi0), 
        .reset_n(reset_n), 
        .we(we[6]), 
        .addr(addr), 
        .din(d_to_mem), 
        .dout(d_from_mem)
		);

	fetcher fetch(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.get_next(get_next), 
		.pc(pc), 
		.data_in(d_to_fetch), 
		.instruction_out(instruction), 
		.pc_next(pc_next), 
		.addr(addr), 
		.instruction_ready(instruction_ready),
		.reg_out(d_from_fetch),
		.fetch_source_selector(fetch_selector)
		);

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.instruction_in(instruction), 
		.opp(),
		.we(we),
		.read_write(we[6]),
		.source_selector_0(source_selector_0),
		.target_selector_0(target_selector_0),
		.source_selector_1(source_selector_1),
		.target_selector_1(target_selector_1),
		.imm_addr(imm),
		.get_next(get_next),
		.instruction_ready(instruction_ready)
		);

	mux831 reg_mux0  (.clk(phi2_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(imm), .in5(d_from_mem), .in6(8'h00), .in7(d_from_fetch), .selector(source_selector_01), .out(reg_connect_0));
	fan138 reg_fan0  (.clk(phi2_int), .in(reg_connect_0), .out0(pc_next), .out1(iADD), .out2(iX), .out3(iY), .out5(d_to_mem), .out6(ialu_a), .out7(d_to_fetch),  .selector(target_selector_01));

	mux831 reg_mux1  (.clk(phi2_int), .in0(oPC), .in1(oADD), .in2(oX), .in3(oY), .in4(imm), .in5(d_from_mem), .in6(8'h00), .in7(d_from_fetch), .selector(source_selector_1), .out(reg_connect_1));
	fan138 reg_fan1  (.clk(phi2_int), .in(reg_connect_1), .out0(pc_next), .out1(iADD), .out2(iX), .out3(iY), .out6(ialu_b), .out7(d_to_fetch), .selector(target_selector_1));

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
	

    ///////////////////////
    ////  Pin Wiggles  ////
    ///////////////////////
	initial begin : main_loop
        reg [`REG_WIDTH - 1 : 0] mem_model [`MEM_DEPTH - 1 : 0];
        reg [`REG_WIDTH - 1 : 0] mem_unit;
        

		$dumpfile("Out/iflow.vcd");
		$dumpvars(0, tb_iflow);
        
        phi0 = 0;
        seed = `SEED;
        
        //Load and check mem using random data
        //Fill with rand data
        for (i = 0; i < `INSTRUCTION_BASE; i++) begin
            mem_unit = $urandom(seed);
            mem_model[i] = mem_unit;    
            
            mem_write   = 1'b1;
            addr_in     = i;
            d_in    = mem_unit;

            #5;
            phi0 = 0;
            #5;
            phi0 = 1;
        end

        //Check that model matches mem
        for (i = 0; i < `INSTRUCTION_BASE; i++) begin
                mem_write   = 1'b0;
                addr_in     = i;
                mem_unit    = d_from_mem;

                #5;
                phi0 = 0;
                #5;
                phi0 = 1;

                if (mem_unit != mem_model[i]) $fatal(1, "Error with mem write/read at addr %h", i);
            end

        for (i = 0; i < `CYCLES; i++) begin
            //Add stimulus here!


        end
        
    end

endmodule

`endif