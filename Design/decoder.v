//Sam Baker
//07/2023
//6502 Decoder

`ifndef DECODE
`define DECODE

`define ADDR_MODE_SELECTOR  (add_mode == `AM3_ADD) ? ((instruction_in[0] == 1) ? `SELECTOR_IMM: `SELECTOR_ADD): `SELECTOR_MEM;


module decoder(
        input clk, reset_n,
        input [ADDR_WIDTH - 1 : 0] addr_in, pc_in,
        input [REG_WIDTH - 1 : 0] instruction_in, status_in, data_in,
        input instruction_ready, alu_done,
        input [REG_WIDTH - 1 : 0] imm_in,
      
        output reg instruction_done, carry_in,

        output reg [ADDR_WIDTH - 1: 0] jump_pc,
        output reg [`WE_WIDTH - 1 : 0] we,

        output reg [3:0] pc_selector,
        output reg [3:0] sp_selector, 
        output reg [3:0] add_selector, 
        output reg [3:0] x_selector, 
        output reg [3:0] y_selector, 
        output reg [3:0] stat_selector,     
        output reg [3:0] mem_selector, 
        output reg [3:0] decode_selector, 
        output reg [3:0] alu0_selector, 
        output reg [3:0] alu1_selector,    

        output reg [3:0] addr_in_selector,   

        output reg [REG_WIDTH - 1 : 0] imm_out,
        output reg alu_update_status, invert_alu_b,
        output reg [`OPP_WIDTH - 1 : 0] opp
        );
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;

        /////////////////////////////

        reg [2:0] add_mode;
        reg [4:0] opp_code;
        reg [REG_WIDTH - 1 : 0] instruction;
        reg [ADDR_WIDTH - 1 : 0] addr_reg;

        

        reg [REG_WIDTH - 1 : 0] decode_counter;

        reg [3:0] fetch_counter, fetch_target; 
        
        always @(posedge instruction_ready) begin
            add_mode = instruction_in[4:2];
            opp_code = {instruction_in[7:5], instruction_in[1:0]};
            instruction = instruction_in;
            instruction_done = 1'b0;
            decode_counter = 0;
            alu_update_status = 0;
            stat_selector = `SELECTOR_STAT; 
            we = 0;
            carry_in = 1'b0;
            opp = `NO_OPP;
            invert_alu_b = 1'b0;
            
        end

        always @(posedge reset_n) instruction_done = 1'b1;

        always @(posedge clk) begin
            we = 0;
            
            addr_in_selector =  `SELECTOR_FETCH;  
            alu_update_status = 1'b0;
            imm_out = imm_in;
            jump_pc = 0;

            if (!reset_n) begin
                we = 0;
                decode_counter = 0;
                instruction_done = 1'b0;

            end else begin
                if (instruction_ready) begin 
                    
                    //UNIMPLEMENTED INSTRUCTIONS:
                    //  BRK: 00             - 000 000 00


                    case(opp_code) //This is gonna be a bit of a mess for a while
                    	5'bXXXXX: ;
                        `OPP_NOP: begin // BRK, CLC, PHP 
                            if (instruction == 8'h00) begin             //BRK
                                if (decode_counter == 0) begin
                                    we[`WE_DOUT] = 1'b1;
                                    mem_selector = `SELECTOR_PC;
                                    addr_in_selector = `SELECTOR_SP;
                                end else if (decode_counter == 1) begin
                                    we[`WE_DOUT] = 1'b1;
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_ZERO;
                                    carry_in = 1'b1;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;    
                                end else if (decode_counter == 3) begin
                                    we[`WE_SP] = 1'b0;
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in || (8'h01 << `INT_DIS);
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end else if (instruction == 8'h18) begin    //CLC
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in && (8'hFF ^ (8'h01 << `CARRY));
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'h08) begin    //PHP
                                if (decode_counter == 0) begin
                                    we[`WE_DOUT] = 1'b1;
                                    mem_selector =  `SELECTOR_STAT;
                                    add_selector = `SELECTOR_SP;
                                end if (decode_counter == 1) begin
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_ZERO;
                                    carry_in = 1'b1;
                                    we[`WE_DOUT] = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;
                                end else if (decode_counter == 3) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end 
                        end
                        `OPP_ORA: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                opp = `OR;
                            end else if (alu_done == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b0;
                                alu_update_status = 1'b0;
                                instruction_done = 1'b1;
                            end
                        end 
	                    `OPP_ASL: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `ADDR_MODE_SELECTOR;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                carry_in = 1'b0;
                                opp = `SUM;
                            end else if (decode_counter == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_AND: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                opp = `AND;
                            end else if (alu_done == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b0;
                                alu_update_status = 1'b0;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_ROL: begin  
                            if (decode_counter == 0) begin 
                                alu0_selector = `ADDR_MODE_SELECTOR;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                carry_in = status_in[`CARRY];
                                opp = `SUM;
                            end else if (alu_done == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
                        `OPP_BIT: begin
                            if (instruction == 8'h30) begin   //BMI
                                if (decode_counter == 0) begin
                                    if (status_in[`NEG] == 1'b1) begin
                                        jump_pc = pc_in + imm_in;
                                    end
                                end else begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end else if (instruction == 8'h20) begin   //JSR 
                                if (decode_counter == 0) begin
                                    we[`WE_DOUT] = 1'b1;
                                    mem_selector = `SELECTOR_PC;
                                    addr_in_selector = `SELECTOR_SP;
                                end else if (decode_counter == 1) begin
                                    we[`WE_DOUT] = 1'b1;
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_ZERO;
                                    carry_in = 1'b1;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;    
                                end else if (decode_counter == 3) begin
                                    we[`WE_SP] = 1'b0;
                                    addr_in_selector = `SELECTOR_FETCH;
                                end else begin
                                    jump_pc = addr_in;
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end else if (instruction == 8'h28) begin   //PLP
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    add_selector =  `ADDR_MODE_SELECTOR
                                    addr_in_selector = `SELECTOR_SP;
                                end else if (decode_counter == 1) begin
                                    we[`WE_STAT] = 1'b0;
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_FF;
                                    carry_in = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;
                                end else if (decode_counter == 3) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'h38) begin   //SEC
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in || (8'h01 << `CARRY);
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else begin                             //BIT (24, 2C)
                                if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_STAT;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                opp = `AND;
                            end else if (alu_done == 1) begin
                                stat_selector = `SELECTOR_ALU_0;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b0;
                            end else if (alu_done == 1) begin
                                we[`WE_STAT] = 1'b1;
                                stat_selector =  `SELECTOR_IMM;
                                if (status_in[`NEG] && status_in[`V_OVERFLOW]) begin                         
                                    imm_out = status_in || (8'h01 << `ZERO);
                                end else begin
                                    imm_out = status_in && (8'hFF ^ (8'h01 << `ZERO));
                                end 
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                            end
                        end
	                    `OPP_EOR: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                opp = `XOR;
                            end else if (alu_done == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b0;
                                alu_update_status = 1'b0;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_LSR: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                carry_in = 1'b0;
                                opp = `SR;
                            end else if (decode_counter == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
                        `OPP_CLI: begin // BVC, PHA, RTI, JMP(Abs)
                            if (instruction == 8'h58) begin   //CLI
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in && (8'hFF ^ (8'h01 << `INT_DIS));
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'h50) begin   //BVC
                                if (decode_counter == 0) begin
                                    if (status_in[`V_OVERFLOW] == 1'b0) begin
                                        jump_pc = pc_in + imm_in;
                                    end
                                end else begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end else if (instruction == 8'h48) begin   //PHA
                                if (decode_counter == 0) begin
                                    we[`WE_DOUT] = 1'b1;
                                    mem_selector = `SELECTOR_ADD;
                                    addr_in_selector = `SELECTOR_SP;
                                end else if (decode_counter == 1) begin
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_ZERO;
                                    carry_in = 1'b1;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;    
                                end else if (decode_counter == 3) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'h40) begin   //RTI
                                if (decode_counter == 0) begin
                                    addr_in_selector = `SELECTOR_SP;
                                    decode_selector = `SELECTOR_MEM;
                                end else if (decode_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_FF;
                                    carry_in = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;
                                end else if (decode_counter == 3) begin
                                    addr_reg[15:8] = data_in;
                                    jump_pc = addr_reg;
                                    we[`WE_SP] = 1'b0;
                                end else if (decode_counter == 4) begin
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_FF;
                                    carry_in = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 5) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;
                                end else if (decode_counter == 6) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'h4C) begin   //JMP (Abs) 
                                if (decode_counter == 0) begin
                                    addr_in_selector = `SELECTOR_FETCH;
                                end else begin
                                    jump_pc = addr_in;
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end
                        end
	                    `OPP_ADC: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                opp = `SUM;
                            end else if (decode_counter == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_ROR: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                carry_in = status_in[`CARRY];
                                opp = `SR;
                            end else if (decode_counter == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
                        `OPP_RTS: begin // BVS, JMP(ind), PLA, SEI  
                            if (instruction == 8'h70) begin   //BVS
                                if (decode_counter == 0) begin
                                    if (status_in[`V_OVERFLOW] == 1'b1) begin
                                        jump_pc = pc_in + imm_in;
                                    end
                                end else begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end if (instruction == 8'h6C) begin   //JMP ind 011 011 00
                                if (decode_counter == 0) begin
                                    addr_in_selector = `SELECTOR_FETCH;
                                end else begin
                                    jump_pc = addr_in;
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end if (instruction == 8'h68) begin   //PLA
                                if (decode_counter == 0) begin
                                    we[`WE_ADD] = 1'b1;
                                    add_selector =  `ADDR_MODE_SELECTOR
                                    addr_in_selector = `SELECTOR_SP;
                                end else if (decode_counter == 1) begin
                                    we[`WE_ADD] = 1'b0;
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_FF;
                                    carry_in = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;
                                end else if (decode_counter == 3) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end if (instruction == 8'h60) begin   //RTS
                                if (decode_counter == 0) begin
                                    addr_in_selector = `SELECTOR_SP;
                                    decode_selector = `SELECTOR_MEM;
                                end else if (decode_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_FF;
                                    alu_update_status = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 2) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;
                                end else if (decode_counter == 3) begin
                                    addr_reg[15:8] = data_in;
                                    jump_pc = addr_reg;
                                    we[`WE_SP] = 1'b0;
                                end else if (decode_counter == 4) begin
                                    alu0_selector = `SELECTOR_SP;
                                    alu1_selector = `SELECTOR_FF;
                                    alu_update_status = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 5) begin
                                    sp_selector = `SELECTOR_ALU_0;
                                    we[`WE_SP] = 1'b1;
                                end else if (decode_counter == 6) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end if (instruction == 8'h78) begin   //SEI
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in || (8'h01 << `INT_DIS);
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end
                        end	
	                    `OPP_STA: begin 
                                if (decode_counter == 0) begin
                                    we[`WE_DOUT] = 1'b1;
                                    mem_selector = `SELECTOR_ADD;
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                        end
                        `OPP_STY: begin // BCC, BPL, TYA, DEY   
                            if (instruction == 8'h90) begin   //BCC
                                if (decode_counter == 0) begin
                                    if (status_in[`CARRY] == 1'b0) begin
                                        jump_pc = pc_in + imm_in;
                                    end
                                end else begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end if (instruction == 8'h10) begin   //BPL
                                if (decode_counter == 0) begin
                                    if (status_in[`NEG] == 1'b0) begin
                                        jump_pc = pc_in + imm_in;
                                    end
                                end else begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end if (instruction[4:2] == `AM3_ADD) begin   //DEY
                                if (decode_counter == 0) begin
                                    alu0_selector = `SELECTOR_Y;
                                    alu1_selector = `SELECTOR_FF;
                                    alu_update_status = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 1) begin
                                    add_selector = `SELECTOR_ALU_0;
                                    we[`WE_ADD] = 1'b1;
                                    instruction_done = 1'b1;
                                end
                            end else begin
                                if (decode_counter == 0) begin
                                    if (add_mode == `AM3_ABS_Y) begin
                                        we[`WE_ADD] = 1'b1;
                                        add_selector = `SELECTOR_Y;
                                    end else begin    
                                        we[`WE_DOUT] = 1'b1;
                                        mem_selector = `SELECTOR_Y;
                                    end
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end
                        end		
	                    `OPP_STX: begin  
                            if (decode_counter == 0) begin
                                if (add_mode == `AM3_ADD) begin
                                    we[`WE_ADD] = 1'b1;
                                    add_selector = `SELECTOR_X;    
                                end else if (add_mode == `AM3_ABS_Y) begin
                                    we[`WE_SP] = 1'b1;
                                    sp_selector = `SELECTOR_X;
                                end else begin  
                                    we[`WE_DOUT] = 1'b1;
                                    mem_selector = `SELECTOR_X;
                                end
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_LDA: begin  
                            if (decode_counter == 0) begin
                                we[`WE_ADD] = 1'b1;
                                add_selector =  `ADDR_MODE_SELECTOR
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                        end	
                        `OPP_LDY: begin // BCS, CLV  
                            if (instruction == 8'hB8) begin //CLV
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in || (8'h01 << `V_OVERFLOW);
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'hB0) begin //BCS
                                if (decode_counter == 0) begin
                                    if (status_in[`CARRY] == 1'b1) begin
                                        jump_pc = pc_in + imm_in;
                                    end
                                end else begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end else begin
                                if (decode_counter == 0) begin
                                    we[`WE_Y] = 1'b1;
                                    if (instruction_in == 8'hA0)  
                                        y_selector = `SELECTOR_IMM;
                                    else
                                        y_selector =  `ADDR_MODE_SELECTOR
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end  
                        end	
	                    `OPP_LDX: begin  
                            if (decode_counter == 0) begin
                                we[`WE_X] = 1'b1;
                                if (add_mode == `AM3_ABS_Y) 
                                    x_selector = `SELECTOR_SP;
                                else if  (instruction_in == 8'hA2)
                                    x_selector = `SELECTOR_IMM;
                                else 
                                    x_selector =  `ADDR_MODE_SELECTOR
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_CMP: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                carry_in = 1'b0;
                                invert_alu_b = 1'b1;
                                opp = `SUM;
                            end else if (decode_counter == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b0;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_DEC: begin  
                            if (instruction[4:2] == `AM3_ADD) begin
                                if (decode_counter == 0) begin
                                    alu0_selector = `SELECTOR_X;
                                    alu1_selector = `SELECTOR_FF;
                                    alu_update_status = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 1) begin
                                    add_selector = `SELECTOR_ALU_0;
                                    we[`WE_ADD] = 1'b1;
                                    instruction_done = 1'b1;
                                end    
                            end else begin
                                if (decode_counter == 0) begin
                                    alu0_selector = `SELECTOR_MEM;
                                    alu1_selector = `SELECTOR_FF;
                                    alu_update_status = 1'b0;
                                    opp = `SUM;
                                end else if (decode_counter == 1) begin
                                    mem_selector = `SELECTOR_ALU_0;
                                    we[`WE_DOUT] = 1'b1;
                                end else if (decode_counter == 2) begin
                                    instruction_done = 1'b1;
                                end
                            end
                        end	
	                    `OPP_SBC: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                carry_in = 1'b0;
                                invert_alu_b = 1'b1;
                                opp = `SUM;
                            end else if (decode_counter == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_INC: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_MEM;
                                alu1_selector = `SELECTOR_ZERO;
                                carry_in = 1'b1;
                                opp = `SUM;
                            end else if (decode_counter == 1) begin
                                mem_selector = `SELECTOR_ALU_0;
                                we[`WE_DOUT] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                            end else if (decode_counter == 2) begin
                                instruction_done = 1'b1;
                            end
                        end
                        `OPP_INX: begin  // CPX, SED, BEQ 
                            if (instruction == 8'hE8) begin //INX
                                if (decode_counter == 0) begin
                                    alu0_selector = `SELECTOR_X;
                                    alu1_selector = `SELECTOR_ZERO;
                                    carry_in = 1'b1;
                                    opp = `SUM;
                                end else if (alu_done == 1) begin
                                    add_selector = `SELECTOR_ALU_0;
                                    we[`WE_ADD] = 1'b1;
                                    we[`WE_STAT] = 1'b1;
                                    alu_update_status = 1'b1;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'hF8) begin //SED
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in || (8'h01 << `DEC);
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'hF0) begin //BEQ
                                if (decode_counter == 0) begin
                                    if (status_in[`ZERO] == 1'b1) begin
                                        jump_pc = pc_in + imm_in;
                                    end
                                end else begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end  
                            end else begin //CPX
                                if (decode_counter == 0) begin
                                    alu0_selector = `SELECTOR_X;
                                    if (instruction == 8'hE0) 
                                        alu1_selector = `SELECTOR_IMM;
                                    else
                                        alu1_selector = `ADDR_MODE_SELECTOR;
                                    carry_in = 1'b0;
                                    invert_alu_b = 1'b1;
                                    opp = `SUM;
                                end else if (decode_counter == 1) begin
                                    add_selector = `SELECTOR_ALU_0;
                                    we[`WE_ADD] = 1'b0;
                                    we[`WE_STAT] = 1'b1;
                                    alu_update_status = 1'b1;
                                    instruction_done = 1'b1;
                                end
                            end    
                        end	
            	        `OPP_INY: begin  // CPY, BNE, CLD 
                            if (instruction == 8'hC8) begin //INY
                                if (decode_counter == 0) begin
                                    alu0_selector = `SELECTOR_Y;
                                    alu1_selector = `SELECTOR_ZERO;
                                    carry_in = 1'b1;
                                    opp = `SUM;
                                end else if (alu_done == 1) begin
                                    add_selector = `SELECTOR_ALU_0;
                                    we[`WE_ADD] = 1'b1;
                                    we[`WE_STAT] = 1'b1;
                                    alu_update_status = 1'b1;
                                    instruction_done = 1'b1;
                                end
                            end else if (instruction == 8'hD0) begin //BNE
                                    if (decode_counter == 0) begin
                                        if (status_in[`ZERO] == 1'b0) begin
                                            jump_pc = pc_in + imm_in;
                                        end
                                    end else begin
                                        we = 0;
                                        opp_code = 0;
                                        instruction_done = 1'b1;
                                    end  
                            end else if (instruction == 8'hD8) begin //CLD
                                if (decode_counter == 0) begin
                                    we[`WE_STAT] = 1'b1;
                                    stat_selector =  `SELECTOR_IMM;
                                    imm_out = status_in && (8'hFF ^ (8'h01 << `DEC));
                                end else if (decode_counter == 1) begin
                                    we = 0;
                                    opp_code = 0;
                                    instruction_done = 1'b1;
                                end
                            end else begin //CPY
                                if (decode_counter == 0) begin
                                    alu0_selector = `SELECTOR_Y;
                                    if (instruction == 8'hC0) 
                                        alu1_selector = `SELECTOR_IMM;
                                    else
                                        alu1_selector = `ADDR_MODE_SELECTOR;
                                    carry_in = 1'b0;
                                    invert_alu_b = 1'b1;
                                    opp = `SUM;
                                end else if (decode_counter == 1) begin
                                    add_selector = `SELECTOR_ALU_0;
                                    we[`WE_ADD] = 1'b0;
                                    we[`WE_STAT] = 1'b1;
                                    alu_update_status = 1'b1;
                                    instruction_done = 1'b1;
                                end
                            end  
                        end	
                        
                        `OPP_ILLEGAL: begin 
                            $fatal(1, "Illegal Instruction ecountered: %h", instruction);
                        end
                      default: begin 
                          //$error(1, "Illegal or unimplemented instruction encountered: %h", instruction);
                      end
                  endcase
                  decode_counter ++;
                  we[`WE_PC] = 1'b1;
                end
            end
        end

    endmodule

`endif