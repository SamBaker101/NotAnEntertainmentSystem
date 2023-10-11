//Sam Baker
//10/2023
//6502 Top Level Testbench

`ifndef TB_6502
`define TB_6502

`timescale 1ns/1ns
`define TEST_RUN

`include "PKG/pkg.v"

typedef bit [`REG_WIDTH - 1 : 0] tb_register; 

tb_register mem_model [`MEM_DEPTH - 1 : 0];

interface mem_over_if (input clk, reset_n); 
    logic [`REG_WIDTH - 1 : 0] test_mem [`MEM_DEPTH - 1 : 0];
    logic [`REG_WIDTH - 1 : 0] real_mem [`MEM_DEPTH - 1 : 0];
    logic mem_override;

    modport TB (input  real_mem, clk, reset_n, output test_mem, mem_override);
    modport DUT(output real_mem,               input  test_mem, mem_override, clk, reset_n);

    task override_real_mem();
        if (reset_n) $display("ERROR: cannot overwrite mem while not in reset");
        else begin
            for (int i = 0; i < `MEM_DEPTH; i++) begin
                test_mem[i] <= mem_model[i];
            end
            mem_override <= 1'b1;
            #20;
            mem_override <= 1'b0;
        end
    endtask : override_real_mem
endinterface



module tb_6502_top;

    int seed = `SEED;

    //6502 Pinouts
    reg phi0, rdy, irq_n, NMI_n, overflow_set_n, reset_n;  //IN
    wire phi1, phi2, sync, R_W_n;                            //OUT
    wire [`ADDR_WIDTH - 1 : 0] A;                            //INOUT
    wire [`REG_WIDTH - 1 : 0] D;                             //INOUT
    
    //MEMORY_MANAGEMENT
    wire [`REG_WIDTH - 1 : 0] real_mem_monitor [`MEM_DEPTH - 1 : 0];

    wire [`REG_WIDTH - 1 : 0] d_to_mem, d_from_mem;

    //ASSIGNS
    assign D        = (R_W_n) ? d_from_mem  : 8'hZZ;
    assign d_to_mem = (R_W_n) ? 8'hZZ       : D;

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
        .override_mem(override_mem),
        .mem_override_in(mem_model),
        .mem_monitor(real_mem_monitor)
        );

    //LOGIC
    always @(*) begin
        #5;
        phi0 = ~phi0;
    end

    mem_over_if mem_override_if(phi0, reset_n);

    //RUN TEST
	initial begin
		$dumpfile("Out/6502_test_out.vcd");
		$dumpvars(0, tb_6502_top);
	
        $display("Starting tb_6502_top \t");

        phi0 = 1'b1;
        reset_n = 1'b0;
        #50;
        zero_mem_model();
        randomize_mem_model(0, `INSTRUCTION_BASE);
        mem_override_if.override_real_mem();

        reset_n = 1'b1;
        #500;
        
        dump_mem(0, 64);

    end

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

    task dump_mem(int start = 0, int finish = `MEM_DEPTH);
        int i;
        for (i = start; i < finish; i++) begin
            $write("| %h:%h = %h | ", i, real_mem_monitor[i], mem_model[i]);
            if (i % 8 == 0) $display("");
        end
    endtask : dump_mem

endmodule
`endif
