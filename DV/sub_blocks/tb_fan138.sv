//This is a testbench 
`ifndef TB_138
`define TB_138

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30

module tb_fan138;

    reg [31:0] i, seed; 
    reg in;
    reg phi0;
    reg [2:0] selector;

    wire [7:0] out;

//Tests functionality with single bit inputs
	fan138 #(.SIGNAL_WIDTH(1)) fan (
            .clk(phi0), 
            .out0(out[0]), 
            .out1(out[1]), 
            .out2(out[2]), 
            .out3(out[3]), 
            .out4(out[4]),
            .out5(out[5]),
            .out6(out[6]),
            .out7(out[7]), 
            .selector(selector), 
            .in(in));

	initial begin
		$dumpfile("Out/fan138.vcd");
		$dumpvars(0, tb_fan138);
        
        phi0 = 0;
        seed = `SEED;

        for (i = 0; i < `CYCLES; i++) begin
            in = $urandom(seed);
            selector = $urandom(seed);

            #5;
            phi0 = 1;
            #1;
        
            if (out[selector] != in) 
                $fatal(1, "Unexpected output: input_byte = %b, selector = %0d", in, selector);

            #5;
            phi0 = 0;
            #1;
        
        end
        
    end

endmodule

`endif
