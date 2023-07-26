//Sam Baker
//07/2023
//6502 Decoder

`ifndef DECODE
`define DECODE

module decoder(
		clk, reset_n, address_in, instruction_in, opp, we, source_selector_0, target_selector_0, 
        source_selector_1, target_selector_1, instruction_ready, addr, instruction_done
		);
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;

        input clk, reset_n;
        input [ADDR_WIDTH - 1 : 0] address_in;
        input [REG_WIDTH - 1 : 0] instruction_in;
        input instruction_ready;

        output reg [OPP_WIDTH - 1 : 0] opp;
        output reg [2:0] source_selector_0, target_selector_0, source_selector_1, target_selector_1;        
        output reg instruction_done;

        output reg [ADDR_WIDTH - 1: 0] addr;
        output reg [`WE_WIDTH - 1 : 0] we;
        output reg get_next; //get_next logic required

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
        end

        always @(posedge clk) begin
            we = 0;
            target_selector_0 = 0;
            target_selector_1 = 0;
            

            if (!reset_n) begin
                opp = 0;
                target_selector_0 = 0;
                target_selector_1 = 0;
                we = 0;
                decode_counter = 0;

            end else begin
                we = 0;
                if (instruction_ready) begin
                    
                    case(opp_code) //This is gonna be a bit of a mess for a while
                    	5'bXXXXX: ; //FIXME workaround while mem is being loaded
                        
                        `OPP_ORA: begin  

                        end 
	                    `OPP_ASL: begin  

                        end	
	                    `OPP_AND: begin  

                        end	
	                    `OPP_ROL: begin  

                        end	
	                    `OPP_EOR: begin  

                        end	
	                    `OPP_LSR: begin  

                        end	
	                    `OPP_ADC: begin  

                        end	
	                    `OPP_ROR: begin  

                        end	
	                    `OPP_STA: begin  
                            if (decode_counter == 0) begin
                                we[`WE_DOUT] = 1'b1;
                                source_selector_1 = `SELECTOR_ADD;
                                target_selector_1 = `SELECTOR_D;
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_STX: begin  

                        end	
	                    `OPP_LDA: begin  
                            if (decode_counter == 0) begin
                                we[`WE_ADD] = 1'b1;
                                target_selector_1 = `SELECTOR_ADD;
                                source_selector_1 = `SELECTOR_IMM;
                            end else if (decode_counter == 1) begin
                                we = 0;
                                opp_code = 0;
                                instruction_done = 1'b1;
                            end
                        end	
	                    `OPP_LDX: begin  

                        end	
	                    `OPP_CMP: begin  

                        end	
	                    `OPP_DEC: begin  

                        end	
	                    `OPP_SBC: begin  

                        end	
	                    `OPP_INC: begin  

                        end	
                        `OPP_SPECIAL: begin
                            case(instruction[7:2])

                                default: begin
                                    //$fatal(1, "Illegal or unimplemented instruction encountered: %h", instruction);
                                end
                            endcase
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