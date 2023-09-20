//Sam Baker
//07/2023
//6502 register module

`ifndef REG
`define REG

module register #(parameter BIT_WIDTH = `REG_WIDTH,
                    parameter RESET_VECTOR = {BIT_WIDTH{1'b0}})
        (
		input clk, reset_n, we,
		input  [BIT_WIDTH - 1 : 0] din,
        output valid,
        output reg [BIT_WIDTH - 1 : 0] dout
		);

	always @(posedge clk) begin
        if (reset_n == 0)
            dout = RESET_VECTOR;
        else if (we)
            dout = din;
        else   
            dout = dout;
    end
endmodule

`endif