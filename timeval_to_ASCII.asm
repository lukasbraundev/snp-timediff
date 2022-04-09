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
; Authors:       Johannes Brandenburger, Lukas Braun, Henry Schuler
;
;----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        ; value db 0
        ; ascii_timeBase dq 0
        ; ascii_timeLen db 0
        ; dotIndex db 0
        ; lenBeforeDot db 0
        ; userMsg db 'Please enter a timestamp (to end write "F"): ' ;Message to ask the User to Enter a new timestamp
        ; lenUserMsg equ $-userMsg                ;The length of the message
        ascii_timeAddress dq 0
        timevalAddress dq 0

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text


;-----------------------------------------------------------------------------
; extern void timeval_to_ASCII(char *ascii_time, struct timeval *tv);
;-----------------------------------------------------------------------------
        global timeval_to_ASCII:function
timeval_to_ASCII:
        push rbp                                ; save stack base of caller
        mov rbp, rsp                            ; set stack pointer to stack base of callee
        push rbx                                ; save callee-saved register
        push rsi                                ; save callee-saved register
        push rdi                                ; save callee-saved register

        mov rax, [rbp + 16]                      ; get address of ascii_time
        mov [ascii_timeAddress], rax            ; save address of ascii_time

        mov rax, [rbp + 24]                     ; get address of timeval struct
        mov [timevalAddress], rax               ; save address of timeval struct

        mov rax, [timevalAddress]               ; address of timeval struct
        mov rax, [rax]                          ; get tv_sec

        mov rdi, [ascii_timeAddress]            ; address of ascii_time

        mov rcx, 20                             ; 20 digits (64 bit)

        mov rbx, 10                             ; Set divisor
        
.start_convert_sec:
        test rax, rax
        jz .fill_sec_with_zero
        dec rcx                                 ; decrement counter
        xor rdx, rdx                            ; reset rdx for division result
        div rbx                                 ; divide rax by rbx -> rest is saved in dl
        add dl, '0'                             ; get ASCII value of dl
        mov BYTE [rdi + rcx], dl     ; save dl in ascii_time
        cmp rcx, 0                              ; check if counter is zero
        je .finished_sec
        jmp .start_convert_sec

.fill_sec_with_zero:
        dec rcx
        mov BYTE [rdi + rcx], '0'
        cmp rcx, 0
        je .finished_sec
        jmp .fill_sec_with_zero

.finished_sec:
        ; Write time_char
        mov eax, 4              ; Sys-Call Number (Write)
        mov ebx, 1                 ; file discriptor (STD OUT)
        mov ecx, [ascii_timeAddress]              ; Message to write
        mov edx, 22            ; length of the Message
        int 80h                         ; call Kernel

.end_function:
        pop rdi                                 ; restore callee-saved register
        pop rsi                                 ; restore callee-saved register
        pop rbx                                 ; restore callee-saved register
        mov rsp, rbp                            ; restore stack pointer of caller
        pop rbp                                 ; restore stack base of caller
        ret