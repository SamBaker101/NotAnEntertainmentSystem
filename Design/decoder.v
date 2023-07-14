//Sam Baker
//07/2023
//6502 Decoder

`ifndef DECODE
`define DECODE

module decoder(
		clk, reset_n, read, opp, we, read_write, reg_sel_00, reg_sel_01, reg_sel_10, reg_sel_11, imm_addr, instruct_ready, addr
		);
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;

        input clk, reset_n;
        input [REG_WIDTH - 1 : 0] read;

        output reg [OPP_WIDTH - 1 : 0] opp;
        output reg [2:0] reg_sel_00, reg_sel_01, reg_sel_10, reg_sel_11;        
        output reg [REG_WIDTH - 1 : 0] imm_addr;

        output reg instruct_ready;
        output reg [ADDR_WIDTH - 1: 0] addr;
        output reg [`WE_WIDTH - 1 : 0] we;
        output reg read_write; //write-low, read-high

        /////////////////////////////

        reg [2:0] add_mode;
        reg [4:0] opp_code;
        reg [REG_WIDTH - 1 : 0] instruction;

        reg [3:0] fetch_counter, fetch_target; 
        
        always @(posedge clk) begin
            //Operation
            instruct_ready = 1'b0;
            we = 0;
            read_write = 1'b1;
            reg_sel_00 = 0;
            reg_sel_01 = 0;
            reg_sel_10 = 0;
            reg_sel_11 = 0;

            if (!reset_n) begin
                opp = 0;
                reg_sel_00 = 0;
                reg_sel_01 = 0;
                reg_sel_10 = 0;
                reg_sel_11 = 0;
                imm_addr = 0;
                fetch_counter = 0;
                fetch_target = 0;
                instruct_ready = 0;
                we = 0;
                read_write = 1'b1;

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
                        fetch_target = 1;
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

                case(opp_code) //This is gonna be a bit of a mess for a while
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
                        if (instruct_ready) begin
                            we = `WE_ADD;

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