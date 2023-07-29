//Sam Baker
//07/2023

//Instruction sets for test benches
//Macros will give instructions and expected modifications to mem

`ifndef INST_MACROS
`define INST_MACROS

`define MEM_DEPTH           'h01FF 
`define INSTRUCTION_BASE    'h0150

//`define MEM_DEPTH           'h001F 
//`define INSTRUCTION_BASE    'h0010

//Blank test for checking build
`define TEST_NOOPP          inst_list[0]    = 8'h00;        \     
                            inst_list[1]    = 8'h00;        \
                            inst_list[2]    = 8'h00;        \     
                            inst_list[3]    = 8'h00;        \
                            inst_list[4]    = 8'h00;        \  
                            inst_list[5]    = 8'h00;        \
                            inst_list[6]    = 8'h00;        \
                            inst_list[7]    = 8'h00;        \
                            inst_list[8]    = 8'h00;        \
                            inst_list[9]    = 8'h00;        \
                            inst_list[10]   = 8'h00;        \    
                            inst_list[11]   = 8'h00;        \
                            inst_list[12]   = 8'h00;        \
                            inst_list[13]   = 8'h00;        \
                            inst_list[14]   = 8'h00;        \
                            inst_list[15]   = 8'h00;        \
                                                            \
                            mem_model[16'h02] = mem_model[16'h02];      \
                            mem_model[16'h0C] = mem_model[16'h0C];      \
                            mem_model[16'h08] = mem_model[16'h08];      \
                            mem_model[16'h06] = mem_model[16'h06];


//LDA using IMM, ZPG & ZPG_X
//STA
`define TEST_LDAZPG         inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'h04;        \   //  x04
                            inst_list[2]    = 8'h85;        \   //  STA ZPG 
                            inst_list[3]    = 8'h02;        \   //  x02
                            inst_list[4]    = 8'hA5;        \   //  LDA ZPG
                            inst_list[5]    = 8'h0A;        \   //  x0A
                            inst_list[6]    = 8'h85;        \   //  STA ZPG
                            inst_list[7]    = 8'h04;        \   //  x04
                            inst_list[8]    = 8'hAA;        \   //  LDA IMM
                            inst_list[9]    = 8'h01;        \   //  x01
                            inst_list[10]   = 8'hB5;        \   //  LDA ZPG_X 
                            inst_list[11]   = 8'h05;        \   //  x05
                            inst_list[12]   = 8'h85;        \   //  STA ZPG
                            inst_list[13]   = 8'h08;        \   //  x08
                            inst_list[14]   = 8'h86;        \   //  STX ZPG
                            inst_list[15]   = 8'h0A;        \   //  x0A
                                                            \
                            mem_model[16'h02] = 8'h04;      \
                            mem_model[16'h04] = mem_model[16'h0A];      \
                            mem_model[16'h08] = mem_model[16'h06];      \
                            mem_model[16'h0A] = 8'h01;

// Test ABS LDA and STA, Note MEM must be at least 'h015f for this test
`define TEST_LDAABS         inst_list[0]    = 8'hAD;        \   //  LDA ABS   
                            inst_list[1]    = 8'h4f;        \   //  x4f
                            inst_list[2]    = 8'h01;        \   //  x01
                            inst_list[3]    = 8'h8D;        \   //  STA ABS
                            inst_list[4]    = 8'h41;        \   //  x41
                            inst_list[5]    = 8'h01;        \   //  x01
                            inst_list[6]    = 8'hAA;        \   //  LDX #
                            inst_list[7]    = 8'h0A;        \   //  x0A
                            inst_list[8]    = 8'hBD;        \   //  LDA ABS_X 
                            inst_list[9]    = 8'hFF;        \   //  x40
                            inst_list[10]   = 8'h00;        \   //  x01      //     x0145
                            inst_list[11]   = 8'hAA;        \   //  LDX #
                            inst_list[12]   = 8'h03;        \   //  x03
                            inst_list[13]   = 8'h9D;        \   //  STA ABS_X
                            inst_list[14]   = 8'h41;        \   //  x41
                            inst_list[15]   = 8'h01;        \   //  x01      //     x0144
                                                            \
                            inst_list[16]   = 8'hA8;        \   //  LDY #
                            inst_list[17]   = 8'h02;        \   //  x0A
                            inst_list[18]   = 8'hB9;        \   //  LDA ABS_Y 
                            inst_list[19]   = 8'hFF;        \   //  xFF
                            inst_list[20]   = 8'h00;        \   //  x00      //     x0145
                            inst_list[21]   = 8'hA8;        \   //  LDY #
                            inst_list[22]   = 8'h03;        \   //  x03
                            inst_list[23]   = 8'h99;        \   //  STA ABS_Y
                            inst_list[24]   = 8'hFF;        \   //  xFF
                            inst_list[25]   = 8'h00;        \   //  x00      //     x0144
                                                            \
                            mem_model[16'h0141] = mem_model[16'h014f];      \
                            mem_model[16'h0144] = mem_model[16'h0109];      \
                            mem_model[16'h0102] = mem_model[16'h0101];

`define TEST_LDYSTY         inst_list[0]    = 8'hA8;        \   //  LDY #   
                            inst_list[1]    = 8'hFF;        \   //  xFF
                            inst_list[2]    = 8'h84;        \   //  STY ZPG
                            inst_list[3]    = 8'h0A;        \   //  x0A
                                                            \
                            mem_model[16'h000A] = 8'hff;    



`endif 