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

_bmi    LDX #$04
        CPX #$02
        BMI bmilab
        LDA #$09
        STA $09
        LDX #$02
        CPX #$04
        BMI bmilab
        LDA #$0A
        STA $0A
bmilab  LDA #$0B
        STA $0B
        LDX #$04
        CPX #$02

_bne    LDX #$02
        CPX #$02
        BNE bnelab
        LDA #$0C
        STA $0C
        LDX #$02
        CPX #$04
        BNE bnelab
        LDA #$0D
        STA $0D
bnelab  LDA #$0E
        STA $0E
        LDX #$04
        CPX #$02

_bpl    LDX #$02
        CPX #$04
        BPL bpllab
        LDA #$0F
        STA $0F
        LDX #$04
        CPX #$02
        BPL bpllab
        LDA #$10
        STA $10
bpllab  LDA #$11
        STA $11
        LDX #$02
        CPX #$04

_bvc    LDA #$7F
        ADC #$01
        BVC bvclab
        LDA #$12
        STA $12
        LDA #$02
        ADC #$01
        BVC bvclab
        LDA #$13
        STA $13
bvclab  LDA #$14
        STA $14
        LDA #$7F
        ADC #$01

_bvs    LDA #$02
        ADC #$01
        BVS bvslab
        LDA #$15
        STA $15
        LDA #$7F
        ADC #$01
        BVS bvslab
        LDA #$16
        STA $16
bvslab  LDA #$17
        STA $17
        LDA #$02
        ADC #$01

        .end
