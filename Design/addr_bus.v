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

`define OUTPUT_BUS  .out0(),             \
                    .out1(pc_out),            \
                    .out2(sp_out),            \
                    .out3(),           \
                    .out4(),             \    
                    .out5(),             \ 
                    .out6(),          \
                    .out7(mem_out),           \
                    .out8(),           \
                    .out9(fetch_out),         \
                    .out10(decode_out),       \
                    .out11(),          \
                    .out12(),           \ 
                    .out13(),           \ 
                    .out14(),           \
                    .out15()     

module addr_bus(
        //IN
        clk, reset_n,
        pc_in, sp_in, mem_in, imm_in, fetch_in, decode_in, alu_in,    //Other
        //SEL
        in_selector, out_selector, 
        //OUT
        pc_out, sp_out, mem_out, fetch_out, decode_out
		);
	
		parameter SIGNAL_WIDTH = `ADDR_WIDTH;
		parameter SELECTOR_WIDTH = 4;

        //IN
        input clk, reset_n;

        input [SIGNAL_WIDTH - 1 : 0] pc_in; 
        input [SIGNAL_WIDTH - 1 : 0] sp_in; 
        input [SIGNAL_WIDTH - 1 : 0] mem_in; 
        input [SIGNAL_WIDTH - 1 : 0] imm_in;
        input [SIGNAL_WIDTH - 1 : 0] fetch_in;
        input [SIGNAL_WIDTH - 1 : 0] decode_in;
        input [SIGNAL_WIDTH - 1 : 0] alu_in;

        //SEL
        input [SELECTOR_WIDTH - 1 : 0] in_selector; 
        input [SELECTOR_WIDTH - 1 : 0] out_selector;   
        
        //OUT
        output [SIGNAL_WIDTH - 1 : 0] pc_out; 
        output [SIGNAL_WIDTH - 1 : 0] sp_out; 
        output [SIGNAL_WIDTH - 1 : 0] mem_out; 
        output [SIGNAL_WIDTH - 1 : 0] fetch_out;
        output [SIGNAL_WIDTH - 1 : 0] decode_out; 

        wire [SIGNAL_WIDTH - 1 : 0] connect;

        mux831 #(.SIGNAL_WIDTH(`ADDR_WIDTH)) input_mux   (.clk(clk), .out(connect), .selector(in_selector),  `INPUT_BUS); 
        fan138 #(.SIGNAL_WIDTH(`ADDR_WIDTH)) output_mux  (.clk(clk), .in(connect),  .selector(out_selector), `OUTPUT_BUS);

endmodule

`endif