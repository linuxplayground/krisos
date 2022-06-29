.ifndef _LIB_LED_
_LIB_LED_ = 1

    .setcpu "6502"
    .psc02                      ; Enable 65c02 opcodes

    .export led_on
    .export led_off

    .include "via.inc"
    .include "lcd.inc"
    .include "../util/print.inc"
    .include "../stdlib/stdlib.inc"

    .import lcd_clear
    .import lcd_write
    .importzp string_ptr

LF      = $0a
NULL    = $00
CR      = $0d


.macro writeln str_addr
    LDA #<str_addr
    STA string_ptr
    LDA #>str_addr
    STA string_ptr+1
    JSR write
.endmacro

led_on:
    PHA
    writeln on_message
    JSR lcd_clear
    writeln_lcd on_message
    LDA #%00000001
    STA VIA2_PORTA
    PLA
    RTS

led_off:
    PHA
    writeln off_message
    JSR lcd_clear
    writeln_lcd off_message
    LDA #%00000000
    STA VIA2_PORTA
    PLA
    RTS

on_message: 
    .byte "LED ON", CR, LF, NULL
off_message: 
    .byte "LED OFF", CR, LF, NULL

.endif
