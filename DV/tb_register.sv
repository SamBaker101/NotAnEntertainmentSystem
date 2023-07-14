//This is a testbench 
`ifndef TB_REG
`define TB_REG

`timescale 1ns/1ns
`include "PKG/pkg.v"

`define SEED   		33551
`define CYCLES 		30

module tb_reg;

    reg [31:0] i, seed; 
    reg phi0, reset_n, we;
    reg [`REG_WIDTH - 1 : 0] din;

    wire valid;
    wire [`REG_WIDTH - 1 : 0] dout;

    reg [`REG_WIDTH - 1 : 0] dout_last;

register reg0(
    .clk(phi0), 
    .reset_n(reset_n), 
    .we(we), 
    .din(din), 
    .dout(dout));

	initial begin
		$dumpfile("Out/register.vcd");
		$dumpvars(0, tb_reg);
        
        phi0 = 0;
        seed = `SEED;
        dout_last = 8'h00;

        for (i = 0; i < `CYCLES; i++) begin
            din = $urandom(seed);
            we = $urandom(seed);
            dout_last = dout;

            #5;
            phi0 = 1;
            #1;
        
            if(we ? (din != dout):(dout != dout_last))
                $fatal(1, "Reg Load Failed on cycle %d", i);

            #5;
            phi0 = 0;
            #1;
        
        end
    end

endmodule

`endif