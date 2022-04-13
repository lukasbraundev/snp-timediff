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

extern uint_to_ASCII

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        ascii_timeAddress dq 0
        timevalAddress dq 0

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

;-----------------------------------------------------------------------------
; extern short timeval_to_ASCII(char *ascii_time, struct timeval *tv);
; ascii_time is a pointer to a char array with length 27
; return: amount of characters written to ascii_time
;-----------------------------------------------------------------------------
        global timeval_to_ASCII:function
timeval_to_ASCII:
        push rbp                                ; save stack base of caller
        mov rbp, rsp                            ; set stack pointer to stack base of callee
        push r12                                ; save callee-saved register

        mov [ascii_timeAddress], rdi            ; save address of ascii_time
        mov [timevalAddress], rsi               ; save address of timeval struct
        
        xor r12, r12                            ; clear counter for written characters

.write_seconds:
        ; call short uint_to_ASCII(char *string, long number, short length, char fillCharacter, bool printZero)
        mov rdi, [ascii_timeAddress]            ; set string to ascii_time
        mov rsi, [timevalAddress]               ; get address of timeval struct
        mov rsi, [rsi]                          ; set number to tv_sec
        mov dx, 20                              ; set length of seconds to 20
        mov cl, 0                               ; set fill character to 0 -> not displayed
        mov r8, 1                               ; set printZero flag to true
        call uint_to_ASCII
        mov r12w, ax                            ; save written characters to r12

.write_dot:
        mov BYTE [rdi + r12], '.'               ; write dot to ascii_time
        inc r12w                                ; increment counter for written characters

.write_microseconds:
        ; call short uint_to_ASCII(char *string, long number, short length, char fillCharacter, bool printZero)
        mov rdi, [ascii_timeAddress]            ; set string to ascii_time
        add rdi, r12                            ; set offset for microseconds
        mov rsi, [timevalAddress]               ; get address of timeval struct
        mov rsi, [rsi + 8]                      ; set number to tv_usec
        mov dx, 6                               ; set length of microseconds to 6
        mov cl, '0'                             ; set fill character to '0'
        mov r8, 0                               ; set printZero flag to false
        call uint_to_ASCII
        add r12w, ax                            ; increment counter for written characters

.end_function:
        xor rax, rax                            ; clear return value
        mov ax, r12w                            ; return amount of characters written to ascii_time

        pop r12                                 ; restore callee-saved register
        mov rsp, rbp                            ; restore stack pointer of caller
        pop rbp                                 ; restore stack base of caller
        ret