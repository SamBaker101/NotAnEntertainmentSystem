//Sam Baker
//07/2023
//6502 Decoder

`ifndef DECODE
`define DECODE

//Im begginning to suspect this is not necessary...
`define ADDR_MODE_SELECTOR  (add_mode == `AM3_IMM)   ? `SELECTOR_IMM:   \
                            (add_mode == `AM3_ZPG)   ? `SELECTOR_MEM:   \
                            (add_mode == `AM3_ZPG_X) ? `SELECTOR_MEM:   \
                            (add_mode == `AM3_ABS)   ? `SELECTOR_MEM:   \
                            (add_mode == `AM3_ABS_X) ? `SELECTOR_MEM:   \
                            (add_mode == `AM3_ABS_Y) ? `SELECTOR_MEM:   \
                            (add_mode == `AM3_X_IND) ? `SELECTOR_MEM:   \
                            (add_mode == `AM3_IND_Y) ? `SELECTOR_MEM:   \
                            {ADDR_WIDTH{1'bz}};

module decoder(
		clk, reset_n, addr_in, instruction_in, opp, we,
        instruction_ready, addr, instruction_done, alu_done,
        
        pc_selector,  
        sp_selector, add_selector,  x_selector,  y_selector, stat_selector, mem_selector, 
        decode_selector,  alu0_selector,  alu1_selector, alu_update_status    
        );
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;

        input clk, reset_n;
        input [ADDR_WIDTH - 1 : 0] addr_in;
        input [REG_WIDTH - 1 : 0] instruction_in;
        input instruction_ready, alu_done;

        output reg [OPP_WIDTH - 1 : 0] opp;       
        output reg instruction_done;

        output reg [ADDR_WIDTH - 1: 0] addr;
        output reg [`WE_WIDTH - 1 : 0] we;

        output reg [3:0] pc_selector; 
        output reg [3:0] sp_selector; 
        output reg [3:0] add_selector; 
        output reg [3:0] x_selector; 
        output reg [3:0] y_selector; 
        output reg [3:0] stat_selector;    
        output reg [3:0] mem_selector; 
        output reg [3:0] decode_selector; 
        output reg [3:0] alu0_selector; 
        output reg [3:0] alu1_selector;      

        output reg alu_update_status;
        /////////////////////////////

        reg [2:0] add_mode;
        reg [4:0] opp_code;
        reg [REG_WIDTH - 1 : 0] instruction;

        reg [REG_WIDTH - 1 : 0] decode_counter;

        reg [3:0] fetch_counter, fetch_target; 
        
        always @(posedge instruction_ready) begin
            add_mode = instruction_in[4:2];
            opp_code = {instruction_in[7:5], instruction_in[1:0]};
            instruction = instruction_in;
            instruction_done = 1'b0;
            decode_counter = 0;
            alu_update_status = 0;
        end

        always @(posedge clk) begin
            we = 0;

            if (!reset_n) begin
                opp = 0;
                we = 0;
                decode_counter = 0;

            end else begin
                we = 0;
                if (instruction_ready) begin
                    
                    case(opp_code) //This is gonna be a bit of a mess for a while
                    	5'bXXXXX: ; //FIXME workaround while mem is being loaded
                        
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

                        end	
	                    `OPP_ADC: begin  
                            if (decode_counter == 0) begin
                                alu0_selector = `SELECTOR_ADD;
                                alu1_selector = `ADDR_MODE_SELECTOR;
                                opp = `SUM;
                            end else if (alu_done == 1) begin
                                add_selector = `SELECTOR_ALU_0;
                                we[`WE_ADD] = 1'b1;
                                we[`WE_STAT] = 1'b1;
                                alu_update_status = 1'b1;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_ROR: begin  

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
                        `OPP_STY: begin  
                            if (decode_counter == 0) begin
                                we[`WE_DOUT] = 1'b1;
                                mem_selector = `SELECTOR_Y;
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                        end		
	                    `OPP_STX: begin  
                            if (decode_counter == 0) begin
                                we[`WE_DOUT] = 1'b1;
                                mem_selector = `SELECTOR_X;
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
                        `OPP_LDY: begin  
                            if (decode_counter == 0) begin
                                we[`WE_Y] = 1'b1;
                                y_selector =  `ADDR_MODE_SELECTOR
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end  
                        end	
	                    `OPP_LDX: begin  
                            if (decode_counter == 0) begin
                                we[`WE_X] = 1'b1;
                                x_selector =  `ADDR_MODE_SELECTOR
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_CMP: begin  

                        end	
	                    `OPP_DEC: begin  

                        end	
	                    `OPP_SBC: begin  

                        end	
	                    `OPP_INC: begin  

                        end	
            
                        `OPP_ILLEGAL: begin 
                            $fatal(1, "Illegal Instruction ecountered: %h", instruction);
                        end
                      default: begin 
                          //$error(1, "Illegal or unimplemented instruction encountered: %h", instruction);
                      end
                  endcase
                  decode_counter ++;
                end
            end
        end

    endmodule

`endif