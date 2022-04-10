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


;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
        global _start:function          ; make label available to linker

_start:                                 ; Programm Start
; call error handler function
        ;push WORD 0                    ; push idx of error Msg
        ;call displayError              ; function call
        ;add rsp, 2


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

readNextTimestamp:
        ;Read and store the user input
        mov eax, sys_read               ; Sys-Call Number (Read)
        mov ebx, stdin                  ; file discriptor (STD IN)
        mov ecx, timestamp_input        ; input is stored into timestamp_input
        mov edx, 128                    ; size of Input (Byte)
        int 80h                         ; call Kernel

        ;Compare if timestamp is F
        lea     rsi, [timestamp_input]  ; load the address of buffer to rsi
        movzx   rdx, byte [rsi]         ; load first char to
        cmp     rdx, 70                 ; check if first char is "F"
        je      finishedInput           ; if its F input is finished
        ;TODO --> Add to list
        jne     readNextTimestamp       ; not F input not finished



finishedInput:
        nop

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
.exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
