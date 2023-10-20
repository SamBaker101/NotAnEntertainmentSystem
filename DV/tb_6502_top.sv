//Sam Baker
//10/2023
//6502 Top Level Testbench

`ifndef TB_6502
`define TB_6502

`timescale 1ns/1ns
`define TEST_RUN

`include "PKG/pkg.v"
        
typedef logic [`REG_WIDTH - 1 : 0] tb_register; 

tb_register mem_model [`MEM_DEPTH - 1 : 0];            //TODO: This could probably be part of the mem_if

module tb_6502_top;

    int seed = `SEED;

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
    always @(*) begin
        #5;
        phi0 = ~phi0;
    end

    mem_over_if mem_override_if(phi0, reset_n);

    //RUN TEST
	initial begin
        string test_name, fname;
        int fw_file, t;
        bit break_out;
        tb_register temp;
        tb_register fw [$];
        tb_register [`MAX_FW_SIZE] fline;

        $dumpfile("Out/6502_test_out.vcd");
		$dumpvars(0, tb_6502_top);
        
        $display("Starting tb_6502_top \t");

        phi0 = 1'b1;
        reset_n = 1'b0;
        #50;
        zero_mem_model();
        randomize_mem_model(0, `INSTRUCTION_BASE);

        //LOAD PROGRAM
        //TODO: This will be moved into its own container (class?) once I've got the logic sorted
        //FIXME: This currently returns nothing, lines are captured but are parsed incorrectly
        test_name = "load_store_test"; //TODO: generalize this in makefile
        fname = $sformatf("Out/%s.hex", test_name); 

        $display("%s : %s", test_name, fname);

        fw_file = $fopen(fname, "r");
        if (!fw_file) $display("ERROR opening file");

        //Would you believe this version of iverilog doesnt support break or continue...
        while ($fgets(fline, fw_file)) begin
            break_out = 0;
            $display("PARSING: %s", fline);

            for (int i = 1; i < `MAX_FW_SIZE; i ++) begin
                if (break_out == 0) begin;
                    if ((fline[i] == ":") || (fline[i+1] == ":")) break_out = 1;
                    else begin
                        $display(" %c%c", fline[i], fline[i+1]);
                        convert_instruction(fline[i+1], fline[i], temp);
                        fw.push_front(temp);
                        i++;
                    end
                end
            end
        end
        
        $display(" ");
        foreach(fw[i]) begin
            $display("%0d : %h", i, fw[i]);
        end
        ///END LOAD


        mem_override_if.override_real_mem();

        reset_n = 1'b1;
        #500;
        
        $display("MEM_SAMPLE");
        mem_override_if.dump_mem(0, 16);
        $display("INSTRUCTION_SAMPLE");
        mem_override_if.dump_mem(`INSTRUCTION_BASE, `INSTRUCTION_BASE + 8);

    end

    task convert_instruction(input [7:0] high_in, [7:0] low_in, output [7:0] instruction_byte);
        bit [3:0] high_nib; 
        bit [3:0] low_nib;
        
        //$display("high_in %c, low in %c", high_in, low_in);

        high_nib =  (high_in < 58) ? high_in - 48 : 
                    (high_in < 71) ? high_in - 55 :
                    high_in - 87;

        low_nib =   (low_in < 58) ? low_in - 48 : 
                    (low_in < 71) ? low_in - 54 :
                    low_in - 86;

        //$display("high_nib %h, low nib %h", high_nib, low_nib);

        instruction_byte = (high_nib << 4) + low_nib; 
        //$display("Instruction %h", instruction_byte);
    endtask

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
