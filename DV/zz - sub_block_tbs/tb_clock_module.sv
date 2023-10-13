//This is a testbench 
//This needs updating does not currently work
`ifndef TB_CM
`define TB_CM

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30

module tb_clock_module;

    //6502 Pinouts
    reg phi0, reset_n;
    wire phi1, phi2;                          //INOUT

clock_module cm(
		.phi0(phi0), 
        .reset_n(reset_n),
		.phi1(phi1), 
        .phi2(phi2)
		);

	initial begin
		$dumpfile("Out/clock_module.vcd");
		$dumpvars(0, tb_clock_module);

        phi0 = 0;
        
        #5;
        phi0 = 1;
        #1;
        if ((phi0 != phi2)|(phi0 == phi1)) $fatal(1, "Clocking incorrect");

        #5;
        phi0 = 0;
        #1;
        if ((phi0 != phi2)|(phi0 == phi1)) $fatal(1, "Clocking incorrect");

        #5;
        phi0 = 1;
        #1;
        if ((phi0 != phi2)|(phi0 == phi1)) $fatal(1, "Clocking incorrect");
    end

endmodule

`endif
