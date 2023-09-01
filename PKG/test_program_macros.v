//Sam Baker
//07/2023

//Instruction sets for test benches
//Macros will give instructions and expected modifications to mem

//FIXME: This is getting tedious to deal with, find a compiler and set up firmware loader to read hex files

//FIXME: Tests missing : 
//                  CMP CPX CPY test
//                  Transfer Test (TSX, TAX, TYA ect)
//                  Stat Clears (CLC, )
//                  Stack Opps (PHP, )  

`ifndef INST_MACROS
`define INST_MACROS

//Blank test for checking build
`define TEST_NOOPP          $display("LOADING TEST: NOOPP"); \
                            test_name = "NOOPP";            \
                                                            \
                            inst_list[0]    = 8'h00;        \     
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


`define TEST_LDAZPG          $display("LOADING TEST: LDAZPG"); \
                            test_name = "LDAZPG";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'h04;        \   //  x04
                            inst_list[2]    = 8'h85;        \   //  STA ZPG 
                            inst_list[3]    = 8'h02;        \   //  x02
                            inst_list[4]    = 8'hA5;        \   //  LDA ZPG
                            inst_list[5]    = 8'h0A;        \   //  x0A
                            inst_list[6]    = 8'h85;        \   //  STA ZPG
                            inst_list[7]    = 8'h04;        \   //  x04
                            inst_list[8]    = 8'hA2;        \   //  LDX # 101 000 10
                            inst_list[9]    = 8'h01;        \   //  x01   101 000 01
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
`define TEST_LDAABS          $display("LOADING TEST: LDAABS"); \
                            test_name = "LDAABS";            \
                                                            \
                            inst_list[0]    = 8'hAD;        \   //  LDA ABS   
                            inst_list[1]    = 8'h4f;        \   //  x4f
                            inst_list[2]    = 8'h01;        \   //  x01
                            inst_list[3]    = 8'h8D;        \   //  STA ABS
                            inst_list[4]    = 8'h41;        \   //  x41
                            inst_list[5]    = 8'h01;        \   //  x01
                            inst_list[6]    = 8'hA2;        \   //  LDX #
                            inst_list[7]    = 8'h0A;        \   //  x0A
                            inst_list[8]    = 8'hBD;        \   //  LDA ABS_X 
                            inst_list[9]    = 8'hFF;        \   //  x40
                            inst_list[10]   = 8'h00;        \   //  x01      //     x0145
                            inst_list[11]   = 8'hA2;        \   //  LDX #
                            inst_list[12]   = 8'h03;        \   //  x03
                            inst_list[13]   = 8'h9D;        \   //  STA ABS_X
                            inst_list[14]   = 8'h41;        \   //  x41
                            inst_list[15]   = 8'h01;        \   //  x01      //     x0144
                                                            \
                            inst_list[16]   = 8'hA0;        \   //  LDY #
                            inst_list[17]   = 8'h02;        \   //  x0A
                            inst_list[18]   = 8'hB9;        \   //  LDA ABS_Y 
                            inst_list[19]   = 8'hFF;        \   //  xFF
                            inst_list[20]   = 8'h00;        \   //  x00      //     x0145
                            inst_list[21]   = 8'hA0;        \   //  LDY #
                            inst_list[22]   = 8'h03;        \   //  x03
                            inst_list[23]   = 8'h99;        \   //  STA ABS_Y
                            inst_list[24]   = 8'hFF;        \   //  xFF
                            inst_list[25]   = 8'h00;        \   //  x00      //     x0144
                                                            \
                            mem_model[16'h0141] = mem_model[16'h014f];      \
                            mem_model[16'h0144] = mem_model[16'h0109];      \
                            mem_model[16'h0102] = mem_model[16'h0101];

`define TEST_LDYSTY           $display("LOADING TEST: LDYSTY"); \
                            test_name = "LDYSTY";            \
                                                            \
                            inst_list[0]    = 8'hA0;        \   //  LDY #   
                            inst_list[1]    = 8'hFF;        \   //  xFF
                            inst_list[2]    = 8'h84;        \   //  STY ZPG
                            inst_list[3]    = 8'h0A;        \   //  x0A
                                                            \
                            mem_model[16'h000A] = 8'hff;    


// X_IND and IND_Y, Note MEM must be at least 'h015f for this test
`define TEST_INDXY           $display("LOADING TEST: INDXY"); \
                            test_name = "INDXY";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'hFF;        \   //  xFF
                            inst_list[2]    = 8'h8D;        \   //  STA ABS
                            inst_list[3]    = 8'h41;        \   //  x41
                            inst_list[4]    = 8'h01;        \   //  x01
                            inst_list[5]    = 8'hA9;        \   //  LDA #   
                            inst_list[6]    = 8'h00;        \   //  x00
                            inst_list[7]    = 8'h8D;        \   //  STA ABS
                            inst_list[8]    = 8'h42;        \   //  x42
                            inst_list[9]    = 8'h01;        \   //  x01
                                                            \
                            inst_list[10]    = 8'hA9;        \   //  LDA #   
                            inst_list[11]    = 8'h30;        \   //  x30
                            inst_list[12]    = 8'h8D;        \   //  STA ABS
                            inst_list[13]    = 8'h24;        \   //  x24
                            inst_list[14]    = 8'h01;        \   //  x01
                            inst_list[15]    = 8'hA9;        \   //  LDA #   
                            inst_list[16]    = 8'h01;        \   //  x01
                            inst_list[17]    = 8'h8D;        \   //  STA ABS
                            inst_list[18]    = 8'h25;        \   //  x25
                            inst_list[19]    = 8'h01;        \   //  x01
                            \                                  
                            inst_list[20]    = 8'hA2;        \   //  LDX #   
                            inst_list[21]    = 8'h04;        \   //  x04
                            inst_list[22]    = 8'hA0;        \   //  LDY #
                            inst_list[23]    = 8'h0A;        \   //  x0A
                            inst_list[24]    = 8'hA1;        \   //  LDA X_IND 101 000 01
                            inst_list[25]    = 8'h20;        \   //  x20  
                            inst_list[26]    = 8'h01;        \   //  x01
                            inst_list[27]    = 8'h91;        \   //  STA IND_Y   100  100  01
                            inst_list[28]    = 8'h41;        \   //  8'h41
                            inst_list[29]    = 8'h01;        \   //  8'h01
                            \
                            test_carry = 1'b0;              \
                            \
                            mem_model[16'h0141] = 8'hFF;      \
                            mem_model[16'h0142] = 8'h00;      \
                            mem_model[16'h0124] = 8'h30;      \
                            mem_model[16'h0125] = 8'h01;      \
                            mem_model[16'h0109] = mem_model[16'h0130];


`define TEST_ADC           $display("LOADING TEST: ADC"); \
                            test_name = "ADC";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'h04;        \   //  x04
                            inst_list[2]    = 8'h69;        \   //  ADC # 
                            inst_list[3]    = 8'h02;        \   //  x02
                            inst_list[4]    = 8'h85;        \   //  STA ZPG 
                            inst_list[5]    = 8'h03;        \   //  x03
                                                            \
                            inst_list[6]    = 8'hA9;        \   //  LDA #   
                            inst_list[7]    = 8'hFF;        \   //  xFF
                            inst_list[8]    = 8'h69;        \   //  ADC # 
                            inst_list[9]    = 8'h02;        \   //  x01
                            inst_list[10]   = 8'h85;        \   //  STA ZPG 
                            inst_list[11]   = 8'h04;        \   //  x04
                                                            \
                            inst_list[12]    = 8'hA9;        \   //  LDA #   
                            inst_list[13]    = 8'h03;        \   //  x03
                            inst_list[14]    = 8'h69;        \   //  ADC # 
                            inst_list[15]    = 8'h03;        \   //  x03
                            inst_list[16]   = 8'h85;        \   //  STA ZPG 
                            inst_list[17]   = 8'h05;        \   //  x05
                                                            \
                            test_carry = 1'b0;              \
                                                            \
                            mem_model[16'h0003] = 8'h06;    \
                            mem_model[16'h0004] = 8'h01;    \
                            mem_model[16'h0005] = 8'h06;      


`define TEST_ALU_LOG        $display("LOADING TEST: ALU_LOG"); \
                            test_name = "ALU_LOG";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'h04;        \   //  x04
                            inst_list[2]    = 8'h69;        \   //  ADC # 
                            inst_list[3]    = 8'h02;        \   //  x02
                            inst_list[4]    = 8'h85;        \   //  STA ZPG 
                            inst_list[5]    = 8'h03;        \   //  x03
                            \
                            inst_list[6]    = 8'h09;        \   //  ORA #
                            inst_list[7]    = 8'h4A;        \   //  x01
                            inst_list[8]    = 8'h85;        \   //  STA ZPG 
                            inst_list[9]    = 8'h04;        \   //  x04
                            \
                            inst_list[10]   = 8'h29;        \   //  AND #
                            inst_list[11]   = 8'h55;        \   //  x55
                            inst_list[12]   = 8'h85;        \   //  STA ZPG 
                            inst_list[13]   = 8'h05;        \   //  x05
                            \                                                                                                                       
                            inst_list[14]   = 8'h49;        \   //  EOR #
                            inst_list[15]   = 8'h0F;        \   //  x0F
                            inst_list[16]   = 8'h85;        \   //  STA ZPG 
                            inst_list[17]   = 8'h06;        \   //  x06
                            \
                            mem_model[16'h0003] = 8'h06;                            \
                            mem_model[16'h0004] = (mem_model[16'h0003]   |   8'h4A);  \
                            mem_model[16'h0005] = (mem_model[16'h0004]   &   8'h55);  \
                            mem_model[16'h0006] = (mem_model[16'h0005]   ^   8'h0F);  

`define TEST_ALU_ASL        $display("LOADING TEST: ALU_ASL"); \
                            test_name = "ALU_ASL";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'hA4;        \   //  xA4
                            inst_list[2]    = 8'h0A;        \   //  ASL A  
                            inst_list[3]    = 8'h85;        \   //  STA ZPG 
                            inst_list[4]    = 8'h03;        \   //  x03
                                                            \
                            test_carry = 1'b1;              \
                                                            \
                            mem_model[16'h0003] = (8'hA4 << 1); // 10100100 << 1 = 01001000 = 48
 
`define TEST_ALU_LSR        $display("LOADING TEST: ALU_LSR"); \
                            test_name = "ALU_LSR";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'hA1;        \   //  xA4
                            inst_list[2]    = 8'h4A;        \   //  LSR A 
                            inst_list[3]    = 8'h85;        \   //  STA ZPG 1000 0101
                            inst_list[4]    = 8'h03;        \   //  x03     00 1010 0001
                                                            \
                            test_carry = 1'b1;              \
                                                            \
                            mem_model[16'h0003] = (8'hA1 >> 1); 


`define TEST_ALU_INC        $display("LOADING TEST: ALU_INC"); \
                            test_name = "ALU_INC";            \
                                                            \ 
                            inst_list[0]    = 8'hA2;        \   //  LDX #   
                            inst_list[1]    = 8'hA4;        \   //  xA4
                            inst_list[2]    = 8'hE8;        \   //  INX 
                            inst_list[3]    = 8'h85;        \   //  STA ZPG 
                            inst_list[4]    = 8'h03;        \   //  x03
                                                            \
                            inst_list[5]    = 8'hA0;        \   //  LDY #   
                            inst_list[6]    = 8'hA1;        \   //  xA4
                            inst_list[7]    = 8'hC8;        \   //  INY 
                            inst_list[8]    = 8'h85;        \   //  STA ZPG 
                            inst_list[9]    = 8'h04;        \   //  x03
                                                            \
                            inst_list[10]    = 8'hE6;        \   //  INC ZPG
                            inst_list[11]    = 8'h04;        \   //  x04  
                                                            \        
                            test_carry = 1'b0;              \
                                                            \
                            mem_model[16'h0003] = (8'hA4 + 1);     \
                            mem_model[16'h0004] = (8'hA1 + 2);     \


`define TEST_ALU_DEC        $display("LOADING TEST: ALU_DEC"); \
                            test_name = "ALU_DEC";            \
                                                            \
                            inst_list[0]    = 8'hA2;        \   //  LDX #   
                            inst_list[1]    = 8'hA4;        \   //  xA4
                            inst_list[2]    = 8'hCA;        \   //  DEX 
                            inst_list[3]    = 8'h85;        \   //  STA ZPG 
                            inst_list[4]    = 8'h03;        \   //  x03
                                                            \
                            inst_list[5]    = 8'hA0;        \   //  LDY #   
                            inst_list[6]    = 8'hA1;        \   //  xA4
                            inst_list[7]    = 8'h88;        \   //  DEY 
                            inst_list[8]    = 8'h85;        \   //  STA ZPG 
                            inst_list[9]    = 8'h04;        \   //  x04
                                                            \
                            inst_list[10]    = 8'hC6;        \   //  DEC ZPG
                            inst_list[11]    = 8'h04;        \   //  x04  
                                                            \        
                            test_carry = 1'b0;              \
                                                            \
                            mem_model[16'h0003] = (8'hA4 - 1);     \
                            mem_model[16'h0004] = (8'hA1 - 2);     \


`define TEST_ALU_ROT        $display("LOADING TEST: ALU_ROT"); \
                            test_name = "ALU_ROT";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'hF0;        \   //  xA4
                            inst_list[2]    = 8'h2A;        \   //  LSR A
                            inst_list[3]    = 8'h2A;        \   //  LSR A 
                            inst_list[4]    = 8'h85;        \   //  STA ZPG 1000 0101
                            inst_list[5]    = 8'h03;        \   //  x03     00 1010 0001
                                                            \                                                          
                            inst_list[6]    = 8'hA9;        \   //  LDA #   
                            inst_list[7]    = 8'h0F;        \   //  xA4
                            inst_list[8]    = 8'h6A;        \   //  LSR A
                            inst_list[9]    = 8'h85;        \   //  STA ZPG 1000 0101
                            inst_list[10]   = 8'h04;        \   //  x03     00 1010 0001
                                                            \
                            test_carry = 1'b1;              \
                                                            \
                            mem_model[16'h0003] = (8'hC1);     \    // 0 1111 0000 >> 1 1110 0000 >> 1 1100 0001 
                            mem_model[16'h0004] = (8'h87);     \ 


`define TEST_ALU_SBC        $display("LOADING TEST: SBC"); \ //This could be more robust
                            test_name = "SBC";            \
                                                            \
                            inst_list[0]    = 8'hA9;        \   //  LDA #   
                            inst_list[1]    = 8'h0F;        \   //  x04
                            inst_list[2]    = 8'hE9;        \   //  ADC # 
                            inst_list[3]    = 8'h02;        \   //  x02
                            inst_list[4]    = 8'h85;        \   //  STA ZPG 
                            inst_list[5]    = 8'h03;        \   //  x03
                                                            \
                            test_carry = 1'b0;              \
                                                            \
                            mem_model[16'h0003] = 8'h0D;       

`endif 