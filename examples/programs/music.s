    .setcpu "6502"
    .psc02                      ; Enable 65c02 opcodes

    .include "via.inc"
    .include "stdlib.inc"

LF      	= $0a
NULL    	= $00
CR      	= $0d
string_ptr 	= $00

.macro writeln str_addr
    LDA #<str_addr
    STA string_ptr
    LDA #>str_addr
    STA string_ptr+1
    JSR write
.endmacro

    .zeropage
temp_y:     .res 1
notel:      .res 2
noteh:      .res 2

    .code
; -------------  Play Music
    writeln happ_message

	lda #$40        ; 01000000
	sta VIA2_IER    ; Interrupt Enable Register

	lda #$c0        ; enable the timer (11000000)
	sta VIA2_ACR

	lda #$00		; start the timer
	sta VIA2_T1CL
	sta VIA2_T1CH

	lda #<NOTELSB
	sta notel
	lda #>NOTELSB
	sta notel + 1 	
	lda #<NOTEMSB
	sta noteh
	lda #>NOTEMSB
	sta noteh + 1
	
	ldy #$00
play:
	sty temp_y
	lda SONG_NOTES,y
	beq end     ; Song is null terminated.

	ldx SONG_TIMES,y
	tay
	lda (notel),y
	sta VIA2_T1CL
	lda (noteh),y
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

	ldy temp_y
	iny
	jmp play

end:
	lda #$00
	sta VIA2_ACR ; turn off timer.

rts              ; return to monitor

; ------------- ascii messages
happ_message: .asciiz "Happy Birthday To You!"
; ------------- Lookup tables

; Happy Birthday to you
SONG_NOTES:
	.byte $30, $30, $32, $30, $35, $34, $6C
	.byte $30, $30, $32, $30, $37, $35, $6C
	.byte $30, $30, $3C, $39, $35, $34, $32
	.byte $6c, $3A, $3A, $39, $35, $37, $35
	.byte $00

SONG_TIMES:
	.byte $04, $04, $08, $04, $08, $08, $0c
	.byte $04, $04, $08, $04, $08, $08, $0c
	.byte $04, $04, $0c, $0c, $0c, $0c, $0f
	.byte $0f, $04, $04, $08, $08, $08, $0f
     
NOTELSB:
	.byte $75	; 0		C0
	.byte $C4	; 1		C#0/Db0
	.byte $6F	; 2		D0
	.byte $6A	; 3		D#0/Eb0
	.byte $CF	; 4		E0
	.byte $78	; 5		F0
	.byte $7A	; 6		F#0/Gb0
	.byte $B8	; 7		G0
	.byte $3C	; 8		G#0/Ab0
	.byte $05	; 9		A0
	.byte $06	; A		A#0/Bb0
	.byte $44	; B		B0
	.byte $BA	; C		C1
	.byte $5E	; D		C#1/Db1
	.byte $34	; E		D1
	.byte $38	; F		D#1/Eb1
	.byte $67	; 10	E1
	.byte $BE	; 11	F1
	.byte $3A	; 12	F#1/Gb1
	.byte $DC	; 13	G1
	.byte $A0	; 14	G#1/Ab1
	.byte $82	; 15	A1
	.byte $84	; 16	A#1/Bb1
	.byte $A2	; 17	B1
	.byte $DC	; 18	C2
	.byte $2F	; 19	C#2/Db2
	.byte $9A	; 1A	D2
	.byte $1C	; 1B	D#2/Eb2
	.byte $B3	; 1C	E2
	.byte $5E	; 1D	F2
	.byte $1D	; 1E	F#2/Gb2
	.byte $EE	; 1F	G2
	.byte $CF	; 20	G#2/Ab2
	.byte $C1	; 21	A2
	.byte $C2	; 22	A#2/Bb2
	.byte $D1	; 23	B2
	.byte $EE	; 24	C3
	.byte $17	; 25	C#3/Db3
	.byte $4D	; 26	D3
	.byte $8E	; 27	D#3/Eb3
	.byte $D9	; 28	E3
	.byte $2F	; 29	F3
	.byte $8E	; 2A	F#3/Gb3
	.byte $F7	; 2B	G3
	.byte $67	; 2C	G#3/Ab3
	.byte $E0	; 2D	A3
	.byte $61	; 2E	A#3/Bb3
	.byte $E8	; 2F	B3
	.byte $77	; 30	C4
	.byte $0B	; 31	C#4/Db4
	.byte $A6	; 32	D4
	.byte $47	; 33	D#4/Eb4
	.byte $EC	; 34	E4
	.byte $97	; 35	F4
	.byte $47	; 36	F#4/Gb4
	.byte $FB	; 37	G4
	.byte $B3	; 38	G#4/Ab4
	.byte $70	; 39	A4
	.byte $30	; 3A	A#4/Bb4
	.byte $F4	; 3B	B4
	.byte $BB	; 3C	C5
	.byte $85	; 3D	C#5/Db5
	.byte $53	; 3E	D5
	.byte $23	; 3F	D#5/Eb5
	.byte $F6	; 40	E5
	.byte $CB	; 41	F5
	.byte $A3	; 42	F#5/Gb5
	.byte $7D	; 43	G5
	.byte $59	; 44	G#5/Ab5
	.byte $38	; 45	A5
	.byte $18	; 46	A#5/Bb5
	.byte $FA	; 47	B5
	.byte $DD	; 48	C6
	.byte $C2	; 49	C#6/Db6
	.byte $A9	; 4A	D6
	.byte $91	; 4B	D#6/Eb6
	.byte $7B	; 4C	E6
	.byte $65	; 4D	F6
	.byte $51	; 4E	F#6/Gb6
	.byte $3E	; 4F	G6
	.byte $2C	; 50	G#6/Ab6
	.byte $1C	; 51	A6
	.byte $0C	; 52	A#6/Bb6
	.byte $FD	; 53	B6
	.byte $EE	; 54	C7
	.byte $E1	; 55	C#7/Db7
	.byte $D4	; 56	D7
	.byte $C8	; 57	D#7/Eb7
	.byte $BD	; 58	E7
	.byte $B2	; 59	F7
	.byte $A8	; 5A	F#7/Gb7
	.byte $9F	; 5B	G7
	.byte $96	; 5C	G#7/Ab7
	.byte $8E	; 5D	A7
	.byte $86	; 5E	A#7/Bb7
	.byte $7E	; 5F	B7
	.byte $77	; 60	C8
	.byte $70	; 61	C#8/Db8
	.byte $6A	; 62	D8
	.byte $64	; 63	D#8/Eb8
	.byte $5E	; 64	E8
	.byte $59	; 65	F8
	.byte $54	; 66	F#8/Gb8
	.byte $4F	; 67	G8
	.byte $4B	; 68	G#8/Ab8
	.byte $47	; 69	A8
	.byte $43	; 6A	A#8/Bb8
	.byte $3F	; 6B	B8
	.byte $00  ; 6C   	NO NOTE

NOTEMSB:
	.byte $77	; 0		C0
	.byte $70	; 1		C#0/Db0
	.byte $6A	; 2		D0
	.byte $64	; 3		D#0/Eb0
	.byte $5E	; 4		E0
	.byte $59	; 5		F0
	.byte $54	; 6		F#0/Gb0
	.byte $4F	; 7		G0
	.byte $4B	; 8		G#0/Ab0
	.byte $47	; 9		A0
	.byte $43	; A		A#0/Bb0
	.byte $3F	; B		B0
	.byte $3B	; C		C1
	.byte $38	; D		C#1/Db1
	.byte $35	; E		D1
	.byte $32	; F		D#1/Eb1
	.byte $2F	; 10	E1
	.byte $2C	; 11	F1
	.byte $2A	; 12	F#1/Gb1
	.byte $27	; 13	G1
	.byte $25	; 14	G#1/Ab1
	.byte $23	; 15	A1
	.byte $21	; 16	A#1/Bb1
	.byte $1F	; 17	B1
	.byte $1D	; 18	C2
	.byte $1C	; 19	C#2/Db2
	.byte $1A	; 1A	D2
	.byte $19	; 1B	D#2/Eb2
	.byte $17	; 1C	E2
	.byte $16	; 1D	F2
	.byte $15	; 1E	F#2/Gb2
	.byte $13	; 1F	G2
	.byte $12	; 20	G#2/Ab2
	.byte $11	; 21	A2
	.byte $10	; 22	A#2/Bb2
	.byte $0F	; 23	B2
	.byte $0E	; 24	C3
	.byte $0E	; 25	C#3/Db3
	.byte $0D	; 26	D3
	.byte $0C	; 27	D#3/Eb3
	.byte $0B	; 28	E3
	.byte $0B	; 29	F3
	.byte $0A	; 2A	F#3/Gb3
	.byte $09	; 2B	G3
	.byte $09	; 2C	G#3/Ab3
	.byte $08	; 2D	A3
	.byte $08	; 2E	A#3/Bb3
	.byte $07	; 2F	B3
	.byte $07	; 30	C4
	.byte $07	; 31	C#4/Db4
	.byte $06	; 32	D4
	.byte $06	; 33	D#4/Eb4
	.byte $05	; 34	E4
	.byte $05	; 35	F4
	.byte $05	; 36	F#4/Gb4
	.byte $04	; 37	G4
	.byte $04	; 38	G#4/Ab4
	.byte $04	; 39	A4
	.byte $04	; 3A	A#4/Bb4
	.byte $03	; 3B	B4
	.byte $03	; 3C	C5
	.byte $03	; 3D	C#5/Db5
	.byte $03	; 3E	D5
	.byte $03	; 3F	D#5/Eb5
	.byte $02	; 40	E5
	.byte $02	; 41	F5
	.byte $02	; 42	F#5/Gb5
	.byte $02	; 43	G5
	.byte $02	; 44	G#5/Ab5
	.byte $02	; 45	A5
	.byte $02	; 46	A#5/Bb5
	.byte $01	; 47	B5
	.byte $01	; 48	C6
	.byte $01	; 49	C#6/Db6
	.byte $01	; 4A	D6
	.byte $01	; 4B	D#6/Eb6
	.byte $01	; 4C	E6
	.byte $01	; 4D	F6
	.byte $01	; 4E	F#6/Gb6
	.byte $01	; 4F	G6
	.byte $01	; 50	G#6/Ab6
	.byte $01	; 51	A6
	.byte $01	; 52	A#6/Bb6
	.byte $00	; 53	B6
	.byte $00	; 54	C7
	.byte $00	; 55	C#7/Db7
	.byte $00	; 56	D7
	.byte $00	; 57	D#7/Eb7
	.byte $00	; 58	E7
	.byte $00	; 59	F7
	.byte $00	; 5A	F#7/Gb7
	.byte $00	; 5B	G7
	.byte $00	; 5C	G#7/Ab7
	.byte $00	; 5D	A7
	.byte $00	; 5E	A#7/Bb7
	.byte $00	; 5F	B7
	.byte $00	; 60	C8
	.byte $00	; 61	C#8/Db8
	.byte $00	; 62	D8
	.byte $00	; 63	D#8/Eb8
	.byte $00	; 64	E8
	.byte $00	; 65	F8
	.byte $00	; 66	F#8/Gb8
	.byte $00	; 67	G8
	.byte $00	; 68	G#8/Ab8
	.byte $00	; 69	A8
	.byte $00	; 6A	A#8/Bb8
	.byte $00	; 6B	B8
	.byte $00  ; 6C    NO NOTE