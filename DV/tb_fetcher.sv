//Sam Baker
//07/2023
// Fetcher is covered by instruction flow testbench so I have not
// completed this one yet

`ifndef TB_FETCH
`define TB_FETCH

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30

module tb_fd;
    reg phi1_int, reset_n;


	fetcher fetch(
		.clk(phi1_int), 
		.reset_n(reset_n), 
		.get_next(get_next), 
		.pc(oPC), 
		.data_in(fetch_reg_in), 
		.instruction_out(instruction), 
		.pc_next(iPC), 
		.we_pc(we_pc), 
		.addr(A), 
		.instruction_ready(instruction_ready),
		.reg_out(fetch_reg_out),
		.fetch_source_selector(fetch_selector)
		);


endmodule

`endif