;   Sam Baker
;   10/2023
;   Tests alu functions
;   Written for use with asm6502 assembler

; Test: ADC, SBC, AND, EOR, ORA, ASL, LSR, ROL, ROR             

;   Program: 

preld   LDX #$02    
        LDY #$03
        LDA #$04

add     ADC #$10
        STA $02 
        LDA #$FF
        ADC #$10
        STA $03      

add     LDA #$12
        SBC #$10
        STA $04 
        SBC #$10
        STA $05      

              
        .end