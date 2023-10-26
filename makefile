#	MAKEFILE
#	SAM BAKER 08/2023

SHELL = /bin/sh

####### FILES #######
SRC = PKG/test_program_macros.v PKG/pkg.v Design/* DV/Structure/*
TBOUT = Out/tb.vvp
SIMOUT = Out/6502_test_out.vcd
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

#I'm using the ASM6502 Assembler from: https://github.com/SYSPROG-JLS/6502Asm
#Other Assembler Options: http://6502.org/tools/asm/
ASSEMBLER_COMMAND = python
ASSEMBLER = asm6502.py
ASSEMBLER_PATH = Z_6502Asm/
#FW_PATH = DC/test_firmware/
#just for testing the assembler
FW_SOURCE_PATH =DV/test_firmware/
FW_OUT_PATH =Out/

#### DEFINES ####
ifndef TEST
	TEST = load_store_test
endif

TEST_DEFINE = 'TEST_NAME="$(TEST)"'
FW_SOURCE =$(FW_SOURCE_PATH)$(TEST).asm
FW_OUT =$(FW_OUT_PATH)$(TEST).hex

TEST_LIST = load_store_test \
			alu_test \
			
 
ifndef DEPTH
	DEPTH = 	"MEM_DEPTH='h00FF" 
endif

ifndef INST_BASE
	INST_BASE = "INSTRUCTION_BASE='h0A0"
endif

ifndef STACK_BASE
	STACK_BASE = "STACK_BASE='h0080"
endif

ifndef SEED
	SEED = SEED=58585
endif

BUILD_DEFINES = -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D $(STACK_BASE) -D $(SEED) -D $(TEST_DEFINE) -D MEM_DUMP 
COMMANDS = assemble build sim

### BASE DIRECTIVES #####
make :  $(TB) $(SRC)
	$(COMPILER) -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D $(STACK_BASE) -D $(SEED) -o  Out/$(TEST).vvp $(TB) $(SRC) 

build : $(TB) $(SRC)
	$(COMPILER) $(BUILD_DEFINES) -o Out/$(TEST).vvp $(TB) $(SRC) 

sim: 
	$(SIMULATOR) Out/$(TEST).vvp
		
view:
	$(VIEWER) $(SIMOUT)

assemble: 
	$(ASSEMBLER_COMMAND) $(ASSEMBLER_PATH)$(ASSEMBLER) $(FW_SOURCE); \
	mv $(FW_SOURCE_PATH)$(TEST).hex $(FW_OUT); \
	mv $(FW_SOURCE_PATH)$(TEST).lst $(FW_OUT_PATH)$(TEST).lst;

### DERIVED DIRECTIVES ###
run: clean $(COMMANDS)

clean : 
	rm -f Out/* 

TEST_DEFINE = 'TEST_NAME="$(TEST)"'
FW_SOURCE =$(FW_SOURCE_PATH)$(TEST).asm
FW_OUT =$(FW_OUT_PATH)$(TEST).hex

runall : clean $(TB) $(SRC)																																		
	$(foreach test, $(TEST_LIST), 															\
		$(ASSEMBLER_COMMAND) $(ASSEMBLER_PATH)$(ASSEMBLER) $(FW_SOURCE_PATH)$(test).asm; 	\
		mv $(FW_SOURCE_PATH)$(test).hex $(FW_OUT_PATH)$(test).hex; 							\
		mv $(FW_SOURCE_PATH)$(test).lst $(FW_OUT_PATH)$(test).lst;							\
		$(COMPILER) -g $(GEN) -D $(DEPTH) -D $(INST_BASE) -D $(STACK_BASE) -D $(SEED) -D 'TEST_NAME="$(test)"' -o Out/$(test).vvp $(TB) $(SRC);  \
		$(SIMULATOR) Out/$(test).vvp;														\
	)						


