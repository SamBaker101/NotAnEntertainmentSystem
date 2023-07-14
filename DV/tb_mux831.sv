//This is a testbench 
//This needs updating does not currently work
`ifndef TB_831
`define TB_831

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30

module tb_mux831;

    reg [31:0] i, seed; 

    reg [7:0] in;
    reg phi0;
    reg [2:0] selector;

    wire out;

//Tests functionality with single bit inputs
	mux831 #(.SIGNAL_WIDTH(1)) mux (
            .clk(phi0), 
            .in0(in[0]), 
            .in1(in[1]), 
            .in2(in[2]), 
            .in3(in[3]), 
            .in4(in[4]),
            .in5(in[5]),
            .in6(in[6]),
            .in7(in[7]), 
            .selector(selector), 
            .out(out));

	initial begin
		$dumpfile("Out/mux831.vcd");
		$dumpvars(0, tb_mux831);
        
        phi0 = 0;
        seed = `SEED;

        for (i = 0; i < `CYCLES; i++) begin
            in = $urandom(seed);
            selector = $urandom(seed);

            #5;
            phi0 = 1;
            #1;
        
            if (out != in[selector]) 
                $fatal(1, "Unexpected output: input_byte = %b, selector = %0d", in, selector);

            #5;
            phi0 = 0;
            #1;
        
        end
        
    end

endmodule

`endif
