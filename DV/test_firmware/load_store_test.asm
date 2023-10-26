;   Sam Baker
;   10/2023
;   Tests load and store instructions with various addressing modes
;   Written for use with asm6502 assembler


; Test:             LDA, LDX, LDY, STA, STX, STY
; Addr Modes:       Imm, ZPG, ZPGX, ABS, ABSX, ABSY, INDX, INDY

;   Program: 

preld   LDX #$02    
        LDY #$03

loada   LDA #$04     
        STA $02     
        LDA $02,X
        STA $0002,Y
        LDA ($02),y
        STA $01
        LDA #$05
        STA ($01,X)

loady   LDY #$1F   
        STY $04     
        LDY $06,X
        STY $000C

loadx   LDX #$FF   
        STX $06     
        LDX $06
        STX $0070

        .end