; KrisOS for the K64
; Copyright 2020 Kris Foster

    .include "term.h"

    .setcpu "6502"
    .PSC02                      ; Enable 65c02 opcodes

; External imports
    .import acia_init
    .import XModemRcv
    .import setup_term
    .import read

    .code

reset:
    JSR acia_init
    JSR setup_term

    ; Get some input
    JSR XModemRcv
    JSR read

halt:
    JMP halt

nmi:
    RTI

irq:
    RTI

    .segment "VECTORS"
    .word nmi
    .word reset
    .word irq