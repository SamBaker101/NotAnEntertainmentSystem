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
        CMP $03
        BEQ beqlab

        JMP endlab

jmprtn  LDA #$03
        STA $03
        RTS

beqlab  LDA #$04
        STA $04

endlab  CLC

        .end
