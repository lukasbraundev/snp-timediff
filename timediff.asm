;-----------------------------------------------------------------------------
; timediff.asm - 
;-----------------------------------------------------------------------------
;
; DHBW Ravensburg - Campus Friedrichshafen
;
; Vorlesung Systemnahe Programmierung (SNP)
;
;----------------------------------------------------------------------------
;
; Architecture:  x86-64
; Language:      NASM Assembly Language
;
; Authors:
;
;----------------------------------------------------------------------------

%include "syscall.inc"  ; OS-specific system call macros

extern ASCII_to_timeval
extern timeval_to_ASCII

;---Function declerations----------------------------------------------------
extern displayError
extern list_init
extern list_size
extern list_is_sorted
extern list_add
extern list_find
extern list_get
;----------------------------------------------------------------------------
sys_read equ 3
sys_write equ 4
stdout equ 1
stdin equ 2

BUFFER_SIZE equ 80

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        userMsg db 'Please enter a timestamp (to end write "F"): ' ;Message to ask the User to Enter a new timestamp
        lenUserMsg equ $-userMsg                ;The length of the message

timeval:
        tv_sec  dq 0
        tv_usec dq 0

        timestamp db '97.98'
        lenTimestamp equ $-timestamp
        time_char db '10000 00000000000000.000000'
        lenTimeChar equ $-time_char

;-----------------------------------------------------------------------------
; SECTION BSS
;-----------------------------------------------------------------------------
SECTION .bss
        timestamp_input resb 128
                align 128               ; make sure that buffer adress is a multiple of 128
        buffer  resb BUFFER_SIZE        ; buffersize for input
                resb 128                ; zero after buffer so that buffer end can be determined


;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
        global _start:function          ; make label available to linker

_start:                                 ; Programm Start

; Beispiel implementation of the function ASCII_to_timeval
        ; push WORD lenTimestamp
        ; push timestamp
        ; push timeval
        ; call ASCII_to_timeval
        ; add rsp, 18

        ; cmp rax, 0                      ; check if conversion was successful
        ; je readNextTimestamp            ; if not, read next timestamp

        ; push timeval
        ; push time_char
        ; call timeval_to_ASCII
        ; add rsp, 16

        ; Write time_char
        ; mov eax, sys_write              ; Sys-Call Number (Write)
        ; mov ebx, stdout                 ; file discriptor (STD OUT)
        ; mov ecx, time_char              ; Message to write
        ; mov edx, lenTimeChar            ; length of the Message
        ; int 80h                         ; call Kernel

; Beispiel END

read_next_string:
        ; Read from STD in
        mov eax, sys_read               ; Sys-Call Number (Read)
        mov ebx, stdin                  ; file discriptor (STD IN)
        mov ecx, buffer                 ; input is stored into timestamp_input
        mov edx, BUFFER_SIZE            ; size of Input
        int 80h                         ; call Kernel

        test eax, eax                   ; check Return value
        jz finishedInput                ; jump to calculation if buffer empty
        lea rsi, [buffer]               ; loads adress of first char into rsi
        mov byte [buffer+rax], 128      ; determines the End of the Buffer

next_char:      
        movzx   rdx, byte [rsi]         ; load next char from buffer
        cmp     rdx,127                 ; check if its a char
        ja      read_next_string        ; jump if no char
        ; TODO Move char in variable if not a linefeed
        ; if linefeed, than check variable for correct synthax



finishedInput:
        nop

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
.exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
