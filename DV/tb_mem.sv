//Sam Baker
//07/2023
//Memory TB

`ifndef TB_mem
`define TB_mem

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30
`define MEM_DEPTH   32

module tb_mem;

    reg [31:0] i, seed; 

    reg phi0, reset_n, we;
    reg [`REG_WIDTH - 1 : 0] din;
    reg [`ADDR_WIDTH - 1 : 0] addr;

    wire [`REG_WIDTH - 1 : 0] dout;

//Tests functionality with single bit inputs
    mem #(.DEPTH(`MEM_DEPTH))
    mem_test(
		.clk(phi0), 
        .reset_n(reset_n), 
        .we(we), 
        .addr(addr), 
        .din(din), 
        .dout(dout)
		);

	initial begin
		$dumpfile("Out/mem.vcd");
		$dumpvars(0, tb_mem);
        
        phi0 = 0;
        seed = `SEED;

        for (i = 0; i < `CYCLES; i++) begin
            din = $urandom(seed);
            addr = $urandom(seed) % `MEM_DEPTH;
            we = 1;

            #5;
            phi0 = 1;
            #5;
            phi0 = 0;
        
            we = 0;
            
            #5;
            phi0 = 1;
            #5;
            phi0 = 0;

            if (dout != din) $fatal(1, "Write/Read not completed as expected");
            else $display("addr: %h  data: %h", i, dout);
        end
        
    end

endmodule

`endif