;   Sam Baker
;   10/2023
;   Tests stack operations
;   Written for use with asm6502 assembler
;
;
; Test:       BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS
;
;   Program: 

        .org $0000
begin   SEC
        BCC LABEL
        LDA #$00
        STA $00
        CLC
        BCC LABEL
        LDA #$01
        STA $01
LABEL   LDA #$02
        STA $02
        CLC

        .end