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
			ALU_ROL

ifndef DEPTH
	DEPTH = 	"MEM_DEPTH='h01FF" 
endif

ifndef INST_BASE
	INST_BASE = "INSTRUCTION_BASE='h0150"
endif

ifndef SEED
	SEED = SEED=58585
endif

BUILD_DEFINES = -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D MEM_DUMP -D $(TEST_STRING) -D $(SEED)

### BASE DIRECTIVES #####
make :  $(TB) $(SRC)
	$(COMPILER) -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D "SELECT_TEST=\`TEST_$(TEST)" -D $(SEED) -o  Out/$(TEST).vvp $(TB) $(SRC) 

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
		$(COMPILER) -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D "SELECT_TEST=\`TEST_$(test)" -D $(SEED) -o  Out/$(test).vvp $(TB) $(SRC);)   \
	$(foreach test, $(TEST_LIST), 																				\
		$(SIMULATOR) Out/$(test).vvp;)																			\

clean : 
	rm -f Out/*.vvp Out/*.vcd 
