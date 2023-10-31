;   Sam Baker
;   10/2023
;   Tests alu functions
;   Written for use with asm6502 assembler

; Test: ADC, SBC, AND, EOR, ORA, ASL, LSR, ROL, ROR    
;       CMP, CPX, CPY         

;   Program: 

preld   LDX #$02    
        LDY #$03
        LDA #$04

add     ADC #$10
        STA $02 
        LDA #$FF
        ADC #$10
        STA $03  

        PHP
        PLA
        STA $0E

sub     LDA #$12
        SBC #$10
        STA $04 
        SBC #$10
        STA $05   

        PHP
        PLA
        STA $0F

_and    LDA #$F0
        AND #$AA
        STA $06

_eor    LDA #$F0
        EOR #$AA
        STA $07

_ora    LDA #$F0
        ORA #$AA
        STA $08

;TODO: Assembler doesnt like shifting Accumulator?
_asl    LDA #$0F
        STA $09
        ASL $09
        STA $09
        ASL $09
        STA $09

        PHP
        PLA
        STA $10

_lsr    LDA #$F0
        STA $0A
        LSR $0A
        STA $0A
        LSR $0A
        STA $0A

_rol    LDA #$F0
        STA $0B
        ROL $0B
        STA $0B

_ror    LDA #$0F
        STA $0C
        ROR $0C
        STA $0C

        PHP
        PLA
        STA $11

_cmp    CLC
        LDA #04
        CMP #$04
        PHP
        PLA
        STA $0D

        LDA #06
        CMP #$04
        PHP
        PLA
        STA $12

        LDA #04
        CMP #$06
        PHP
        PLA
        STA $13

_cpx    CLC
        LDX #04
        CPX #$04
        PHP
        PLA
        STA $14

        LDX #06
        CPX #$04
        PHP
        PLA
        STA $15

        LDX #04
        CPX #$06
        PHP
        PLA
        STA $16

_cpy    CLC
        LDY #04
        CPY #$04
        PHP
        PLA
        STA $17

        LDY #06
        CPY #$04
        PHP
        PLA
        STA $18

        LDY #04
        CPY #$06
        PHP
        PLA
        STA $19
        .end