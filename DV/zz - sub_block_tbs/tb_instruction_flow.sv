//Sam Baker
//07/2023
//Instruction flow test bench
//This test bench loads a dummy mem with random data and user program
//Connects mem to fetcher and decoder logic
//Includes necessary mem, reg, switch, mux and fan modules

//FIXME:
// Remove get_next signal between decoder and fetcher (use instruction_ready toggling)
// Set up logic such that mem can be filled with data (outside of chip logic) while chip is in reset
// Testing currently only really tests instructions in isolation, wierd issues may appear with multiple opps in a single program

`ifndef TB_IFLOW
`define TB_IFLOW

`timescale 1ns/1ns
`include "PKG/test_program_macros.v"
`include "PKG/pkg.v"

`define CYCLES 		        75

module tb_iflow;

    ////////////////////////
    ////       TB       ////
    ////////////////////////
    reg [31:0] i, seed; 
    reg [`ADDR_WIDTH - 1 : 0] addr_in;
    reg [`REG_WIDTH - 1 : 0] d_in;
    reg manual_mem;
    
    reg [`REG_WIDTH - 1 : 0] test_stat;
    reg [`REG_WIDTH - 1 : 0] capture_stat;
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
    wire [`ADDR_WIDTH - 1 : 0] addr_to_mem_with_mm;
    wire [`REG_WIDTH - 1 : 0] d_to_fetch, d_from_fetch;

    wire get_next, ask_next, instruction_done;
    wire instruction_ready;

    wire [`WE_WIDTH - 1 : 0] we;
    wire we_pc, we_sp, we_add, we_x, we_y, we_stat;
	
	wire [`ADDR_WIDTH - 1: 0] iPC, oPC;
	wire [`REG_WIDTH - 1: 0] iSP, oSP, sp_from_bus;
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
    
    wire [`ADDR_WIDTH - 1: 0] pc, pc_next, jump_pc;
    wire [`REG_WIDTH - 1: 0] imm_to_bus, imm_to_decoder;

    wire we_dout;
    wire [`REG_WIDTH - 1: 0] d_to_mem1;

    wire [`REG_WIDTH - 1: 0] d_from_alu;
    wire [`REG_WIDTH - 1: 0] status_from_alu, status_from_bus;
    wire [`REG_WIDTH - 1: 0] d_to_alu_0;
    wire [`REG_WIDTH - 1: 0] d_to_alu_1;
    wire [`REG_WIDTH - 1: 0] d_to_decode;
    wire [7:0] alu_opp;
    wire alu_done, update_status, invert_alu_b;
    wire carry_in;


    //addr_bus connections
    //IN
    wire [`ADDR_WIDTH - 1: 0] sp_to_abus;
    wire [`ADDR_WIDTH - 1: 0] addr_from_fetch;
    wire [`ADDR_WIDTH - 1: 0] addr_from_decode;

    //SEL
    wire [3 : 0] in_selector; 
    wire [3 : 0] out_selector; 
    //OUT
    wire [`ADDR_WIDTH - 1: 0] addr_from_bus;

    assign sp_to_abus = oSP + `STACK_BASE;
    
    ////////////////////////
    ////   TL Assigns   ////
    ////////////////////////
    assign we_pc 	= 1'b1;
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
    assign addr_to_mem_with_mm  = manual_mem ? addr_in    : addr_from_bus;
    assign we[`WE_DOUT] = manual_mem ? mem_write : we_dout;

    assign get_next     = trigger_program;

    assign iPC = (jump_pc) ? jump_pc : pc_next;
    assign iSP = sp_from_bus + `STACK_BASE;

    string test_name = "UNDEF";
    ///////////////////////
    ////    Modules    ////
    ///////////////////////

    addr_bus abus(
        //IN
        .clk(phi1_int), 
        .reset_n(reset_n),
        .pc_in(oPC), 
        .sp_in(sp_to_abus), 
        .mem_in({8'h00, d_from_mem}), 
        .imm_in({8'h00, imm_to_bus}), 
        .fetch_in(addr_from_fetch), 
        .decode_in(addr_from_decode), 
        .alu_in({8'h00, d_from_alu}),    //Other
        //SEL
        .in_selector(in_selector), 
        //OUT
        .out(addr_from_bus)
		);

    data_bus bus(
        //IN
        .clk(phi2_int), 
        .reset_n(reset_n),
        .pc_in(oPC[7:0]), 
        .sp_in(oSP), 
        .add_in(oADD), 
        .x_in(oX), 
        .y_in(oY), 
        .stat_in(oSTATUS),      
        .mem_in(d_from_mem), 
        .imm_in(imm_to_bus), 
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
        //.pc_out(iPC), 
        .sp_out(iSP), 
        .add_out(iADD), 
        .x_out(iX), 
        .y_out(iY), 
        .stat_out(status_from_bus), 
        .mem_out(d_to_mem), 
        .fetch_out(d_to_fetch), 
        .decode_out(d_to_decode), 
        .alu0_out(d_to_alu_0), 
        .alu1_out(d_to_alu_1) 
		);

//Tests functionality with single bit inputs
    mem #(.DEPTH(`MEM_DEPTH)) mem_test(
		.clk(phi2_int), 
        .reset_n(reset_n), 
        .we(we[`WE_DOUT]), 
        .addr(addr_to_mem_with_mm), 
        .din(d_to_mem1), 
        .dout(d_from_mem)
		);

	fetcher fetch(
		.phi1(phi1_int),
        .phi2(phi2_int), 
		.reset_n(reset_n), 
		.get_next(get_next), 
		.pc(oPC), 
        .sp(oSP),
		.data_in(d_to_fetch), 
		.instruction_out(instruction), 
		.pc_next(pc_next), 
		.addr(addr_from_fetch), 
		.instruction_ready(instruction_ready),
        .instruction_done(instruction_done),
		.reg_out(d_from_fetch),
        .imm(imm_to_decoder),
		.fetch_selector(fetch_selector)
		);

	decoder decode(
		.clk(phi1_int), 
		.reset_n(reset_n), 
        .addr_in(addr_from_bus),
		.instruction_in(instruction), 
		.opp(alu_opp),
		.we({we_dout, we[5:0]}),    //dont ask, Ill fix this in a minute
        .carry_in(carry_in),
		.instruction_ready(instruction_ready),
		.instruction_done(instruction_done),
        .alu_done(alu_done),
        .status_in(oSTATUS),
        .invert_alu_b(invert_alu_b),
        .imm_in(imm_to_decoder),
        .imm_out(imm_to_bus),
        .pc_in(oPC),
        .data_in(d_to_decode),
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

        .addr_in_selector(in_selector), 

        .alu_update_status(update_status),   
        .jump_pc(jump_pc)                       
        );

    ALU alu(.reset_n(reset_n), 
        .phi1(phi1_int),
        .phi2(phi2_int),
        .func(alu_opp), 
        .status_in(oSTATUS),
        .carry_in(carry_in),
        .invert(invert_alu_b),
        .a_in(d_to_alu_0), 
        .b_in(d_to_alu_1), 
        .dout(d_from_alu),
        .wout(alu_done),
        .status_out(status_from_alu)
        );

	//Regs
	register #(.BIT_WIDTH(16), .RESET_VECTOR(`INSTRUCTION_BASE)) PC (.clk(phi2_int), .reset_n(reset_n), .we(we_pc), .din(iPC), .dout(oPC));
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
        
        test_stat = 8'h00;

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
        $write("Checking random data loaded to memory \t");
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

        $write("Zero-ing instructions \t");
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
        #5;
        reset_n = 1'b1;

        trigger_program = 1'b1;
        #5;
        phi0 = 1;
        #5;
        phi0 = 0;
        #5;
        trigger_program = 1'b0;

        //Spin the clock
        //$write("Spinning the clock \t");
        for (i = 0; i < `CYCLES; i++) begin
                    #5;
                    phi0 = 1;
                    #5;
                    phi0 = 0;
        end

        capture_stat = oSTATUS;    
        manual_mem = 1'b1;
        reset_n = 1'b0;

`ifdef MEM_DUMP
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
`endif

        $display("");


`ifdef TEST_CHECK_CARRY        
        if (test_stat[`CARRY] !== capture_stat[`CARRY]) $fatal(1, "\n##### ERROR ##### \tTEST: %s \t Time: %d \tCarry is %d should be %d", test_name, $time, oSTATUS[`CARRY], test_stat[`CARRY]);
`endif

`ifdef TEST_CHECK_ZERO        
        if (test_stat[`ZERO] !== capture_stat[`ZERO]) $fatal(1, "\n##### ERROR ##### \tTEST: %s \t Time: %d \tZero is %d should be %d", test_name, $time, oSTATUS[`ZERO], test_stat[`ZERO]);
`endif

`ifdef TEST_CHECK_NEG        
        if (test_stat[`NEG] !== capture_stat[`NEG]) $fatal(1, "\n##### ERROR ##### \tTEST: %s \t Time: %d \tNeg is %d should be %d", test_name, $time, oSTATUS[`NEG], test_stat[`NEG]);
`endif



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

                if (mem_unit !== mem_model[i]) $fatal(1, "\n##### ERROR ##### \nTEST: %s \n Time: %d \nincorrect mem at addr %h", test_name, $time, i);
        end

        
    end

endmodule

`endif