;   Sam Baker
;   10/2023
;   Tests stack operations
;   Written for use with asm6502 assembler


; Test:       TSX, TXS, PHA, PHP, PLA, PLP


;   Program: 

preld   LDX #$02    
        LDY #$03

        
        .end