;   Sam Baker
;   10/2023
;   Tests status set and clear instructions
;   Written for use with asm6502 assembler


; Test:         CLC, CLD, CLI, CLV, SEC, SED, SEI
; Also uses:    PHP, PLA to push stat to stack and pull it onto accumulator

;   Program: 

        .org $0000
_carry  SEC
        PHP
        PLA
        STA $00
        CLC

_intdis SEI
        PHP
        PLA
        STA $01
        CLI

_dec    SED
        PHP
        PLA
        STA $02
        CLD

_over   LDA #$7F
        ADC $00
        PHP
        PLA
        STA $03
        CLV
        PHP
        PLA
        STA $04
