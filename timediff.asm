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
extern timeval_to_daystring

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

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        userMsg db 'Please enter a timestamp (to end write "F"): ' ;Message to ask the User to Enter a new timestamp
        lenUserMsg equ $-userMsg                ;The length of the message

timeval:
        tv_sec  dq 0
        tv_usec dq 0

; Example: implementation of the function ASCII_to_timeval and timeval_to_ASCII
        timestamp db '12345678901234567890.123456'
        lenTimestamp equ $-timestamp
        time_char db 'abcdfghijklmnopqrstupabcdef', 10
        lenTimeChar equ $-time_char
; Example: END

; Example: implementation of the function timeval_to_daystring
        daystring db 'DDDDDDDDDDDDDDD days, HH:MM:SS.UUUUUU', 10
        lenDaystring equ $-daystring
; Example: END

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

; Example: implementation of the function ASCII_to_timeval and timeval_to_ASCII
        ; ; bool ASCII_to_timeval(struct timeval *tv, char *ascii_time, short len)
        ; mov rdi, timeval
        ; mov rsi, timestamp
        ; xor rdx, rdx
        ; mov dx, lenTimestamp
        ; call ASCII_to_timeval
        ; ; rax now holds 1 if successful, 0 if not

        ; ; void timeval_to_ASCII(char *ascii_time, struct timeval *tv)
        ; mov rdi, time_char
        ; mov rsi, timeval
        ; call timeval_to_ASCII

        ; ; Write time_char
        ; mov eax, sys_write              ; Sys-Call Number (Write)
        ; mov ebx, stdout                 ; file discriptor (STD OUT)
        ; mov ecx, time_char              ; Message to write
        ; mov edx, lenTimeChar            ; length of the Message
        ; int 80h                         ; call Kernel

; Example: END

; Example: implementation of the function timeval_to_daystring
        ; ; void timeval_to_daystring(char *daystring, struct timeval *tv)
        ; mov rdi, daystring
        ; mov rsi, timeval
        ; call timeval_to_daystring

        ; ; Write daystring
        ; mov rax, sys_write              ; Sys-Call Number (Write)
        ; mov rbx, stdout                 ; file discriptor (STD OUT)
        ; mov rcx, daystring              ; Message to write
        ; mov rdx, lenDaystring           ; length of the Message
        ; int 80h                         ; call Kernel

; Example: END

readNextTimestamp:
        
        ; Write the initial User Message
        mov eax, sys_write              ; Sys-Call Number (Write)
        mov ebx, stdout                 ; file discriptor (STD OUT)
        mov ecx, userMsg                ; Message to write
        mov edx, lenUserMsg             ; length of the Message
        int 80h                         ; call Kernel

        ;Read and store the user input
        mov eax, sys_read               ; Sys-Call Number (Read)
        mov ebx, stdin                  ; file discriptor (STD IN)
        mov ecx, timestamp_input        ; input is stored into timestamp_input
        mov edx, 128                    ; size of Input
        int 80h                         ; call Kernel

        ;Compare if timestamp is F
        lea     rsi, [timestamp_input]  ; load the address of buffer to rsi
        movzx   rdx, byte [rsi]         ; load first char to
        cmp     rdx, 70                 ; check if first char is "F"
        je      finishedInput           ; if its F input is finished
        ;TODO --> Add to list
        jne     readNextTimestamp       ; not F input not finished

finishedInput:
        ;Test Purpose to test the Jump
        mov eax, sys_write              ; Sys-Call Number (Write)
        mov ebx, stdout                 ; file discriptor (STD OUT)
        mov ecx, userMsg                ; Message to write
        mov edx, lenUserMsg             ; length of the Message
        int 80h                         ; call Kernel

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
.exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
