//This is a testbench 
//This needs updating does not currently work
`ifndef TB_6502
`define TB_6502

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30

module tb_6502_top;

    //6502 Pinouts
    reg phi0, rdy, irq_n, NMI_n, overflow_set_n, reset_n;  //IN
    wire phi1, phi2, sync, R_W_n;                            //OUT
    wire [`ADDR_WIDTH - 1 : 0] A;                            //INOUT
    wire [`REG_WIDTH - 1 : 0] D;                             //INOUT

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

	initial begin
		$dumpfile("Out/6502_test_out.vcd");
		$dumpvars(0, tb_6502_top);
	end

endmodule

`endif
