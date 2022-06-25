.ifndef _LIB_DELAYMS_
_LIB_DELAY_ = 1

    .setcpu "6502"
    .psc02                      ; Enable 65c02 opcodes

    .export delayms

    .segment "LIB"

;------------------------------------------------------------------------------
delayms:
;------------------------------------------------------------------------------
; Number of milliseconds to delay in Y
; If Y = 0; then minimum time is 17 cycles 
;------------------------------------------------------------------------------
MSCNT = 198
    cpy #0      
    beq delay_ms_exit
    nop
    cpy #1
    bne delay_ms_a
    jmp delay_ms_last_1
delay_ms_a:
    dey
delay_ms_0:
    ldx #MSCNT
delay_ms_1:
    dex
    bne delay_ms_1
    nop
    nop
    dey
    bne delay_ms_0
delay_ms_last_1:
    ldx #MSCNT - 3
delay_ms_2:
    dex
    bne delay_ms_2
delay_ms_exit:
    rts
.endif