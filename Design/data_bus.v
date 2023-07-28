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
                    .in3(add_in),           \
                    .in4(x_in),             \    
                    .in5(y_in),             \ 
                    .in6(stat_in),          \
                    .in7(mem_in),           \
                    .in8(imm_in),           \
                    .in9(fetch_in),         \
                    .in10(decode_in),       \
                    .in11(alu_in),          \
                    .in12(8'hzz),           \ 
                    .in13(8'hzz),           \ 
                    .in14(8'hzz),           \
                    .in15(8'hzz)     

module data_bus(
        //IN
        clk, reset_n,
        pc_in, sp_in, add_in, x_in, y_in, stat_in,      //Regs
        mem_in, imm_in, fetch_in, decode_in, alu_in,    //Other
        //SEL
        pc_selector, sp_selector, add_selector, x_selector, y_selector, stat_selector,      //Regs
        mem_selector, fetch_selector, decode_selector, alu0_selector, alu1_selector,        //Other
        //OUT
        pc_out, sp_out, add_out, x_out, y_out, stat_out,        //Regs
        mem_out, fetch_out, decode_out, alu0_out, alu1_out,     //Other
		);
	
		parameter SIGNAL_WIDTH = `REG_WIDTH;
		parameter SELECTOR_WIDTH = 4;

        //IN
        input [SIGNAL_WIDTH - 1 : 0] pc_in; 
        input [SIGNAL_WIDTH - 1 : 0] sp_in; 
        input [SIGNAL_WIDTH - 1 : 0] add_in; 
        input [SIGNAL_WIDTH - 1 : 0] x_in;
        input [SIGNAL_WIDTH - 1 : 0] y_in; 
        input [SIGNAL_WIDTH - 1 : 0] stat_in;      
        input [SIGNAL_WIDTH - 1 : 0] mem_in; 
        input [SIGNAL_WIDTH - 1 : 0] imm_in; 
        input [SIGNAL_WIDTH - 1 : 0] fetch_in; 
        input [SIGNAL_WIDTH - 1 : 0] decode_in; 
        input [SIGNAL_WIDTH - 1 : 0] alu_in;
        
        //SEL
        input [SELECTOR_WIDTH - 1 : 0] pc_selector; 
        input [SELECTOR_WIDTH - 1 : 0] sp_selector; 
        input [SELECTOR_WIDTH - 1 : 0] add_selector; 
        input [SELECTOR_WIDTH - 1 : 0] x_selector; 
        input [SELECTOR_WIDTH - 1 : 0] y_selector; 
        input [SELECTOR_WIDTH - 1 : 0] stat_selector;    
        input [SELECTOR_WIDTH - 1 : 0] mem_selector; 
        input [SELECTOR_WIDTH - 1 : 0] fetch_selector;
        input [SELECTOR_WIDTH - 1 : 0] decode_selector; 
        input [SELECTOR_WIDTH - 1 : 0] alu0_selector; 
        input [SELECTOR_WIDTH - 1 : 0] alu1_selector;       
        
        //OUT
        output reg [SIGNAL_WIDTH - 1 : 0] pc_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] sp_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] add_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] x_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] y_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] stat_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] mem_out;
        output reg [SIGNAL_WIDTH - 1 : 0] fetch_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] decode_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] alu0_out; 
        output reg [SIGNAL_WIDTH - 1 : 0] alu1_out;

        mux831 reg_mux0  (.clk(phi2_int), .in0(/*oPC*/), .in1(oADD), .in2(oX), .in3(oY), .in4(imm), .in5(d_from_mem), .in6(8'h00), .in7(d_from_fetch), .selector(source_selector_01), .out(reg_connect_0));

        mux831 pc_mux(.clk(clk), .out(pc_out), `INPUT_BUS); 
        mux831 sp_mux(.clk(clk), .out(sp_out), `INPUT_BUS);  
        mux831 add_mux(.clk(clk), .out(add_out), `INPUT_BUS); 
        mux831 x_mux(.clk(clk), .out(x_out), `INPUT_BUS);  
        mux831 y_mux(.clk(clk), .out(y_out), `INPUT_BUS);  
        mux831 stat_mux(.clk(clk), .out(stat_out), `INPUT_BUS);  
        mux831 mem_mux(.clk(clk), .out(mem_out), `INPUT_BUS); 
        mux831 fetch_mux(.clk(clk), .out(fetch_out), `INPUT_BUS);  
        mux831 decode_mux(.clk(clk), .out(decode_out), `INPUT_BUS);  
        mux831 alu0_mux(.clk(clk), .out(alu0_out), `INPUT_BUS);  
        mux831 alu1_mux(.clk(clk), .out(alu1_out), `INPUT_BUS); 

endmodule

`endif