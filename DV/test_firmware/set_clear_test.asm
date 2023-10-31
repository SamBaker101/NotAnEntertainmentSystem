;   Sam Baker
;   10/2023
;   Tests status set and clear instructions
;   Written for use with asm6502 assembler


; Test:         CLC, CLD, CLI, CLV, SEC, SED, SEI
; Also uses:    PHP, PLA to push stat to stack and pull it onto accumulator

;   Program: 

_carry  SEC
        PHP
        PLA
        STA $00
        CLC
        

