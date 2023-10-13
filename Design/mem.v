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
		
        //Only in test environments
        `ifdef TEST_RUN
            ,input override_mem
            ,input [`REG_WIDTH - 1 : 0] mem_override_in [`MEM_DEPTH - 1 : 0]
            ,output reg [`REG_WIDTH - 1 : 0] bank [`MEM_DEPTH - 1 : 0]
        `endif
        );
	
    parameter WIDTH = `REG_WIDTH;
    parameter ADDR_WIDTH = `ADDR_WIDTH;
    parameter DEPTH = 16;
    parameter BASE  = 0;

    `ifndef TEST_RUN
        reg [WIDTH - 1 : 0] bank [DEPTH - 1 : 0];
    `endif
    
    wire [ADDR_WIDTH - 1 : 0] local_addr;

    assign local_addr = addr - BASE;
    assign dout = !we ? bank[local_addr] : {WIDTH{1'bz}}; 

    //This will only be included in test environments to allow override and monitor of mem
    `ifdef TEST_RUN
        //Override bank
        always @(posedge override_mem) begin
            if (!reset_n) begin 
                for (int i = 0; i < DEPTH; i++) begin
                    bank[i] = mem_override_in[i];
                end
            end

            for (int i = 0; i < 8; i++) begin
                $write("|%h: %h = %h | ", i, mem_override_in[i], bank[i]);
            end
            $display("\n");

        end
    `endif


	always @(posedge clk) begin
        if (we) begin
            bank[local_addr] = din;
        end
    end
endmodule

`endif