`ifndef PKG
`define PKG
	


	
	//Operations
	`define OPP_WIDTH 8
	
	`define NO_OPP 	0
	`define FETCH   1
	`define LOAD 	2
	`define STORE	4
	`define SUM 	8
	`define AND 	16
	`define OR  	32
	`define XOR 	64
	`define SR  	128   


	//Hardware Definitions
	`define REG_WIDTH 8
	`define INSTRUCTION_WIDTH 8
	`define ADDR_WIDTH 16
	`define SELECTOR_WIDTH = 4

	//REG Write Enables
	`define WE_WIDTH 7

	`define WE_PC 	0
	`define WE_SP 	1
	`define WE_ADD 	2
	`define WE_X	3
	`define WE_Y 	4
	`define WE_STAT 5
	`define WE_DOUT 6   //0100 0000

	//ALU MUX Reg Selectors
	`define SELECTOR_ZERO 	4'd0
	`define SELECTOR_PC 	4'd1
	`define SELECTOR_SP		4'd2
	`define SELECTOR_ADD 	4'd3
	`define SELECTOR_X	    4'd4
	`define SELECTOR_Y	    4'd5
	`define SELECTOR_STAT   4'd6
	`define SELECTOR_MEM  	4'd7
	`define SELECTOR_IMM    4'd8
	`define SELECTOR_FETCH  4'd9
	`define SELECTOR_DECODE 4'd10
	`define SELECTOR_ALU_0	4'd11
	`define SELECTOR_ALU_1	4'd12
	`define SELECTOR_ONE 	4'd13

	// IMM vs IMP/ADD
	// impl/A   08 0A      	000 010 00 | 000 010 10 
	// Imm      09  	   	000 010 01

	//STATUS REG Bit Definitions
	`define CARRY       0
	`define ZERO       	1
	`define INT_DIS  	2
	`define DEC      	3
	`define BREAK    	4
	`define V_OVERFLOW	6
	`define NEG			7

	//Opp Code
	`define OPP_SPECIAL 5'bXXX_00 //LB 0, 4, 8, C
	`define OPP_ILLEGAL 5'bXXX_11 //LB 3, 7, B, F

	`define	OPP_ORA 	5'b000_01
	`define OPP_ASL		5'b000_10
	`define OPP_AND		5'b001_01
	`define OPP_ROL		5'b001_10
	`define OPP_EOR		5'b010_01
	`define OPP_LSR		5'b010_10
	`define OPP_ADC		5'b011_01
	`define OPP_ROR		5'b011_10
	`define OPP_STA		5'b100_01
	`define OPP_STY		5'b100_00
	`define OPP_STX		5'b100_10    
	`define OPP_LDA		5'b101_01    
	`define OPP_LDY		5'b101_00 
	`define OPP_LDX		5'b101_10
	`define OPP_INY     5'b110_00   
	`define OPP_CMP		5'b110_01
	`define OPP_DEC		5'b110_10
	`define OPP_SBC		5'b111_01
	`define OPP_INC		5'b111_10
	`define OPP_INX  	5'b111_00

	//Spec Opp Codes 6 bits (instruction [7:2])
	//There is probably a cleaner way to encode these
	`define SPEC_OPP_BRK 	6'b0000_00
	`define SPEC_OPP_BPL	6'b0001_00
	//...

	//Address Modes
	`define AM3_X_IND	3'b000 
	`define AM3_ZPG		3'b001
	`define AM3_ADD		3'b010  
	`define AM3_ABS		3'b011
	`define AM3_IND_Y	3'b100
	`define AM3_ZPG_X	3'b101
	`define AM3_ABS_Y	3'b110
	`define AM3_ABS_X	3'b111

`include "Design/data_bus.v"
`include "Design/decoder.v"
`include "Design/fetcher.v"
`include "Design/mem.v"
`include "Design/mux831.v"
`include "Design/fan138.v"
`include "Design/register.v"
`include "Design/clock_module.v"
`include "Design/ALU.v"
`include "Design/6502_top.v"
`include "Design/switch.v"




`endif