//Sam Baker
//07/2023
//6502 Instruction fetcher

`ifndef FETCHER
`define FETCHER

module fetcher(
		clk, phi2, reset_n, get_next, pc, data_in, instruction_out, 
        pc_next, addr, imm, instruction_ready, reg_out, 
        fetch_source_selector, instruction_done
		);
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;

        input instruction_done;
        input clk, phi2, reset_n, get_next;  
        input [ADDR_WIDTH - 1 : 0] pc; 
        input [REG_WIDTH - 1 : 0] data_in;

        output reg instruction_ready;
        output reg [ADDR_WIDTH - 1: 0] addr, pc_next;
        output reg [REG_WIDTH - 1 : 0] imm;
        output reg [`REG_WIDTH - 1 : 0] instruction_out, reg_out;
        output reg [2:0] fetch_source_selector;
        /////////////////////////////

        reg [2:0] add_mode;
        reg [4:0] opp_code;
        reg [REG_WIDTH - 1 : 0] instruction;
        reg [ADDR_WIDTH - 1: 0] addr_reg;

        reg [2:0] fetch_counter; 

        always @(posedge instruction_done) begin
            fetch_counter = 0;
            instruction_ready = 1'b0;
            fetch_source_selector = `SELECTOR_D;
            addr = pc;
            end

        always @(posedge phi2) begin
            if (!instruction_ready)
                pc_next = pc + 1;
        end

        always @(posedge clk) begin
            //Operation
            
  

            if (!reset_n) begin
                fetch_counter = 0;
                instruction_ready = 1'b1;
                pc_next = `INSTRUCTION_BASE;             //This is not the right reset_vector, left here for testing

            end else begin 
      //This logic is a mess, try again          

                if (get_next) begin 
                    fetch_counter = 1'b0;
                    instruction_ready = 1'b0;
                    fetch_source_selector = `SELECTOR_D;
                    addr = pc;
                end
                if (!instruction_ready) begin
                    fetch_source_selector = 0;
                    addr = pc;
                    fetch_source_selector = `SELECTOR_D;
                    if (fetch_counter == 0) begin
                        add_mode = data_in[4:2]; 
                        instruction_out = data_in;
                    end 

                    //This logic is a big mess, many of these need to be rewritten
                    case(add_mode) //These are the basic addr mode, may need to be overwritten in some cases
                        `AM3_X_IND  : begin 
                            if (fetch_counter == 0) begin 
                                
                                instruction = data_in;
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};
                                fetch_source_selector = `SELECTOR_D;
                            end
                            if (fetch_counter == 2) begin
                                addr[15:8] = data_in;
                                fetch_source_selector = `SELECTOR_X;
                            end
                            if (fetch_counter == 3) begin
                                addr[7:0] = (data_in + addr[7:0]);
                                instruction_ready = 1'b1;
                            end                            
                        end
                        `AM3_ZPG	: begin     
                            if (fetch_counter == 0) begin 
                                instruction = data_in;
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};                        
                                instruction_ready = 1'b1;
                            end
                        end	
                        `AM3_IMM	: begin        
                            if (fetch_counter == 0) begin 
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                imm = data_in;
                                instruction_ready = 1'b1;
                            end
                        end
                        `AM3_ABS	: begin
                            if (fetch_counter == 0) begin 
                                instruction = data_in;
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};
                                fetch_source_selector = `SELECTOR_D;
                            end
                            if (fetch_counter == 2) begin 
                                addr[15:8] = data_in;
                                instruction_ready = 1'b1;
                            end
                        end
                        `AM3_IND_Y  : begin
                            if (fetch_counter == 0) begin 
                                instruction = data_in;
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};
                                fetch_source_selector = `SELECTOR_D;
                            end
                            if (fetch_counter == 1) begin 
                                addr[15:8] = data_in;
                                fetch_source_selector = `SELECTOR_Y;
                            end
                            if (fetch_counter == 4) begin
                                addr = addr + data_in;
                                instruction_ready = 1'b1;
                            end
                        end
                        `AM3_ZPG_X  : begin
                            if (fetch_counter == 0) begin 
                                instruction = data_in;
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};
                                fetch_source_selector = `SELECTOR_X;
                            end
                            if (fetch_counter == 2) begin
                                addr[7:0] = (data_in + addr[7:0]);
                                instruction_ready = 1'b1;
                            end      
                        end
                        `AM3_ABS_Y  : begin   
                            if (fetch_counter == 0) begin 
                                instruction = data_in;
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};
                                fetch_source_selector = `SELECTOR_D;
                            end
                            if (fetch_counter == 2) begin
                                addr[15:8] = data_in;
                                fetch_source_selector = `SELECTOR_Y;
                            end
                            if (fetch_counter == 3) begin
                                addr += data_in;
                                instruction_ready = 1'b1;
                            end    
                        end
                        `AM3_ABS_X  : begin   
                            if (fetch_counter == 0) begin 
                                instruction = data_in;
                                fetch_source_selector = `SELECTOR_D;
                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};
                                fetch_source_selector = `SELECTOR_D;
                            end
                            if (fetch_counter == 2) begin 
                                addr[15:8] = data_in;
                                fetch_source_selector = `SELECTOR_X;
                            end
                            if (fetch_counter == 3) begin
                                addr += data_in;
                                instruction_ready = 1'b1;
                            end    
                        end
                    endcase
                fetch_counter++; 
                end
            end
        end 

    endmodule

`endif