//Sam Baker
//07/2023
//6502 Instruction fetcher

`ifndef FETCHER
`define FETCHER

module fetcher(
		clk, reset_n, get_next, pc, data_in, instruction_out, 
        pc_next, we_pc, addr, instruction_ready, reg_out, 
        fetch_source_selector
		);
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;

        input clk, reset_n, get_next;
        input [REG_WIDTH - 1 : 0] pc, data_in;

        output reg instruction_ready, we_pc;
        output reg [ADDR_WIDTH - 1: 0] addr;
        output reg [`REG_WIDTH - 1 : 0] instruction_out, pc_next, reg_out;
        output reg [2:0] fetch_source_selector;
        /////////////////////////////

        reg [2:0] add_mode;
        reg [4:0] opp_code;
        reg [REG_WIDTH - 1 : 0] instruction;

        reg [2:0] fetch_counter; 
        
        always @(posedge clk) begin
            //Operation
            
            we_pc = 1'b0;

            if (!reset_n) begin
                fetch_counter = 0;
                instruction_ready = 0;
                we_pc = 0;
                pc_next = 0;             //This is not the right reset_vector, left here for testing

            end else begin 
      //This logic is a mess, try again          

                instruction_out = instruction;
                instruction_ready = 1'b0;
                if (get_next) fetch_counter = 1'b0;
                else fetch_counter ++;


                fetch_source_selector = `SELECTOR_D;
                case(add_mode) //These are the basic addr mode, may need to be overwritten in some cases
                    `AM3_X_IND  : begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 2) begin
                            addr[15:8] = data_in;
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 3) begin
                            fetch_source_selector = `SELECTOR_X;
                        end
                        if (fetch_counter == 4) begin
                            addr[7:0] = (data_in + addr[7:0]);
                            instruction_ready = 1'b1;
                        end                            
                    end
                    `AM3_ZPG	: begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;                            
                            instruction_ready = 1'b1;
                        end
                    end	
                    `AM3_IMM	: begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 2) begin 
                            reg_out[15:8] = data_in;
                            instruction_ready = 1'b1;
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                    end
                    `AM3_ABS	: begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 2) begin 
                            addr[15:8] = data_in;
                            instruction_ready = 1'b1;
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                    end
                    `AM3_IND_Y  : begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 1) addr[15:8] = data_in;
                        if (fetch_counter == 2) begin
                            fetch_source_selector = `SELECTOR_Y;
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 3) begin
                            reg_out = data_in
                        end   
                        if (fetch_counter == 4) begin
                            reg_out = reg_out + data_in;
                            instruction_ready = 1'b1;
                        end
                    end
                    `AM3_ZPG_X  : begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 2) begin
                            fetch_source_selector = `SELECTOR_X;
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 3) begin
                            addr[7:0] = (data_in + addr[7:0]);
                            instruction_ready = 1'b1;
                        end      
                    end
                    `AM3_ABS_Y  : begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 2) begin
                            addr[15:8] = data_in;
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 3) begin
                            fetch_source_selector = `SELECTOR_Y;
                        end
                        if (fetch_counter == 4) begin
                            addr += data_in;
                            instruction_ready = 1'b1;
                        end    
                    end
                    `AM3_ABS_X  : begin
                        if (fetch_counter == 0) begin 
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                            instruction = data_in;
                        end 
                        if (fetch_counter == 1) begin
                            addr = {16'h00, data_in};
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 2) begin 
                            addr[15:8] = data_in;
                            pc_next = pc + 1;
                            we_pc = 1'b1;
                        end
                        if (fetch_counter == 3) begin
                            fetch_source_selector = `SELECTOR_X;
                        end
                        if (fetch_counter == 4) begin
                            addr += data_in;
                            instruction_ready = 1'b1;
                        end    
                    end
                endcase
            end
        end 

    endmodule

`endif