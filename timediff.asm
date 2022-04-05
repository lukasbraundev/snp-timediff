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

sys_read equ 2
sys_write equ 4
stdout equ 1
stdin equ 2

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        userMsg db 'Please enter a timestamp: ' ;Message to ask the User to Enter a new timestamp
        lenUserMsg equ $-userMsg                ;The length of the message

;-----------------------------------------------------------------------------
; SECTION BSS
;-----------------------------------------------------------------------------
SECTION .bss
        timestamp_input resb 100

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
        global _start:function          ; make label available to linker

_start:                                 ; Programm Start
        
        ; <<<<<<<--TODO Test-->>>>>>>
        ; Write the initial User Message
        mov eax, sys_write              ; Sys-Call Number (Write)
        mov ebx, stdout                 ; file discriptor (STD OUT)
        mov ecx, userMsg                ; length of the Message
        mov edx, lenUserMsg             ; Message to write
        int 80h                         ; call Kernel

        ;Read and store the user input
        mov eax, sys_read               ; Sys-Call Number (Read)
        mov ebx, stdin                  ; file discriptor (STD IN)
        mov ecx, timestamp_input        ; input ist stored into num
        mov edx, 8                      ; size of Input
        int 80h                         ; call Kernel
        
        ; <<<<<<<---->>>>>>>

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
.exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
