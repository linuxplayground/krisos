; KrisOS LCD Library
;
; Copyright 2020 Kris Foster
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

.ifndef _LIB_LCD_
_LIB_LCD = 1

    .setcpu "6502"
    .psc02                      ; Enable 65c02 opcodes

    .include "lcd.inc"
    .include "via.inc"
    .include "../term/term.inc" ; XXX this is probably a bad sign

    .importzp string_ptr

    .export lcd_init
    .export lcd_write
    .export lcd_clear

    .segment "LIB"

lcd_init:
    PHA
    LDA #%00111000              ; Set 8-bit mode; 2-line display; 5x8 font
    JSR send_lcd_command
    
    LDA #%00001110              ; Display on; cursor on; blink off
    JSR send_lcd_command
    
    LDA #%00000110              ; Increment and shift cursor; don't shift display
    JSR send_lcd_command
    PLA
    RTS

lcd_clear:
    PHA
    LDA #LCD_CLEAR_DISPLAY
    JSR send_lcd_command
    LDX #2                      ; Clearing the LCD directly needs an idle timeout afterwards
                                ; Instead of using this direct hardware call 
:   LDA #$ff                    ; one option is to use a VideoRam based implementation and 
    JSR lcd_sleep               ; just clear the RAM cells - no sleep needed w/ such approach
    DEX
    BNE :-
    PLA
    RTS

send_lcd_command:
    PHA                         ; preserve A
send_lcd_command_loop:          ; wait until LCD becomes ready
    JSR check_busy_flag
    BNE send_lcd_command_loop
    PLA                         ; restore A

    STA VIA1_PORTB              ; Write accumulator content into VIA2_PORTB
    LDA #LCD_CLEAR
    STA VIA1_PORTA              ; Clear RS/RW/E bits
    LDA #LCD_ENABLE
    STA VIA1_PORTA              ; Set E bit to send instruction
    LDA #LCD_CLEAR
    STA VIA1_PORTA              ; Clear RS/RW/E bits
    RTS

; Need to write proper busy checking code
check_busy_flag:
    LDA #LCD_CLEAR              ; clear port A
    STA VIA1_PORTA              ; clear RS/RW/E bits

    LDA #LCD_RW                 ; prepare read mode
    STA VIA1_PORTA

    BIT VIA1_PORTB             ; read data from LCD
    BPL check_busy_flag_ready  ; bit 7 not set -> ready
    LDA #1                     ; bit 7 set, LCD is still busy, need waiting
    RTS
check_busy_flag_ready:
    LDA #0
    RTS

lcd_write:
    PHY
    LDY #00
lcd_write_loop:
    LDA (string_ptr), y
    BEQ lcd_write_done          ; NULL will make us branch
    JSR write_lcd
    INY
    JMP lcd_write_loop
lcd_write_done:
    PLY
    RTS

write_lcd:
    STA VIA1_PORTB                               ; Write accumulator content into VIA2_PORTB
    LDA #LCD_CLEAR
    STA VIA1_PORTA                               ; Clear RS/RW/E bits
    LDA #(LCD_RS | LCD_ENABLE)
    STA VIA1_PORTA                               ; SET E bit AND register select bit to send instruction
    LDA #LCD_CLEAR
    STA VIA1_PORTA                               ; Clear RS/RW/E bits
    RTS

lcd_sleep:
    tay
:   dey
    bne :-
    rts

.endif