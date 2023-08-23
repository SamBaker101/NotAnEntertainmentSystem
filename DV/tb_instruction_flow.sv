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
`include "PKG/test_program_macros.v"
`include "PKG/pkg.v"


`define SEED   		        33551
`define CYCLES 		        150

//Test selection (Only one of these should be uncommented at a time)

//FIXME I need a better way to handle my tests...
//`define SELECT_TEST `TEST_NOOPP
//`define SELECT_TEST `TEST_LDAZPG
//`define SELECT_TEST `TEST_LDAABS
//`define SELECT_TEST `TEST_LDYSTY
//`define SELECT_TEST `TEST_INDXY
//`define SELECT_TEST `TEST_ADC
//`define SELECT_TEST `TEST_ALU_LOG
//`define SELECT_TEST `TEST_ALU_ASL
`define SELECT_TEST `TEST_ALU_LSR
//`define SELECT_TEST `TEST_ALU_INC



module tb_iflow;

    ////////////////////////
    ////       TB       ////
    ////////////////////////
    reg [31:0] i, seed; 
    reg [`ADDR_WIDTH - 1 : 0] addr_in;
    reg [`REG_WIDTH - 1 : 0] d_in;
    reg manual_mem;
    reg test_carry;
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

    wire [3 : 0] pc_selector; 
    wire [3 : 0] sp_selector; 
    wire [3 : 0] add_selector; 
    wire [3 : 0] x_selector; 
    wire [3 : 0] y_selector; 
    wire [3 : 0] stat_selector;    
    wire [3 : 0] mem_selector; 
    wire [3 : 0] fetch_selector;
    wire [3 : 0] decode_selector; 
    wire [3 : 0] alu0_selector; 
    wire [3 : 0] alu1_selector;   
    
    wire [`ADDR_WIDTH - 1: 0] /*pc,*/ pc_next;
    wire [`REG_WIDTH - 1: 0] imm;

    wire we_dout;
    wire [`ADDR_WIDTH - 1 : 0] fetcher_addr;
    wire [`REG_WIDTH - 1: 0] d_to_mem1;

    reg [`ADDR_WIDTH - 1 : 0] pc;

    wire [`REG_WIDTH - 1: 0] d_from_alu;
    wire [`REG_WIDTH - 1: 0] status_from_alu, status_from_bus;
    wire [`REG_WIDTH - 1: 0] d_to_alu_0;
    wire [`REG_WIDTH - 1: 0] d_to_alu_1;
    wire [7:0] alu_opp;
    wire alu_done, update_status;

    ////////////////////////
    ////   TL Assigns   ////
    ////////////////////////
    assign we_pc 	= we[`WE_PC];
	assign we_sp 	= we[`WE_SP];
	assign we_add 	= we[`WE_ADD];
	assign we_x 	= we[`WE_X];
	assign we_y 	= we[`WE_Y];
	assign we_stat 	= update_status ? 1'b1 : we[`WE_STAT];

    assign iSTATUS = update_status ? status_from_alu : status_from_bus;

    ////////////////////////
    ////   TB Assigns   ////
    ////////////////////////
    assign d_to_mem1    = manual_mem ? d_in       : d_to_mem;
    assign addr         = manual_mem ? addr_in    : fetcher_addr;
    assign we[`WE_DOUT] = manual_mem ? mem_write : we_dout;

    assign get_next     = trigger_program;
    
    always @(phi2_int) pc      = pc_next;

    ///////////////////////
    ////    Modules    ////
    ///////////////////////

    data_bus bus(
        //IN
        .clk(phi2_int), 
        .reset_n(reset_n),
        .pc_in(oPC), 
        .sp_in(oSP), 
        .add_in(oADD), 
        .x_in(oX), 
        .y_in(oY), 
        .stat_in(oSTATUS),      
        .mem_in(d_from_mem), 
        .imm_in(imm), 
        .fetch_in(d_from_fetch), 
        .decode_in(8'hzz), 
        .alu_in(d_from_alu),            
        //SEL
        .pc_selector(pc_selector), 
        .sp_selector(sp_selector), 
        .add_selector(add_selector), 
        .x_selector(x_selector),
        .y_selector(y_selector), 
        .stat_selector(stat_selector),         
        .mem_selector(mem_selector), 
        .fetch_selector(fetch_selector), 
        .decode_selector(decode_selector), 
        .alu0_selector(alu0_selector), 
        .alu1_selector(alu1_selector),   
        //OUT
        .pc_out(iPC), 
        .sp_out(iSP), 
        .add_out(iADD), 
        .x_out(iX), 
        .y_out(iY), 
        .stat_out(status_from_bus), 
        .mem_out(d_to_mem), 
        .fetch_out(d_to_fetch), 
        .decode_out(), 
        .alu0_out(d_to_alu_0), 
        .alu1_out(d_to_alu_1) 
		);

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
		.phi1(phi1_int),
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
		.fetch_selector(fetch_selector)
		);

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
        .addr_in(fetcher_addr),
		.instruction_in(instruction), 
		.opp(alu_opp),
		.we({we_dout, we[5:0]}),    //dont ask, Ill fix this in a minute
		.instruction_ready(instruction_ready),
		.instruction_done(instruction_done),
        .alu_done(alu_done),
        //Selectors
        .pc_selector(pc_selector),  
        .sp_selector(sp_selector), 
        .add_selector(add_selector),  
        .x_selector(x_selector),  
        .y_selector(y_selector), 
        .stat_selector(stat_selector), 
        .mem_selector(mem_selector), 
        .decode_selector(decode_selector),  
        .alu0_selector(alu0_selector),  
        .alu1_selector(alu1_selector),
        .alu_update_status(update_status)    
        );

    ALU alu(.reset_n(reset_n), 
        .phi1(phi1_int),
        .phi2(phi2_int),
        .func(alu_opp), 
        .status_in(oSTATUS),
        .a(d_to_alu_0), 
        .b(d_to_alu_1), 
        .dout(d_from_alu),
        .wout(alu_done),
        .status_out(status_from_alu)
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
	
    ///////////////////////
    ////  Pin Wiggles  ////
    ///////////////////////
	initial begin : main_loop
        reg [`REG_WIDTH - 1 : 0] mem_model [`MEM_DEPTH - 1 : 0];
        reg [`REG_WIDTH - 1 : 0] inst_list [`MEM_DEPTH - `INSTRUCTION_BASE - 1 : 0];
        reg [`REG_WIDTH - 1 : 0] mem_unit;

		$dumpfile("Out/iflow.vcd");
		$dumpvars(0, tb_iflow);
        
        test_carry = 1'b0;

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
            //$display("mem_model[%d] = %h", i, mem_model[i]);

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
                    //else $display("Match at addr %0d value %h", i, mem_model[i]);
            end

        $display("Zero-ing instructions");
        for (i = 0; i < `MEM_DEPTH - `INSTRUCTION_BASE; i++) begin
            mem_model[i + `INSTRUCTION_BASE] = 8'h00;    
            
            mem_write   = 1'b1;
            addr_in     = i + `INSTRUCTION_BASE;
            d_in    = inst_list[i];

            #5;
            phi0 = 1;
            #5;
            phi0 = 0;
        end

        //PREPARE TEST
        `SELECT_TEST

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
                //else $display("Match at instruct addr %0d value %h", i + `INSTRUCTION_BASE, inst_list[i]);
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

                $write("| %h:%h = %h | ", i, mem_unit, mem_model[i]);
                if (i % 8 == 0) $display("");
        end
        
        $display("");
        
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

                if (mem_unit !== mem_model[i]) $fatal(1, "Error: incorrect mem at addr %h", i);
        end

        if (test_carry !== oSTATUS[`CARRY]) $fatal(1, "Error: Carry should be %d", test_carry);
    end

endmodule

`endif