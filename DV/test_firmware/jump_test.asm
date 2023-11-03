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
        JMP jmplab
        CLC               ;This is just to kill a cycle
        LDA #$00
        STA $00
jmplab  LDA #$01
        STA $01

        .end
