//Sam Baker
//07/2023
//6502 Instruction fetcher

`ifndef FETCHER
`define FETCHER

module fetcher(
        input instruction_done,
        input phi1, phi2, reset_n,
        input [ADDR_WIDTH - 1 : 0] pc,
        input [REG_WIDTH - 1 : 0] sp,
        input [REG_WIDTH - 1 : 0] data_in,

        output reg instruction_ready,
        output reg [ADDR_WIDTH - 1: 0] addr, pc_next,
        output reg [REG_WIDTH - 1 : 0] imm,
        output reg [`REG_WIDTH - 1 : 0] instruction_out, reg_out,

        output reg [3 : 0] fetch_selector
		);
	
        parameter REG_WIDTH = `REG_WIDTH;
        parameter ADDR_WIDTH = `ADDR_WIDTH;
        parameter OPP_WIDTH = `OPP_WIDTH;

        /////////////////////////////
        reg reset_n_d;

        reg [2:0] add_mode;
        reg [ADDR_WIDTH - 1: 0] addr_reg;

        reg pc_wait;
        reg [2:0] fetch_counter; 

        always @(posedge instruction_done) begin
            fetch_counter = 0;
            instruction_ready = 1'b0;
            fetch_selector = `SELECTOR_MEM;
            addr = pc;
            pc_wait = 1'b0;
            pc_next = pc + 1;
            end

        always @(posedge phi1) begin
            //Operation

            if (!reset_n) begin
                fetch_counter = 0;
                instruction_ready = 1'b1;
                pc_next = `INSTRUCTION_BASE;            
                pc_wait = 1'b1;
            end else begin 
                if (!instruction_ready) begin
                    fetch_selector = 0;
                    addr = pc;
                    fetch_selector = `SELECTOR_MEM;

                    if (fetch_counter == 0) begin
                        add_mode = data_in[4:2]; 
                        instruction_out = data_in;
                    end 

                    //This logic is a big mess, many of these need to be rewritten
                    case(add_mode) //These are the basic addr mode, may need to be overwritten in some cases
                        `AM3_X_IND  : begin
                            if (instruction_out == 8'h00) begin
                            end else if (instruction_out[1:0] == 2'b01) begin
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg = {8'h00, data_in};
                                    fetch_selector = `SELECTOR_X;
                                    pc_wait = 1'b1;
                                end
                                if (fetch_counter == 2) begin
                                    addr_reg += data_in;
                                    addr = addr_reg;
                                    instruction_ready = 1'b1;
                                    pc_wait = 1'b0;
                                end  
                            end else if (instruction_out == 8'h20) begin //JSR
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                end
                                if (fetch_counter == 2) begin 
                                    addr_reg[15:8] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                    pc_wait = 1'b1;
                                    pc_next = addr_reg;
                                    instruction_ready = 1'b1;
                                end
                            end else begin  //Imm for LDX LDY and CPX CPY
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    imm = data_in;
                                    instruction_ready = 1'b1;
                                end
                            end
                        end
                        `AM3_ZPG	: begin     
                            if (fetch_counter == 0) begin 
                                fetch_selector = `SELECTOR_MEM;

                            end 
                            if (fetch_counter == 1) begin
                                addr = {16'h00, data_in};
                                instruction_ready = 1'b1;                         
                            end                             
                        end	
                        `AM3_ADD	: begin        
                            if (fetch_counter == 0) begin 
                                if ((instruction_out[0] == 1)  ||    
                                    (instruction_out == 8'hA0) ||
                                    (instruction_out == 8'hA2)) begin
                                        fetch_selector = `SELECTOR_MEM;
                                    //pc_wait = 1'b1; 
                                    end else if (instruction_out == 8'h08) begin    //PHP
                                        addr = sp + `STACK_BASE;
                                        instruction_ready = 1'b1; 
                                    end else begin
                                        instruction_ready = 1'b1;
                                end
                            end 
                            if (fetch_counter == 1) begin
                                imm = data_in;
                                instruction_ready = 1'b1;
                                //pc_wait = 1'b0;
                            end
                        end
                        `AM3_ABS	: begin
                            if ((instruction_out == 8'h4C) || 
                                (instruction_out == 8'h6C)) begin
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                end
                                if (fetch_counter == 2) begin 
                                    addr_reg[15:8] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                    addr = addr_reg;
                                    pc_wait = 1'b1;
                                    pc_next = addr_reg;
                                    instruction_ready = 1'b1;
                                end
                            end else begin
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                end
                                if (fetch_counter == 2) begin 
                                    addr_reg[15:8] = data_in;
                                    addr = addr_reg;
                                    instruction_ready = 1'b1;
                                end
                            end
                        end
                        `AM3_IND_Y  : begin
                            if (instruction_out[1:0] == 2'b00) begin //BRANCHES 
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end else if (fetch_counter == 1) begin
                                    imm = data_in;
                                    instruction_ready = 1'b1;
                                end
                            end else begin
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg = {8'h00, data_in};
                                    addr = addr_reg;
                                    fetch_selector = `SELECTOR_MEM;
                                    pc_wait = 1'b1;
                                end
                                if (fetch_counter == 2) begin 
                                    addr_reg = {8'h00, data_in};
                                    fetch_selector = `SELECTOR_Y;
                                end
                                if (fetch_counter == 3) begin
                                    imm = addr_reg + data_in;
                                    instruction_ready = 1'b1;
                                    pc_wait = 1'b0;
                                end  
                            end
                        end
                        `AM3_ZPG_X  : begin
                            if (fetch_counter == 0) begin 
                                fetch_selector = `SELECTOR_MEM;
                            end 
                            if (fetch_counter == 1) begin
                                addr_reg = {16'h00, data_in};
                                fetch_selector = `SELECTOR_X;
                                pc_wait = 1'b1;
                            end
                            if (fetch_counter == 2) begin
                                addr_reg = (data_in + addr_reg);
                                addr = addr_reg[7:0];
                                instruction_ready = 1'b1;
                                pc_wait = 1'b0;
                            end      
                        end
                        `AM3_ABS_Y  : begin    
                            if ((instruction_out[3:0] == 4'h8) ||   //This covers mostly set/clear commands
                                (instruction_out == 8'hBA)) begin   //TSX
                                instruction_ready = 1'b1;
                            end else begin
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                end
                                if (fetch_counter == 2) begin 
                                    addr_reg[15:8] = data_in;
                                    fetch_selector = `SELECTOR_Y;
                                    pc_wait = 1'b1;
                                end
                                if (fetch_counter == 3) begin
                                    addr_reg += data_in;
                                    addr = addr_reg;
                                    instruction_ready = 1'b1;
                                    pc_wait = 1'b0;
                                end
                            end  
                        end
                        `AM3_ABS_X  : begin  
                            if ({instruction_out[7:5], instruction_out[1:0]} == `OPP_LDX) begin
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                end
                                if (fetch_counter == 2) begin 
                                    addr_reg[15:8] = data_in;
                                    fetch_selector = `SELECTOR_Y;
                                    pc_wait = 1'b1;
                                end
                                if (fetch_counter == 3) begin
                                    addr_reg += data_in;
                                    addr = addr_reg;
                                    instruction_ready = 1'b1;
                                    pc_wait = 1'b0;
                                end  
                            end else begin        
                                if (fetch_counter == 0) begin 
                                    fetch_selector = `SELECTOR_MEM;
                                end 
                                if (fetch_counter == 1) begin
                                    addr_reg[7:0] = data_in;
                                    fetch_selector = `SELECTOR_MEM;
                                end
                                if (fetch_counter == 2) begin 
                                    addr_reg[15:8] = data_in;
                                    fetch_selector = `SELECTOR_X;
                                    pc_wait = 1'b1;
                                end
                                if (fetch_counter == 3) begin
                                    addr_reg += data_in;
                                    addr = addr_reg;
                                    instruction_ready = 1'b1;
                                    pc_wait = 1'b0;
                                end    
                            end
                        end
                    endcase
                if (reset_n == reset_n_d)
                    fetch_counter++; 
                if (!pc_wait && !instruction_ready)
                    pc_next = pc + 1;
                end
            end

            reset_n_d = reset_n;
        end 

    endmodule

`endif