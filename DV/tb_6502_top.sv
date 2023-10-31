//Sam Baker
//10/2023
//6502 Top Level Testbench

`ifndef TB_6502
`define TB_6502

`timescale 1ns/1ns
`define TEST_RUN

`include "PKG/pkg.v"

typedef logic [`REG_WIDTH - 1 : 0] tb_register; 

//FIXME: These are globals as a work around due to limited SystemVerilog support in iVerilog
tb_register mem_model [`MEM_DEPTH - 1 : 0];         //Belongs to mem_over_if.sv            
byte fw [`MAX_FW_SIZE];                             //Belongs to firmware.sv
reg [7:0] stat_model;

module tb_6502_top;

    int seed = `SEED;
    wire [7:0] stat_tap; 

    //6502 Pinouts
    reg phi0, rdy, irq_n, NMI_n, overflow_set_n, reset_n;  //IN
    wire phi1, phi2, sync, R_W_n;                            //OUT
    wire [`ADDR_WIDTH - 1 : 0] A;                            //INOUT
    wire [`REG_WIDTH - 1 : 0] D;                             //INOUT
    
    //MEMORY_MANAGEMENT
    wire [`REG_WIDTH - 1 : 0] d_to_mem, d_from_mem;

    //ASSIGNS
    assign D        = (R_W_n) ? d_from_mem  : 8'hZZ;
    assign d_to_mem = (R_W_n) ? 8'hZZ       : D;
    assign stat_tap = cpu.oSTATUS;

    //MODULES
    cpu_top cpu(
	    .phi0(phi0), 
        .reset_n(reset_n),
		.rdy(rdy), 
        .irq_n(irq_n), 
        .NMI_n(NMI_n), 
        .overflow_set_n(overflow_set_n),

        .phi1(phi1),
        .phi2(phi2),
        .sync(sync), 
        .R_W_n(R_W_n),

        .D(D),
        .A(A)
		);

    mem  #(.DEPTH(`MEM_DEPTH)) mem_test(
        .clk(!phi0), 
        .reset_n(reset_n), 
        .we(!R_W_n),
        .din(d_to_mem),
        .addr(A),
        .dout(d_from_mem),

        //Only exist for tbs
        .override_mem(mem_override_if.mem_override),
        .mem_override_in(mem_override_if.test_mem),
        .mem_monitor(mem_override_if.flat_mem)
        );

    //LOGIC
    mem_over_if mem_override_if(phi0, reset_n);

    initial begin : clock
        forever begin
            phi0 = 0;
            #1;
            phi0 = ~phi0;
            #1;
        end
    end : clock

    //RUN TEST
	initial begin : main_test
        firmware test_fw;
        basic_test this_test;

        $dumpfile("Out/6502_test_out.vcd");
		$dumpvars(0, tb_6502_top);
        
        $display("Starting tb_6502_top \t");

        reset_n = 1'b0;
        #50;
        zero_mem_model();
        randomize_mem_model(0, `INSTRUCTION_BASE);

        this_test = new(`TEST_NAME);
        
        ///LOAD PROGRAM
        test_fw = new(`TEST_NAME);   
        test_fw.open_file();
        test_fw.read_fw();
        test_fw.load_fw();
        //test_fw.print_fw();

        mem_override_if.override_real_mem();

        this_test.modify_mem_model();

        reset_n = 1'b1;
        #500;
        
        $display("### MEM_DUMP: %s ###", `TEST_NAME);
        $display("STATUS: Real - %h : Model - %h", stat_tap, stat_model);
        $display("MEM_SAMPLE");
        mem_override_if.dump_mem(0, 32);

        if ((`TEST_NAME == "stack_test") || (`TEST_NAME == "set_clear_test")) begin    
            $display("STACK_SAMPLE");
            mem_override_if.dump_mem(`STACK_BASE, `STACK_BASE + 16);
        end

        $display("INSTRUCTION_SAMPLE");
        mem_override_if.dump_mem(`INSTRUCTION_BASE, `INSTRUCTION_BASE + 32);

        //CHECKS
        mem_override_if.check_mem();

        this_test.check_stat(stat_tap, `CARRY);  
        this_test.check_stat(stat_tap, `ZERO); 
        this_test.check_stat(stat_tap, `NEG); 

        $finish;
    end : main_test

    //TASKS:
    task zero_mem_model(bit zero_model = 1, bit zero_real = 0);
        int i;
        for (i = 0; i < `MEM_DEPTH; i++) begin
            mem_model[i] = 0;
        end
    endtask : zero_mem_model


    task randomize_mem_model(int start = 0, int finish = `MEM_DEPTH);
        int i;
        for (i = start; i < finish; i++) begin
            mem_model[i] = $urandom(); 
        end
    endtask : randomize_mem_model

endmodule
`endif
