//Sam Baker
//10/2023
//Interface for overwriting mem

`ifndef MEM_OVER
`define MEM_OVER

interface mem_over_if (input clk, reset_n); 
    logic [`REG_WIDTH - 1 : 0] test_mem [`MEM_DEPTH - 1 : 0];
    logic [`REG_WIDTH * `MEM_DEPTH - 1 : 0] flat_mem;
    wire [`REG_WIDTH - 1 : 0] real_mem [`MEM_DEPTH - 1 : 0];
    logic mem_override;

    genvar j;
    for (j = 0; j < `MEM_DEPTH; j++)
        assign real_mem[j] = flat_mem[((j + 1) * `REG_WIDTH - 1) : (j*`REG_WIDTH)];

    task override_real_mem();
        if (reset_n) $display("ERROR: cannot overwrite mem while not in reset");
        else begin
            for (int i = 0; i < `MEM_DEPTH; i++) begin
                test_mem[i] = mem_model[i];
            end

            #10;
            mem_override <= 1'b1;
            #20;
            mem_override <= 1'b0;
        end
    endtask : override_real_mem

    task dump_mem(int start = 0, int finish = `MEM_DEPTH);
        int i;
        for (i = start; i < finish; i++) begin
            if (((i - start) % 8 == 0) && (i - start != 0)) $display(" ");
            $write("| %h:%h = %h | ", i, real_mem[i], mem_model[i]);
        end
        $display(" ");
    endtask : dump_mem

endinterface

`endif