`ifndef REG
`define REG

module register(
		clk, reset_n, we, din, valid, dout
		);
	
        parameter REG_WIDTH = `REG_WIDTH;

        input clk, reset_n, we;
		input  [REG_WIDTH - 1 : 0] din;
        output valid;
        output reg [REG_WIDTH - 1 : 0] dout;

	always @(posedge clk) begin
        if (reset_n == 0)
            dout = 0;
        else if (we)
            dout = din;
        else   
            dout = dout;
    end
endmodule

`endif