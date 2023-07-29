//Sam Baker
//07/2023

//Instruction sets for test benches
//Macros will give instructions and expected modifications to mem

`ifndef INST_MACROS
`define INST_MACROS

`define MEM_DEPTH           'h01FF 
`define INSTRUCTION_BASE    'h0150

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
                            inst_list[1]    = 8'h01;        \   //  x01
                            inst_list[2]    = 8'h4f;        \   //  x4f
                            inst_list[3]    = 8'h8D;        \   //  STA ABS
                            inst_list[4]    = 8'h01;        \   //  x01
                            inst_list[5]    = 8'h41;        \   //  x41
                                                            \
                            mem_model[16'h0141] = mem_model[16'h014f];




`endif 