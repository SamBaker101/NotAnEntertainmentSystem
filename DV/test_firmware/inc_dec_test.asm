;   Sam Baker
;   10/2023
;   Tests increment and decrement operations
;   Written for use with asm6502 assembler


; Test:             DEC, DEX, DEY, INC, INX, INY

;   Program: 

        .org $0000
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

preld2  LDA #$03    
        LDX #$04
        LDY #$05
        STA $05

_inc    INC $05
        INX
        INY
        STX $06
        STY $07

        LDX #$FF
        INX
        INX
        STX $08