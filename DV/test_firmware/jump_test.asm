;   Sam Baker
;   11/2023
;   Tests jump instructions
;   Written for use with asm6502 assembler
;
;
; Test:       JMP, JSR, RTS
;             
;   Program: 

        .org $00A0
_jmp    JMP jmplab
        LDA #$00
        STA $00
jmplab  LDA #$01
        STA $01

_jsr    JSR jmprtn
        LDA #$02
        STA $02
jmprtn  LDA #$03
        STA $03
        
        .end
