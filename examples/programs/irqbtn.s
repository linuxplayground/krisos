    .setcpu "6502"
    .psc02                      ; Enable 65c02 opcodes

    .include "via.inc"
    .include "stdlib.inc"


LF          = $0a
NULL        = $00
CR          = $0d
string_ptr  = $00

.macro writeln str_addr
    LDA #<str_addr
    STA string_ptr
    LDA #>str_addr
    STA string_ptr+1
    JSR write
.endmacro

    .code
main:
    lda #<irq       ; set up IRQ handler for sixty5o2
    sta irq_ptr
    lda #>irq
    sta irq_ptr + 1

    lda #$00        ; set all PA to input.  Will break LCD.
    sta VIA1_DDRA
    sta $10F1

    lda #$82        ; Enable CA1 interrupt on the VIA (10000010)
    sta VIA1_IER
    lda #$01
    sta VIA1_PCR    ; Set CA1 to trigger on negative transition (going low)    

loop:
    clc
    jsr getch_nw
    bcs exit
    jmp loop
exit:
    rts

irq:
    pha
    txa
    pha
    tya
    pha

    lda VIA1_PORTA
    and #$0F
    cmp #$1
    beq out_1
    cmp #$2
    beq out_2
    cmp #$4
    beq out_3
    cmp #$8
    beq out_4
    jmp exit_irq
out_1:
    writeln L1
    jsr beep
    jmp exit_irq
out_2:
    writeln L2
    jmp exit_irq
out_3:
    writeln L3
    jmp exit_irq
out_4:
    writeln L4
exit_irq:    
    ldy #250
    jsr delayms

    pla
    tay
    pla
    tax
    pla

    rti

L1: .byte "BTN-1",LF,CR,NULL
L2: .byte "BTN-2",LF,CR,NULL
L3: .byte "BTN-3",LF,CR,NULL
L4: .byte "BTN-4",LF,CR,NULL