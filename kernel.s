; KrisOS for the K64
; Copyright 2020 Kris Foster

    .setcpu "6502"
    .PSC02                      ; Enable 65c02 opcodes

    .include "term.inc"
    .include "kernel.inc"
    .include "lcd.inc"
    .include "command.inc"
    .include "via.inc"
    .include "toolbox.inc"

    .importzp nmi_ptr
    .importzp irq_ptr
    .importzp string_ptr
    .importzp char_ptr
    .importzp uptime

    .import acia_init
    .import XModemRcv
    .import setup_term
    .import read
    .import write
    .import write_char
    .import dump
    .import panic
    .import reset_user_input
    .import parse_command
    .import ACIA_DATA
    .import ACIA_STATUS
    .import lcd_init
    .import via1_init_ports
    .import via2_init_ports
    .import lcd_write
    .import binhex
    .import clear_screen
    .import sound_init
    .import startup_sound
    .import beep

    .code
main:
    SEI                         ; Disable interrupts while we initialize
    CLD                         ; Explicitly do not use decimal mode
    LDX #$FF                    ; Initialize our stack pointer
    TXS

    JSR acia_init               ; Set up the serial port
    writeln init_acia_msg

    writeln init_terminal_msg
    JSR setup_term              ; Pretty up the user's terminal

    writeln init_via_msg
    LDA #%11100001              ; LCD signals + 1 pin for LED
    LDX #%11111111              ; LCD databus lines
    JSR via1_init_ports         ; Initialize VIA
    LDA #%01100000
    LDA #%11111111
    JSR via2_init_ports
    writeln init_done_msg

    writeln init_sound_msg
    JSR sound_init
    JSR startup_sound
    writeln init_done_msg

    writeln init_lcd_msg
    JSR lcd_init                ; Set up the LCD display
    writeln_lcd krisos_lcd_message
    writeln init_done_msg

    writeln init_clear_userspace_msg
    LDA #$00
    LDX #$00
clear_page:                     ; Give the user's code clean space to run in
    STA user_code_segment,X
    CPX #$FF
    BEQ clear_done
    INX
    JMP clear_page
clear_done:
    writeln init_done_msg

    writeln init_default_interrupt_handlers
    JSR set_interrupt_handlers
    writeln init_done_msg
    writeln init_reenable_irq_msg
    CLI                         ; Re-enable interrupts
    writeln init_done_msg

    writeln build_time_msg
    write_hex_dword build_time
    writeln new_line

    writeln assembler_version_msg
    write_hex_word assembler_version
    writeln new_line

    ; We start the clock late because it's wired into NMI
    writeln init_clock_msg
    STZ16 uptime                ; Reset our uptime to zero
    LDA #%01000000              ; T1 continuous interrupts, PB7 disabled
    STA VIA1_ACR
    LDA #%11000000              ; Enable T1 interrupts
    STA VIA1_IER
    LDA #<TICK
    STA VIA1_T1CL               ; Low byte of interval counter
    LDA #>TICK
    STA VIA1_T1CH               ; High byte of interval counter
    writeln init_done_msg

    writeln init_start_cli_msg
    writeln welcome_msg

repl:                           ; Not really a repl but I don't have a better name
    writeln start_of_repl_msg
    JSR reset_user_input        ; Show a fresh prompt
    writeln prompt              ;
    JSR read                    ; Read command
    JSR parse_command
    ; Switch
    case_command #ERROR_CMD,    error
    case_command #LOAD_CMD,     XModemRcv
    case_command #RUN_CMD,      run_program
    case_command #DUMP_CMD,     dump
    case_command #HELP_CMD,     help
    case_command #SHUTDOWN_CMD, shutdown
    case_command #CLEAR_CMD,    clear_screen
    case_command #RESET_CMD,    main
    case_command #BREAK_CMD,    soft_irq
    case_command #BEEP_CMD,     beep
    case_command #UPTIME_CMD,   uptime_ticker
repl_done:
    JMP repl                    ; Do it all again!

start_of_repl_msg: .byte "start of repl",CR,LF,NULL

run_program:
    writeln calling_msg         ; Indicate that we're starting the user's code
    JSR user_code_segment       ; Start it!
    PHA                         ; Save our 16-bit return
    PHX                         ;
    writeln exited_msg
    PLA                         ; binhex takes the argument in the A register
    JSR binhex
    STA char_ptr
    JSR write_char              ; Display the high order byte
    STX char_ptr
    JSR write_char
    PLA
    JSR binhex
    STA char_ptr
    JSR write_char
    STX char_ptr
    JSR write_char              ; Display the low order byte
    writeln new_line
    JSR set_interrupt_handlers  ; Reset our default interrupt handlers
    writeln handlers_reset_msg
    RTS

handlers_reset_msg: .byte "handlers reset",CR,LF,NULL

error:
    writeln bad_command_msg
    RTS

help:
    writeln help_header_msg
    writeln help_commands_msg
    writeln help_copyright_msg
    RTS

shutdown:
    writeln shutdown_msg
    STP
    ; We do not return from this, ever.

uptime_ticker:
    writeln uptime_msg
    LDA uptime+1                ; High order byte of uptime
    JSR binhex
    STA char_ptr
    JSR write_char
    STX char_ptr
    JSR write_char
    LDA uptime                  ; Low order byte of uptime
    JSR binhex
    STA char_ptr
    JSR write_char
    STX char_ptr
    JSR write_char
    writeln new_line
    RTS

soft_irq:
    BRK
    .byte $00                   ; RTI sends us to second byte after BRK
    RTS

set_interrupt_handlers:
    LDA #<default_nmi
    STA nmi_ptr
    LDA #>default_nmi
    STA nmi_ptr+1
    LDA #<default_irq
    STA irq_ptr
    LDA #>default_irq
    STA irq_ptr+1
    RTS

nmi:
    PHA
    PHX
    PHY
uptime_handler:
    BIT VIA1_T1CL               ; Clear interrupt
    INC16 uptime
    JMP (nmi_ptr)               ; Call the user's NMI handler
default_nmi:                    ; Do nothing
    PLY
    PLX
    PLA
    RTI

bios_write_char:
    PHA
wait_txd_empty_char:
    LDA $4001
    AND #$10
    BEQ wait_txd_empty_char
    PLA
    STA $4000
    JMP return_call

bios_get_char:
    CLC
    LDA $4001
    AND #$08
    BEQ bios_get_char           ; Block until we get a character
    LDA $4000
    SEC
acia_get_char_done:
    JMP return_call

irq:
    ; TODO check if it's a BRK, that's a BIOS call
    ; Otherwise use the default handler
    JMP (irq_ptr)

default_irq:
    JMP (bios_jmp_table,X)
return_call:
    ;writeln default_irq_msg
    RTI

bios_jmp_table:
    .word $0000
    .word $0000
    .word bios_write_char
    .word bios_get_char

    .segment "VECTORS"
    .word nmi
    .word main
    .word irq