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

#### DEFINES ####
ifndef TEST
	TEST = NOOPP
endif

TEST_STRING = "SELECT_TEST=\`TEST_$(TEST)"

TEST_LIST = NOOPP \
			LDAZPG \
			LDAABS \
			LDYSTY \
			INDXY \
			ADC \
			ALU_LOG \
			ALU_ASL \
			ALU_LSR \
			ALU_INC


DUMP = MEM_DUMP
#DUMP = NO_DUMP

DEPTH = 	"MEM_DEPTH='h01FF" 
INST_BASE = "INSTRUCTION_BASE='h0150"

BUILD_DEFINES = -D $(DEPTH) -D $(INST_BASE) -D $(DUMP) -D $(TEST_STRING)

### BASE DIRECTIVES #####
make :  $(TB) $(SRC)
	$(COMPILER) -o  Out/$(TEST).vvp $(TB) $(SRC) 

build : $(TB) $(SRC)
	$(COMPILER) $(BUILD_DEFINES) -o Out/$(TEST).vvp $(TB) $(SRC) 

sim: 
	$(SIMULATOR) Out/$(TEST).vvp
		
view:
	$(VIEWER) $(SIMOUT)

### DERIVED DIRECTIVES ###
run: build sim

runall :   $(TB) $(SRC)
	$(foreach test, $(TEST_LIST), 																				\
		$(COMPILER) -D $(DEPTH) -D $(INST_BASE) -D "SELECT_TEST=\`TEST_$(test)" -o  Out/$(test).vvp $(TB) $(SRC);)   \
	$(foreach test, $(TEST_LIST), 																				\
		$(SIMULATOR) Out/$(test).vvp;)																			\


clean : 
	rm -f Out/*.vvp Out/*.vcd 