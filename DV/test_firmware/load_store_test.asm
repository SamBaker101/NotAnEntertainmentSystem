;   This is temporary to test file load/interpretation

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

        .end