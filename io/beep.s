; Generate a beep note at C4

.ifndef _LIB_BEEP_
_LIB_BEEP_ = 1

    .setcpu "6502"
    .psc02                      ; Enable 65c02 opcodes

    .include "via.inc"
    .export beep

    .segment "LIB"

beep:
	lda #$40        ; 01000000
	sta VIA2_IER    ; Interrupt Enable Register

	lda #$c0        ; enable the timer (11000000)
	sta VIA2_ACR

	lda #$00		; start the timer
	sta VIA2_T1CL
	sta VIA2_T1CH
	
play:
	ldx #$02
	lda #$77
	sta VIA2_T1CL
	lda #$00
	sta VIA2_T1CH
again:
	lda #$4e	; wait for 0.05 seconds
	sta VIA2_T2CL
	lda #$c3
	sta VIA2_T2CH
	lda #$20
wait:
	bit VIA2_IFR
	beq wait
	dex
	bne again	; keep waiting until duration is up.

end:
	lda #$00
	sta VIA2_ACR ; turn off timer.

    rts
.endif