//Sam Baker
//07/2023
//Addr Bus

//This isn't correct but should keep things straightforward and uniform 
//until I get the logic correct.

`ifndef ABUS
`define ABUS

//This makes life easier :)
`define INPUT_BUS   .in0(16'h0),             \
                    .in1(pc_in),            \
                    .in2(sp_in),            \
                    .in3(16'hzzzz),           \
                    .in4(16'hzzzz),             \    
                    .in5(16'hzzzz),             \ 
                    .in6(16'hzzzz),          \
                    .in7(mem_in),           \
                    .in8(imm_in),           \
                    .in9(fetch_in),         \
                    .in10(decode_in),       \
                    .in11(alu_in),          \
                    .in12(16'hzzzz),           \ 
                    .in13(16'hFFFF),           \ 
                    .in14(16'hzzzz),           \
                    .in15(16'hzzzz)     

module addr_bus(
        //IN
        input clk, reset_n,

        input [SIGNAL_WIDTH - 1 : 0] pc_in, 
        input [SIGNAL_WIDTH - 1 : 0] sp_in, 
        input [SIGNAL_WIDTH - 1 : 0] mem_in, 
        input [SIGNAL_WIDTH - 1 : 0] imm_in,
        input [SIGNAL_WIDTH - 1 : 0] fetch_in,
        input [SIGNAL_WIDTH - 1 : 0] decode_in,
        input [SIGNAL_WIDTH - 1 : 0] alu_in,

        //SEL
        input [SELECTOR_WIDTH - 1 : 0] in_selector, 
        input [SELECTOR_WIDTH - 1 : 0] out_selector,   
        
        //OUT
        output [SIGNAL_WIDTH - 1 : 0] out
		);
	
		parameter SIGNAL_WIDTH = `ADDR_WIDTH;
		parameter SELECTOR_WIDTH = 4;



        mux831 #(.SIGNAL_WIDTH(`ADDR_WIDTH)) input_mux   (.clk(clk), .out(out), .selector(in_selector),  `INPUT_BUS); 
endmodule

`endif