`ifndef DECODE
`define DECODE

module decoder(
		clk, reset_n, read, opp, reg_sel_a, reg_sel_b, imm, instruct_ready, addr
		);
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;


        input clk, reset_n;
        input [REG_WIDTH - 1 : 0] read;

        output reg [OPP_WIDTH - 1 : 0] opp;
        output reg [2:0] reg_sel_a, reg_sel_b;        
        output reg [REG_WIDTH - 1 : 0] imm;

        output reg instruct_ready;
        output reg [ADDR_WIDTH - 1: 0] addr;

        /////////////////////////////

        reg [2:0] add_mode;
        reg [4:0] opp_code;
        reg [REG_WIDTH - 1 : 0] instruction;

        reg [3:0] fetch_counter, fetch_target; 
        
        always @(posedge clk) begin
            //Operation
            instruct_ready = 1'b0;
            if (!reset_n) begin
                opp = 0;
                reg_sel_a = 0;
                reg_sel_b = 0;
                imm = 0;
                fetch_counter = 0;
                fetch_target = 0;
                instruct_ready = 0;
            
            end else if (fetch_counter == fetch_target) begin
                add_mode = read[4:2];
                opp_code = {read[7:5], read[1:0]};
                instruction = read;
                fetch_counter = 0;
                fetch_target = 0;

                case(add_mode) //These are the basic addr mode, may need to be overwritten in some cases
                    `AM3_X_IND: begin 
                            
                    end	 
	                `AM3_ZPG	: begin 

                    end	
	                `AM3_IMM	: begin 

                    end	
	                `AM3_ABS	: begin 

                    end	
	                `AM3_IND_Y: begin 

                    end	
	                `AM3_ZPG_X: begin 

                    end	
	                `AM3_ABS_Y: begin 

                    end	
	                `AM3_ABS_X: begin 

                    end	
                endcase

                case(opp_code)
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

                    end	
	                `OPP_STX: begin  

                    end	
	                `OPP_LDA: begin  

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
                                $fatal(1, "Illegal or unimplemented instruction encountered: %h", instruction);
                            end
                        endcase
                    end
                    `OPP_ILLEGAL: begin 
                        $fatal(1, "Illegal Instruction ecountered: %h", instruction);
                    end
                    default: begin 
                        $fatal(1, "Illegal or unimplemented instruction encountered: %h", instruction);
                    end
                endcase
                if (fetch_counter == fetch_target) instruct_ready = 1'b1;

            end else begin
                fetch_counter += 1;
                if (fetch_counter == 1) addr[7:0] = read;
                if (fetch_counter == 2) addr[15:8] = read;
                if (fetch_counter == fetch_target) instruct_ready = 1'b1;
            end

        end

    endmodule

`endif