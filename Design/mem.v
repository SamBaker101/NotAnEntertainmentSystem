//Sam Baker
//07/2023
//6502 basic memory module

`ifndef MEM
`define MEM

module mem(
		clk, reset_n, we, addr, din, dout
		);
	
        parameter WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter DEPTH = 16;
        parameter BASE  = 0;

        input clk, reset_n, we;
		input [WIDTH - 1: 0] din;
        input [ADDR_WIDTH - 1 : 0] addr;
        output [WIDTH - 1 : 0] dout;

        reg [WIDTH - 1 : 0] bank [DEPTH - 1 : 0];
        wire [ADDR_WIDTH - 1 : 0] local_addr;


        assign local_addr = addr - BASE;
        assign dout = !we ? bank[local_addr] : {WIDTH{1'bz}}; 

	always @(posedge clk) begin
        if (we)
            bank[local_addr] = din;
    end
endmodule

`endif