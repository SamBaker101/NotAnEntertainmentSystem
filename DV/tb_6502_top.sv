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
        tb_register [`MEM_DEPTH - `INSTRUCTION_BASE] fline;

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
        test_name = "load_store_test"; //TODO: generalize this in makefile
        fname = $sformatf("DV/test_firmware/%s.txt", test_name); 

        $display("%s : %s", test_name, fname);

        fw_file = $fopen(fname, "r");
        if (!fw_file) $display("ERROR opening file");

        //Would you believe this version of iverilog doesnt support break or continue...
        while ($fgets(fline, fw_file)) begin
            break_out = 0;
            $write("PARSING: %s", fline);

            for (int i = 0; i < `MEM_DEPTH - `INSTRUCTION_BASE; i ++) begin
                if (break_out == 0) begin;
                    if ((fline[i] == "#") || (fline[i] == "\n")) begin
                        break_out = 1;
                    end else if (fline[i] == " ") begin
                    end else begin
                        convert_instruction(fline[i], fline[i+1], temp);
                        fw.push_back(temp);
                        i++;                  
                    end
                end
            end
        end
            
        foreach(fw[i]) begin
            $display("%0d : %h", i, fw[i]);
        end

        mem_override_if.override_real_mem();

        reset_n = 1'b1;
        #500;
        
        mem_override_if.dump_mem(`INSTRUCTION_BASE, `INSTRUCTION_BASE + 8);

    end

    task convert_instruction(input high_in, low_in, output [7:0] instruction_byte);
        bit [3:0] high_nib; 
        bit [3:0] low_nib;

        high_nib =  (high_in < 58) ? high_in - 48 : 
                    (high_in < 71) ? high_in - 55 :
                    high_in - 87;

        low_nib =   (high_in < 58) ? high_in - 48 : 
                    (high_in < 71) ? high_in - 55 :
                    high_in - 87;

        instruction_byte = (high_nib << 4) + low_nib;
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
