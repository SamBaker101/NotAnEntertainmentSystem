#	MAKEFILE
#	SAM BAKER 08/2023

SHELL = /bin/sh

####### FILES #######
SRC = PKG/test_program_macros.v PKG/pkg.v Design/data_bus.v Design/decoder.v Design/fetcher.v Design/mem.v Design/mux831.v Design/fan138.v Design/register.v Design/clock_module.v Design/ALU.v Design/6502_top.v Design/switch.v
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
	$(COMPILER) -o $(TBOUT) $(SRC)

sim: 
	$(SIMULATOR) $(TBOUT) >> $(LOGOUT)

view:
	$(VIEWER) $(SIMOUT)

#MAKE DEPENDANCIES
$(TBOUT): $(COUTPUT)
	$(SIMULATOR) $(SOPTIONS) $(COUTPUT) $(SOUTPUT)

$(COUTPUT): $(TB) $(SRC)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TB) $(SRC)

#make: iverilog -o Out/tb.vvp DV/tb_instruction_flow.sv