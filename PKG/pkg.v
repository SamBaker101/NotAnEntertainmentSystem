`ifndef PKG
`define PKG
	
	//ALU functions
	`define SUM 1
	`define AND 2
	`define OR  4
	`define XOR 8
	`define SR  16

	//Hardware Definitions
	`define REG_WIDTH 8
	`define INSTRUCTION_WIDTH 8
	`define ADDR_WIDTH 16

	//ALU MUX Reg Selectors
	`define SELECTOR_PC 	0
	`define SELECTOR_ADD 	1
	`define SELECTOR_X		2
	`define SELECTOR_Y 		3
	`define SELECTOR_IMM    4

	//STATUS REG Bit Definitions
	`define CARRY       1
	`define ZERO       	2
	`define INT_DIS  	4
	`define DEC      	8
	`define BREAK    	16
	`define V_OVERFLOW	64
	`define NEG			128

	//Opp Code
	`define OPP_SPECIAL 5'bXXX_00 //LB 0, 4, 8, C
	`define OPP_ILLEGAL 5'bXXX_11 //LB 3, 7, B, F

	`define	OPP_ORA 	5'000_01
	`define OPP_ASL		5'000_10
	`define OPP_AND		5'001_01
	`define OPP_ROL		5'001_10
	`define OPP_EOR		5'010_01
	`define OPP_LSR		5'010_10
	`define OPP_ADC		5'011_01
	`define OPP_ROR		5'011_10
	`define OPP_STA		5'100_01
	`define OPP_STX		5'100_10
	`define OPP_LDA		5'101_01
	`define OPP_LDX		5'101_10
	`define OPP_CMP		5'110_01
	`define OPP_DEC		5'110_10
	`define OPP_SBC		5'111_01
	`define OPP_INC		5'111_10

	//Spec Opp Codes 6 bits (instruction [7:2])
	//There is probably a cleaner way to encode these
	`define SPEC_OPP_BRK 	6'0000_00
	`define SPEC_OPP_BPL	6'0001_00
	//...

	//Address Modes
	`define AM3_X_IND	3'b000
	`define AM3_ZPG		3'b001
	`define AM3_IMM		3'b010
	`define AM3_ABS		3'b011
	`define AM3_IND_Y	3'b100
	`define AM3_ZPG_X	3'b101
	`define AM3_ABS_Y	3'b110
	`define AM3_ABS_X	3'b111

`include "Design/mux831.v"
`include "Design/register.v"
`include "Design/clock_module.v"
`include "Design/ALU.v"
`include "Design/6502_top.v"
`include "Design/decoder.v"

`endif