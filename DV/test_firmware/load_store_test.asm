;   This is temporary to test file load/interpretation before setting up assembler
;   Program: 
;   LDA #04      (imm)
;   STA $02      (zeropage)


begin   LDA #$04    ; load accum 
        STA $02     ; store

        .end
        
