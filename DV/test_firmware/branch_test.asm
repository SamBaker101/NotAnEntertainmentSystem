;   Sam Baker
;   10/2023
;   Tests stack operations
;   Written for use with asm6502 assembler
;
;
; Test:       BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS
;             BMI, BNE, BPL, BVC, BVS
;   Program: 

        .org $0000
_bcc    SEC
        BCC bcclab
        LDA #$00
        STA $00
        CLC
        BCC bcclab
        LDA #$01
        STA $01
bcclab  LDA #$02
        STA $02

_bcs    CLC
        BCS bcslab
        LDA #$03
        STA $03
        SEC
        BCS bcslab
        LDA #$04
        STA $04
bcslab  LDA #$05
        STA $05
        CLC

_beq    LDX #$02
        CPX #$04
        BEQ beqlab
        LDA #$06
        STA $06
        LDX #$02
        CPX #$02
        BEQ beqlab
        LDA #$07
        STA $07
beqlab  LDA #$08
        STA $08
        LDX #$04
        CPX #$02

        .end