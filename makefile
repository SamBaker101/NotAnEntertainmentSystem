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
TEST_NAME = TEST_NOOPP
TEST_STRING = "SELECT_TEST=\`$(TEST_NAME)"
#TEST_STRING = "SELECT_TEST \`TEST_LDAZPG"
#TEST_STRING = "SELECT_TEST \`TEST_LDAABS"
#TEST_STRING = "SELECT_TEST \`TEST_LDYSTY"
#TEST_STRING = "SELECT_TEST \`TEST_INDXY"     
#TEST_STRING = "SELECT_TEST \`TEST_ADC"
#TEST_STRING = "SELECT_TEST \`TEST_ALU_LOG"
#TEST_STRING = "SELECT_TEST \`TEST_ALU_ASL"
#TEST_STRING = "SELECT_TEST \`TEST_ALU_LSR"
#TEST_STRING = "SELECT_TEST \`TEST_ALU_INC"

TEST_LIST = TEST_NOOPP \
			TEST_LDAZPG \
			TEST_LDAABS \
			TEST_LDYSTY \
			TEST_INDXY \
			TEST_ADC \
			TEST_ALU_LOG \
			TEST_ALU_ASL \
			TEST_ALU_LSR \
			TEST_ALU_INC


DUMP = MEM_DUMP
#DUMP = NO_DUMP

DEPTH = 	"MEM_DEPTH='h01FF" 
INST_BASE = "INSTRUCTION_BASE='h0150"

BUILD_DEFINES = -D $(DEPTH) -D $(INST_BASE) -D $(DUMP) -D $(TEST_STRING)

### BASE DIRECTIVES #####
make :  $(TB) $(SRC)
	$(COMPILER) -o  Out/$(TEST_NAME).vvp $(TB) $(SRC) 

build : $(TB) $(SRC)
	$(COMPILER) $(BUILD_DEFINES) -o Out/$(TEST_NAME).vvp $(TB) $(SRC) 

sim: 
	$(SIMULATOR) $(TBOUT)
		
view:
	$(VIEWER) $(SIMOUT)

### DERIVED DIRECTIVES ###
go: build sim

runall :   $(TB) $(SRC)
	$(foreach test, $(TEST_LIST), 																				\
		$(COMPILER) -D $(DEPTH) -D $(INST_BASE) -D "SELECT_TEST=\`$(test)" -o  Out/$(test).vvp $(TB) $(SRC);)   \
	$(foreach test, $(TEST_LIST), 																				\
		$(SIMULATOR) Out/$(test).vvp;)																			\


