.ifndef _LIB_BLINK_
_LIB_BLINK_ = 1

    .setcpu "6502"
    .psc02                      ; Enable 65c02 opcodes

    .export blink_on
    .export blink_off

    .include "via.inc"
    .include "lcd.inc"
    .include "../util/print.inc"

    .import lcd_clear
    .import lcd_write
    .importzp string_ptr

blink_on:
    PHA
    strprint "Turning on the LED..."
    JSR lcd_clear
    writeln_lcd on_message
    LDA #%00000001
    STA VIA2_PORTA
    PLA
    RTS

blink_off:
    PHA
    strprint "Turning off the LED..."
    JSR lcd_clear
    writeln_lcd off_message
    LDA #%00000000
    STA VIA2_PORTA
    PLA
    RTS

on_message: 
    .asciiz "LED ON"
off_message: 
    .asciiz "LED OFF"

.endif
