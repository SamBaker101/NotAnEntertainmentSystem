//Sam Baker
//10/2023
//Class to handle load and handling of firmware for tests

`ifndef FW
`define FW

`include "PKG/pkg.v"

typedef logic [`REG_WIDTH - 1 : 0] fw_byte; 

class firmware;
    string test_name, fname;
    int fw_file, t;
    bit break_out;
    fw_byte temp;
    fw_byte [`MAX_FW_SIZE] fw;
    fw_byte [`MAX_FW_SIZE] fline;

    function new(string test_name);
        this.fname = $sformatf("Out/%s.hex", this.test_name);
    endfunction

    function void open_file();
        this.fw_file = $fopen(this.fname, "r");
        if (!this.fw_file) $display("ERROR opening file");    
    endfunction

    function void load_fw();
        while ($fgets(this.fline, this.fw_file)) begin
            this.break_out = 0;
            $display("PARSING: %s", this.fline);

            for (int i = 1; i < `MAX_FW_SIZE; i ++) begin
                if (this.break_out == 0) begin;
                    if ((this.fline[i] == ":") || (this.fline[i+1] == ":")) 
                        this.break_out = 1;
                    else begin
                        $display(" %c%c", this.fline[i], this.fline[i+1]);
                        this.convert_instruction(this.fline[i+1], this.fline[i], this.temp);
                        this.fw_push_front(this.temp);
                        i++;
                    end
                end
            end
        end
    endfunction

    function void fw_push_front(bit [7:0] input_byte); 
        //Workaround as queues in classes arent supported
        for (int i = 1; i < `MAX_FW_SIZE; i ++) begin
            fw[`MAX_FW_SIZE - i] = fw[`MAX_FW_SIZE - i - 1];
        end 
        fw[0] = input_byte;
    endfunction

    //FIXME: This needs fixing
    function void print_fw();
        int i;
        i = 4;
            $display("%0d : %h", i, this.fw[i]);
    endfunction

    task convert_instruction(input [7:0] high_in, [7:0] low_in, output [7:0] instruction_byte);
        bit [3:0] high_nib; 
        bit [3:0] low_nib;
        
        //$display("high_in %c, low in %c", high_in, low_in);

        high_nib =  (high_in < 58) ? high_in - 48 : 
                    (high_in < 71) ? high_in - 55 :
                    high_in - 87;

        low_nib =   (low_in < 58) ? low_in - 48 : 
                    (low_in < 71) ? low_in - 54 :
                    low_in - 86;

        //$display("high_nib %h, low nib %h", high_nib, low_nib);

        instruction_byte = (high_nib << 4) + low_nib; 
        //$display("Instruction %h", instruction_byte);
    endtask

endclass

`endif