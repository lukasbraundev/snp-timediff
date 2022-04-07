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
        mov ecx, userMsg                ; length of the Message
        mov edx, lenUserMsg             ; Message to write
        int 80h                         ; call Kernel

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
.exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
