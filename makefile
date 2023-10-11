#	MAKEFILE
#	SAM BAKER 08/2023

SHELL = /bin/sh

####### FILES #######
SRC = PKG/test_program_macros.v PKG/pkg.v Design/*
TBOUT = Out/tb.vvp
SIMOUT = Out/iflow.vcd
LOGOUT = Out/log.txt

#Note: design has changed since creating lower level tbs, they may no longer function
ifndef TB
	TB = DV/tb_6502_top.sv
endif

####### TOOLS #######
COMPILER = iverilog
GEN = 2012
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
			ALU_INC \
			ALU_DEC \
			ALU_ROT \
			ALU_SBC \
			CMP 	\
			CPX		\
			CPY
 
ifndef DEPTH
	DEPTH = 	"MEM_DEPTH='h01FF" 
endif

ifndef INST_BASE
	INST_BASE = "INSTRUCTION_BASE='h0140"
endif

ifndef STACK_BASE
	STACK_BASE = "STACK_BASE='h0180"
endif

ifndef SEED
	SEED = SEED=58585
endif

BUILD_DEFINES = -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D $(STACK_BASE) -D "SELECT_TEST=\`TEST_$(TEST)" -D $(SEED) -D MEM_DUMP 

### BASE DIRECTIVES #####
make :  $(TB) $(SRC)
	$(COMPILER) -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D $(STACK_BASE) -D "SELECT_TEST=\`TEST_$(TEST)" -D $(SEED) -o  Out/$(TEST).vvp $(TB) $(SRC) 

build : $(TB) $(SRC)
	$(COMPILER) $(BUILD_DEFINES) -o Out/$(TEST).vvp $(TB) $(SRC) 

sim: 
	$(SIMULATOR) Out/$(TEST).vvp
		
view:
	$(VIEWER) $(SIMOUT)

### DERIVED DIRECTIVES ###
run: clean build sim

clean : 
	rm -f Out/*.vvp Out/*.vcd 

runall : clean $(TB) $(SRC)																																		
	$(foreach test, $(TEST_LIST), 																				\
		$(COMPILER) -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D $(STACK_BASE) -D "SELECT_TEST=\`TEST_$(test)" -D $(SEED) -o  Out/$(test).vvp $(TB) $(SRC);)   \
	$(foreach test, $(TEST_LIST), 																				\
		$(SIMULATOR) Out/$(test).vvp;)																			\


