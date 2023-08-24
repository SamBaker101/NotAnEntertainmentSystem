#	MAKEFILE
#	SAM BAKER 08/2023

SHELL = /bin/sh

####### FILES #######
SRC = PKG/test_program_macros.v PKG/pkg.v Design/*
TB = DV/tb_instruction_flow.sv
TBOUT = Out/tb.vvp
SIMOUT = Out/iflow.vcd
LOGOUT = Out/log.txt

####### TOOLS #######
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave

### DIRECTIVES #####
make : $(TB) $(SRC)
	$(COMPILER) -o $(TBOUT) $(TB) $(SRC)

sim: 
	$(SIMULATOR) $(TBOUT)
		

view:
	$(VIEWER) $(SIMOUT)

#make: iverilog -o Out/tb.vvp DV/tb_instruction_flow.sv