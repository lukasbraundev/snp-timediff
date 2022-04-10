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
stdin equ 0

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
        time_char db '1000000000000000000.000000'
        lenTimeChar equ $-time_char
        possible_timechar db '                            '
        possible_timechar_len equ $-possible_timechar
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

init:
        mov r12, 0                      ; ctr for the possible timechar index

read_next_string:
        ; Read from STD in
        mov rax, sys_read               ; Sys-Call Number (Read)
        mov rbx, stdin                  ; file discriptor (STD IN)
        mov rcx, buffer                 ; input is stored into timestamp_input
        mov rdx, BUFFER_SIZE            ; size of Input
        int 80h                         ; call Kernel

        test    rax,rax                 ; check system call return value
        jz      finishedInput             ; jump to exit if nothing is read (end)
        lea rsi, [buffer]               ; loads adress of first char into rsi
        mov byte [buffer+rax], 128      ; determines the End of the Buffer




next_char:      
        mov     dl, byte [rsi]          ; load next char from buffer
        cmp     dl,127                  ; check if its a char
        ja      read_next_string        ; jump if no char
        cmp     r12, 27                 ; check if input length is max
        je      max_input_error
        cmp     dl, 10                  ; check for linefeed TODO, check for end of file
        je      timestamp_finished      ; jump if timestamp detected
        mov     [possible_timechar + r12], dl
        inc r12                         ; inc possible timechar index
        inc rsi                         ; inc adress in Buffer
        jmp next_char


max_input_error:

        jmp exit

timestamp_finished:
        ; Check for correct syntax
        push rsi
        push rdx
        mov rdi, timeval
        mov rsi, possible_timechar
        xor rdx, rdx
        mov dx, possible_timechar_len
        call ASCII_to_timeval
        pop rdx
        pop rsi
        cmp rax, 0                      ; check if conversation was sucessful
        je exit                         ; if not exit programnm
        ; ----- TODO Error Message -------- ;
        mov rdi, timeval
        call list_add
        ; addList() Funktion aufrufen TODO Rückgabewert überprüfen
        ; placeholder reinitialize
        ; foreach char in possible_char
        ; char => " "
        mov r12, 0
        jmp next_char


finishedInput:
        nop

;         ;-----------------------------------------------------------
;         ; call system exit and return to operating system / shell
;         ;-----------------------------------------------------------
exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------
