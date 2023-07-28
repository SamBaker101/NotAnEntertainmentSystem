//Sam Baker
//07/2023

//Instruction sets for test benches
//Macros will give instructions and expected modifications to mem

`ifndef INST_MACROS
`define INST_MACROS

//Loads and stores data to the ADD reg using IMM and ZPG add_modes
`define TEST_LDAZPG         inst_list[0]    = 8'hA5;        \     
                            inst_list[1]    = 8'h04;        \
                            inst_list[2]    = 8'h85;        \     
                            inst_list[3]    = 8'h02;        \
                            inst_list[4]    = 8'hA9;        \  
                            inst_list[5]    = 8'h10;        \
                            inst_list[6]    = 8'hA9;        \
                            inst_list[7]    = 8'hFF;        \
                            inst_list[8]    = 8'h85;        \
                            inst_list[9]    = 8'h0C;        \
                            inst_list[10]   = 8'hA5;        \    
                            inst_list[11]   = 8'h02;        \
                            inst_list[12]   = 8'h85;        \
                            inst_list[13]   = 8'h08;        \
                            inst_list[14]   = 8'h85;        \
                            inst_list[15]   = 8'h06;        \
                                                            \
                            mem_model[16'h02] = mem_model[16'h04];      \
                            mem_model[16'h0C] = 8'hFF;                  \
                            mem_model[16'h08] = mem_model[16'h02];      \
                            mem_model[16'h06] = mem_model[16'h02];


`endif 