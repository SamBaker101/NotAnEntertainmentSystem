//Sam Baker
//10/2023
//Interface for overwriting mem

`ifndef MEM_OVER
`define MEM_OVER

interface mem_over_if (input clk, reset_n); 
    logic [`REG_WIDTH - 1 : 0] test_mem [`MEM_DEPTH - 1 : 0];
    logic [`REG_WIDTH - 1 : 0] real_mem [`MEM_DEPTH - 1 : 0];
    logic mem_override;


    task override_real_mem();
        if (reset_n) $display("ERROR: cannot overwrite mem while not in reset");
        else begin
            for (int i = 0; i < `MEM_DEPTH; i++) begin
                test_mem[i] = mem_model[i];
            end

            #10;
            mem_override <= 1'b1;
            #50;

            //TODO: This is just for troubleshooting
            for (int i = 0; i < 8; i++) begin
                $write("|%h: %h = %h | ", i, test_mem[i], real_mem[i]);
            end
            $display("\n");

            #20;
            mem_override <= 1'b0;
        end
    endtask : override_real_mem
endinterface

`endif