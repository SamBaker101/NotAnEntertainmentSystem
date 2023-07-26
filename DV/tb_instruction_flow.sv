//Sam Baker
//07/2023
//Instruction flow test bench
//This test bench loads a dummy mem with random data and user program
//Connects mem to fetcher and decoder logic
//Includes necessary mem, reg, switch, mux and fan modules

//FIXMEs
// Remove get_next signal between decoder and fetcher (use instruction_ready toggling)
// Set up logic such that mem can be filled with data (outside of chip logic) while chip is in reset

`ifndef TB_IFLOW
`define TB_IFLOW

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		        33551
`define CYCLES 		        30
`define MEM_DEPTH           32


module tb_iflow;

    ////////////////////////
    ////       TB       ////
    ////////////////////////
    reg [31:0] i, seed; 
    reg [`ADDR_WIDTH - 1 : 0] addr_in;
    reg [`REG_WIDTH - 1 : 0] d_in;
    reg manual_mem;

    /////////////////////////
    ////  Top Level I/O  ////
    /////////////////////////
    //  IN
    reg phi0, reset_n;
    reg mem_write;
    reg trigger_program;

    //  OUT
    wire [`REG_WIDTH - 1 : 0] ialu_a, ialu_b;

    ////////////////////////
    ////    Internal    ////
    ////////////////////////
    wire phi1_int, phi2_int;

    wire [`REG_WIDTH - 1 : 0] d_to_mem, d_from_mem;
    wire [`ADDR_WIDTH - 1 : 0] addr;
    wire [`REG_WIDTH - 1 : 0] d_to_fetch, d_from_fetch;

    wire get_next, ask_next, instruction_done;
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
	wire  [2:0] source_selector_01, target_selector_01;
    
    wire [`ADDR_WIDTH - 1: 0] /*pc,*/ pc_next;
    wire [`REG_WIDTH - 1: 0] imm;

    wire we_dout;
    wire [`ADDR_WIDTH - 1 : 0] fetcher_addr;
    wire [`REG_WIDTH - 1: 0] d_to_mem1;

    reg [`ADDR_WIDTH - 1 : 0] pc;
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
    assign we[`WE_DOUT] = manual_mem ? mem_write : we_dout;
    
    assign addr         = manual_mem        ? addr_in : 
                          /*instruction_ready ?*/ fetcher_addr  /*    : 
                          pc*/;

    assign d_to_mem1    = manual_mem ? d_in : d_to_mem;

	/*
    assign pc = oPC;
	assign we[0] = (pc != pc_next) ? 1'b1 : 0;
	assign iPC 	 = (pc != pc_next) ? pc_next : pc;
*/
    assign get_next = trigger_program ? trigger_program : ask_next;
    
	switch #(.SIGNAL_WIDTH(3)) selector_switch0(
		.in0(source_selector_0), .in1(fetch_selector), .out0(source_selector_01),
		.in_select(fetch_selector != 0), .out_select(1'b0));

	switch #(.SIGNAL_WIDTH(3)) selector_switch1(
		.in0(target_selector_0), .in1(`SELECTOR_FETCH), .out0(target_selector_01),
		.in_select(fetch_selector != 0), .out_select(1'b0));

    always @(*) pc = pc_next;

//Tests functionality with single bit inputs
    mem #(.DEPTH(`MEM_DEPTH)) mem_test(
		.clk(phi2_int), 
        .reset_n(reset_n), 
        .we(we[`WE_DOUT]), 
        .addr(addr), 
        .din(d_to_mem1), 
        .dout(d_from_mem)
		);

	fetcher fetch(
		.clk(phi1_int),
        .phi2(phi2_int), 
		.reset_n(reset_n), 
		.get_next(get_next), 
		.pc(pc), 
		.data_in(d_to_fetch), 
		.instruction_out(instruction), 
		.pc_next(pc_next), 
		.addr(fetcher_addr), 
		.instruction_ready(instruction_ready),
        .instruction_done(instruction_done),
		.reg_out(d_from_fetch),
        .imm(imm),
		.fetch_source_selector(fetch_selector)
		);

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
        .address_in(fetcher_addr),
		.instruction_in(instruction), 
		.opp(),
		.we({we_dout, we[5:0]}),    //dont ask, Ill fix this in a minute
		.source_selector_0(source_selector_0),
		.target_selector_0(target_selector_0),
		.source_selector_1(source_selector_1),
		.target_selector_1(target_selector_1),
		.instruction_ready(instruction_ready),
		.instruction_done(instruction_done)
        );

	mux831 reg_mux0  (.clk(phi2_int), .in0(/*oPC*/), .in1(oADD), .in2(oX), .in3(oY), .in4(imm), .in5(d_from_mem), .in6(8'h00), .in7(d_from_fetch), .selector(source_selector_01), .out(reg_connect_0));
	fan138 reg_fan0  (.clk(phi2_int), .in(reg_connect_0), .out0(/*pc_next*/), .out1(iADD), .out2(iX), .out3(iY), .out5(d_to_mem), .out6(ialu_a), .out7(d_to_fetch),  .selector(target_selector_01));

	mux831 reg_mux1  (.clk(phi2_int), .in0(/*oPC*/), .in1(oADD), .in2(oX), .in3(oY), .in4(imm), .in5(d_from_mem), .in6(8'h00), .in7(d_from_fetch), .selector(source_selector_1), .out(reg_connect_1));
	fan138 reg_fan1  (.clk(phi2_int), .in(reg_connect_1), .out0(/*pc_next*/), .out1(iADD), .out2(iX), .out3(iY), .out6(ialu_b), .out7(), .selector(target_selector_1));

	//Regs
	//register PC(.clk(phi2_int), .reset_n(reset_n), .we(we_pc), .din(iPC), .dout(oPC));
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
        reg [`REG_WIDTH - 1 : 0] inst_list [`MEM_DEPTH - `INSTRUCTION_BASE - 1 : 0];
        reg [`REG_WIDTH - 1 : 0] mem_unit;

		$dumpfile("Out/iflow.vcd");
		$dumpvars(0, tb_iflow);
        
        phi0 = 0;
        seed = `SEED;
        manual_mem = 1'b1;
        phi0 = 0;

        reset_n = 1'b1;
        #5;
        phi0 = 1;
        #5;
        phi0 = 0;

        reset_n = 1'b0;
        #5;
        phi0 = 1;
        #5;
        phi0 = 0;


        
        //Load and check mem using random data
        //Fill with rand data
        for (i = 0; i < `INSTRUCTION_BASE; i++) begin
            mem_unit = $urandom(seed);
            mem_model[i] = mem_unit;    
            $display("mem_model[%d] = %h", i, mem_model[i]);

            mem_write   = 1'b1;
            addr_in     = i;
            d_in        = mem_unit;

            #5;
            phi0 = 1;
            #5;
            phi0 = 0;
        end

        //Check that model matches mem
        $display("Checking random data loaded to memory");
        for (i = 0; i < `INSTRUCTION_BASE; i++) begin
                mem_write   = 1'b0;
                addr_in     = i;
                
                #5;
                phi0 = 1;
                #5;
                phi0 = 0;
                #5;

                mem_unit    = d_from_mem;
                
                if (mem_unit != mem_model[i]) begin
    
                    
                    $fatal(1, "Error with mem write/read at addr %h, mem_unit = %h, mem_model[%0d] = %h", i, mem_unit, i, mem_model[i]);
                end
                    else $display("Match at addr %0d value %h", i, mem_model[i]);
            end

        //ENTER SOME INSTRUCTIONS HERE;
        inst_list[0]    = 8'hA9;     //LDA #04 - 101_010_11
        inst_list[1]    = 8'h04;
        inst_list[2]    = 8'h85;    //STA ZPG 02 
        inst_list[3]    = 8'h02;
        inst_list[4]    = 8'h0;
        inst_list[5]    = 8'h0;
        inst_list[6]    = 8'h0;
        inst_list[7]    = 8'h0;
        inst_list[8]    = 8'h0;
        inst_list[9]    = 8'h0;
        inst_list[10]   = 8'h0;
        inst_list[11]   = 8'h0;
        inst_list[12]   = 8'h0;
        inst_list[13]   = 8'h0;
        inst_list[14]   = 8'h0;
        inst_list[15]   = 8'h0;

        //Modify mem_model
        mem_model[16'h02] = 8'h04;
        
        //Load Program
        for (i = 0; i < `MEM_DEPTH - `INSTRUCTION_BASE; i++) begin
            mem_model[i + `INSTRUCTION_BASE] = inst_list[i];    
            
            mem_write   = 1'b1;
            addr_in     = i + `INSTRUCTION_BASE;
            d_in    = inst_list[i];

            #5;
            phi0 = 1;
            #5;
            phi0 = 0;
        end

        //Check Program
        for (i = 0; i < `MEM_DEPTH - `INSTRUCTION_BASE; i++) begin
                mem_write   = 1'b0;
                addr_in     = i + `INSTRUCTION_BASE;

                #5;
                phi0 = 1;
                #5;
                phi0 = 0;

                mem_unit    = d_from_mem;

                if (mem_unit != inst_list[i]) $fatal(1, "Error with mem write/read at addr %h", i + `INSTRUCTION_BASE);
                else $display("Match at instruct addr %0d value %h", i + `INSTRUCTION_BASE, inst_list[i]);
        end
        
        manual_mem = 1'b0;
        reset_n = 1'b1;

        trigger_program = 1'b1;
        #5;
        phi0 = 1;
        #5;
        phi0 = 0;
        #5;
        trigger_program = 1'b0;

        //Spin the clock
        $display("Spinning the clock");
        for (i = 0; i < `CYCLES; i++) begin
                    #5;
                    phi0 = 1;
                    #5;
                    phi0 = 0;
        end

        manual_mem = 1'b1;

        $display("Mem Dump");
        for (i = 0; i < `INSTRUCTION_BASE; i++) begin
                mem_write   = 1'b0;
                addr_in     = i;

                #5;
                phi0 = 1;
                #5;
                phi0 = 0;

                mem_unit    = d_from_mem;

                $display("addr: %h data: %h, mem_model: %h", i, mem_unit, mem_model[i]);
        end

        //Checks
        //Check that model matches mem
        for (i = 0; i < `INSTRUCTION_BASE; i++) begin
                mem_write   = 1'b0;
                addr_in     = i;

                #5;
                phi0 = 1;
                #5;
                phi0 = 0;

                mem_unit    = d_from_mem;

                if (mem_unit != mem_model[i]) $fatal(1, "Error: incorrect mem at addr %h", i);
        end

        //Mem dump
        $display("Mem Dump");
        for (i = 0; i < `INSTRUCTION_BASE; i++) begin
                mem_write   = 1'b0;
                addr_in     = i;

                #5;
                phi0 = 1;
                #5;
                phi0 = 0;

                mem_unit    = d_from_mem;

                $display("addr: %h data: %h, mem_model: %h", i, mem_unit, mem_model[i]);
        end

    end

endmodule

`endif