;   Sam Baker
;   10/2023
;   Tests stack operations
;   Written for use with asm6502 assembler


; Test:       TSX, TXS, PHA, PHP, PLA, PLP
;Also Uses    SEC, CLC

;   Program: 

preld   LDA #$05
        LDX #$02    
        LDY #$03

_rv     TSX
        STX $00         ;Check stack reset vector
        
_acc    PHA
        LDA #$02
        PHA
        
        TSX
        STX $01

        LDA #$03
        PLA
        STA $02
        PLA
        STA $03

_stat   SEC
        PHP
        CLC
        PLP

        .end