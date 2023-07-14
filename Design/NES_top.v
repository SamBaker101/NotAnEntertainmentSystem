//Sam Baker
//07/2023
//6502 NES top level module

//The intention of this project is not to make a bit perfect version of the NES but
//to try to dessign and implement my own version of the device which as closely
//Matches the specs and behavior of the original as possible

`ifndef TOP_NES
`define TOP_NES

//Not much here yet, here as a placeholder
module top(
		);

    //6502 Pinouts
    reg phi0, rdy, irq_n, NMI_n, overflow_set_n, reset_n;  //IN
    wire phi1, phi2, sync, R_W_n;                            //OUT
    wire [`ADDR_WIDTH - 1 : 0] A;                            //INOUT
    wire [`REG_WIDTH - 1 : 0] D;                             //INOUT

    cpu_top cpu(
		    .phi0(phi0), 
        .reset_n(reset_n),
		    .rdy(rdy), 
        .irq_n(irq_n), 
        .NMI_n(NMI_n), 
        .overflow_set_n(overflow_set_n),

        .phi1(phi1),
        .phi2(phi2),
        .sync(sync), 
        .R_W_n(R_W_n),

        .D(D),
        .A(A)
		);

endmodule

`endif