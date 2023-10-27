;   Sam Baker
;   10/2023
;   Tests increment and decrement operations
;   Written for use with asm6502 assembler


; Test:             DEC, DEX, DEY, INC, INX, INY

;   Program: 

preld   LDA #$01    
        LDX #$02
        LDY #$03
        STA $01

_dec    DEC $01
        DEX
        DEY
        STX $02
        STY $03

        LDX #$01
        DEX
        DEX
        STX $04