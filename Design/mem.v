//Sam Baker
//07/2023
//6502 basic memory module

`ifndef MEM
`define MEM

module mem(
	    input clk, reset_n, we
		,input [WIDTH - 1: 0] din
        ,input [ADDR_WIDTH - 1 : 0] addr
        ,output [WIDTH - 1 : 0] dout
		
        `ifdef TEST_RUN
            ,input override_mem
            ,input [`REG_WIDTH - 1 : 0] mem_override_in [`MEM_DEPTH - 1 : 0]
            ,output wire [`REG_WIDTH - 1 : 0] mem_monitor [`MEM_DEPTH - 1 : 0]
        `endif
        );
	
    parameter WIDTH = `REG_WIDTH;
    parameter ADDR_WIDTH = `ADDR_WIDTH;
    parameter DEPTH = 16;
    parameter BASE  = 0;

    reg [WIDTH - 1 : 0] bank [DEPTH - 1 : 0];
    wire [ADDR_WIDTH - 1 : 0] local_addr;

    assign local_addr = addr - BASE;
    assign dout = !we ? bank[local_addr] : {WIDTH{1'bz}}; 

    `ifdef TEST_RUN
        assign mem_monitor = bank;

        always @(posedge override_mem) begin
            if (!reset_n) begin 
                for (int i = 0; i < DEPTH; i++) begin
                    bank[i] = mem_override_in[i];
                end
            end
        end
    `endif


	always @(posedge clk) begin
        if (we) begin
            bank[local_addr] = din;
            //$display("WE addr: %h local_addr: %h, din %h, bank: %h", addr, local_addr, din, bank[local_addr]);
        end
    end
endmodule

`endif