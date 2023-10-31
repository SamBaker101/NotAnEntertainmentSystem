;   Sam Baker
;   10/2023
;   Tests stack operations
;   Written for use with asm6502 assembler


; Test:       BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS

;   Program: 

_bcc    SEC
        BCC tag
        LDA #$00
        STA $00
        CLC
        BCC tag
        LDA #$01
        STA $01
  tag   LDA #$02
        STA $02
        CLC

        .end