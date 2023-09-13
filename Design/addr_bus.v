//Sam Baker
//07/2023
//Data Bus

//This isn't correct but should keep things straightforward and uniform 
//until I get the logic correct.

`ifndef BUS
`define BUS

//This makes life easier :)
`define INPUT_BUS   .in0(8'h0),             \
                    .in1(pc_in),            \
                    .in2(sp_in),            \
                    .in3(38'hzz),           \
                    .in4(8'hzz),             \    
                    .in5(8'hzz),             \ 
                    .in6(8'hzz),          \
                    .in7(mem_in),           \
                    .in8(imm_in),           \
                    .in9(fetch_in),         \
                    .in10(decode_in),       \
                    .in11(alu_in),          \
                    .in12(8'hzz),           \ 
                    .in13(8'hFF),           \ 
                    .in14(8'hzz),           \
                    .in15(8'hzz)     

`define OUTPUT_BUS     .out0(8'h0),             \
                    .out1(pc_out),            \
                    .out2(sp_out),            \
                    .out3(38'hzz),           \
                    .out4(8'hzz),             \    
                    .out5(8'hzz),             \ 
                    .out6(8'hzz),          \
                    .out7(mem_out),           \
                    .out8(8'hzz),           \
                    .out9(fetch_out),         \
                    .out10(decode_out),       \
                    .out11(8'hzz),          \
                    .out12(8'hzz),           \ 
                    .out13(8'hFF),           \ 
                    .out14(8'hzz),           \
                    .out15(8'hzz)     

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

        mux831 input_mux    (.clk(clk), .out(connect), .selector(in_selector),  `INPUT_BUS); 
        fan138 output_mux   (.clk(clk), .in(connect),  .selector(out_selector), `OUTPUT_BUS);

endmodule

`endif