//Sam Baker
//10/2023
//Class to handle load and handling of firmware for tests

`ifndef FW
`define FW

`include "PKG/pkg.v"

typedef logic [`REG_WIDTH - 1 : 0] fw_byte; 

class firmware;
    string fname;
    int fw_length;
    int fw_file, t;
    bit break_out;
    byte temp;
    
    function new(string test_name);
        this.fname = $sformatf("Out/%s.hex", test_name);
    endfunction

    function void open_file();
        this.fw_file = $fopen(this.fname, "r");
        if (!this.fw_file) $display("ERROR opening file");    
    endfunction

    function void read_fw();
        //If you use a different assembler this may need modification
        fw_byte [`MAX_FW_SIZE] fline, temp_fw;
        byte temp;
        int temp_length;

        this.fw_length = 0;

        while ($fgets(fline, this.fw_file)) begin
            this.break_out = 0;
            $display("PARSING: %s", fline);
            temp_length = 0;


            for (int i = 1; i < `MAX_FW_SIZE; i ++) begin
                if (this.break_out == 0) begin;
                    if ((fline[i] == ":") || (fline[i+1] == ":")) begin
                        this.break_out = 1;
                    end else begin
                        //$display(" %c%c", fline[i], fline[i+1]);
                        temp_length ++;
                        this.convert_instruction(fline[i+1], fline[i], temp);

                        for (int i = 1; i < temp_length; i ++) begin
                            temp_fw[temp_length - i] = temp_fw[temp_length - i - 1];
                        end 
                        
                        temp_fw[0] = temp;
                        i++;
                    end
                end
            end 
            for (int i = 4;  i < temp_length - 1; i++) begin
                $display("ADDING: %h", temp_fw[i]);
                fw[this.fw_length] = temp_fw[i];
                this.fw_length = this.fw_length + 1;
            end

        end

        //clean header and footer

    endfunction

    function void load_fw();
        for (int i = 0; i < `MAX_FW_SIZE; i++) begin
            if (i < this.fw_length)
                mem_model[i + `INSTRUCTION_BASE] = fw[i];
            else
                mem_model[i + `INSTRUCTION_BASE] = 8'h00;
        end
    endfunction

    function void fw_push_front(input byte input_byte); 
        //Workaround as queues in classes arent supported
        for (int i = 1; i < this.fw_length; i ++) begin
            fw[this.fw_length - i] = fw[this.fw_length - i - 1];
        end 
        fw[0] = input_byte;
    endfunction

    function void remove_front(); 
        //Workaround as queues in classes arent supported
        for (int i = 0; i < this.fw_length - 1; i ++) begin
            fw[i] = fw[i+1];
        end 
        this.fw_length = this.fw_length - 1;  
    endfunction

    function void remove_back(); 
        //Workaround as queues in classes arent supported
        fw[this.fw_length - 1] = 8'h00;
        this.fw_length = this.fw_length - 1;
    endfunction

    function void print_fw();
        for (int i = 0; i <= this.fw_length - 1; i++) begin
            $display("%0d : %h", i, fw[i]);
        end
    endfunction

    task convert_instruction(input [7:0] high_in, [7:0] low_in, output [7:0] instruction_byte);
        bit [3:0] high_nib; 
        bit [3:0] low_nib;
        
        //$display("high_in %c, low in %c", high_in, low_in);

        high_nib =  (high_in < 58) ? high_in - 48 : 
                    (high_in < 71) ? high_in - 55 :
                    high_in - 87;

        low_nib =   (low_in < 58) ? low_in - 48 : 
                    (low_in < 71) ? low_in - 55 :
                    low_in - 86;

        instruction_byte = (high_nib << 4) + low_nib; 
        $display("High_nib %h, Low nib %h, Converted Instruction %h", high_nib, low_nib, instruction_byte);

    endtask

endclass

`endif