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
        ascii_timeAddress dq 0
        timevalAddress dq 0
        ascii_timeSecondsLen db 0

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

;-----------------------------------------------------------------------------
; extern void timeval_to_ASCII(char *ascii_time, struct timeval *tv);
; ascii_time is a pointer to a char array with length 27
;-----------------------------------------------------------------------------
        global timeval_to_ASCII:function
timeval_to_ASCII:
        push rbp                                ; save stack base of caller
        mov rbp, rsp                            ; set stack pointer to stack base of callee
        push rbx                                ; save callee-saved register

        mov [ascii_timeAddress], rdi            ; save address of ascii_time

        mov [timevalAddress], rsi               ; save address of timeval struct

        mov rax, [timevalAddress]               ; address of timeval struct
        mov rax, [rax]                          ; get tv_sec

        xor rcx, rcx                            ; reset counter

        mov rbx, 10                             ; Set divisor

.start_evaluate_ascii_sec_length:               ; evaluate amount of ascii digits for seconds
        test rax, rax                           ; check if a digit is left
        jz .end_evaluate_ascii_sec_length       ; if not, jump to end
        xor rdx, rdx                            ; reset rdx for division
        div rbx                                 ; divide seconds by 10 -> get next digit
        inc cl                                  ; increase counter
        jmp .start_evaluate_ascii_sec_length    ; check for left digits

.end_evaluate_ascii_sec_length:                 ; no more digits left

        cmp cl, 0                               ; check if seconds was 0
        jne .more_than_zero_sec                 ; if not, jump to next step
        inc cl                                  ; increase counter so that '0' can be printed

.more_than_zero_sec:                            ; counter holds amount of number characters before decimal point (0-20)

        mov [ascii_timeSecondsLen], cl              ; save amount of number characters before decimal point
        ; restore tv_sec in rax
        mov rax, [timevalAddress]               ; address of timeval struct
        mov rax, [rax]                          ; get tv_sec

        ; divisor rbx is still set, counter rcx is set to amount of number characters before decimal point

        mov rdi, [ascii_timeAddress]            ; address of ascii_time
        
.start_convert_sec:
        dec rcx                                 ; decrement counter
        xor rdx, rdx                            ; reset rdx for division result
        div rbx                                 ; divide rax by rbx -> rest is saved in dl
        add dl, '0'                             ; get ASCII value of dl
        mov BYTE [rdi + rcx], dl                ; save dl in ascii_time
        cmp rcx, 0                              ; check if counter is zero
        ja .start_convert_sec

.finished_sec:

        add rdi, [ascii_timeSecondsLen]             ; jump to the dot in the string

        mov BYTE [rdi], '.'                     ; save dot in ascii_time

        mov rax, [timevalAddress]               ; address of timeval struct
        add rax, 8                              ; get address tv_usec
        mov rax, [rax]                          ; get tv_usec
        
        mov rcx, 6                              ; Counter for 6 digits

        ; divisor rbx is still set to 10

.start_convert_usec:
        test rax, rax                           ; check if rax is 0
        jz .fill_usec_with_zero                 ; if yes, fill missing characters for usec with '0'
        xor rdx, rdx                            ; reset rdx for division result
        div rbx                                 ; divide rax by rbx -> rest is saved in dl
        add dl, '0'                             ; get ASCII value of dl
        mov BYTE [rdi + rcx], dl                ; save dl in ascii_time
        dec rcx                                 ; decrement counter
        jnz .start_convert_usec                 ; restart conversion if counter is not zero
        jz .finished_usec                       ; jump to end if counter is zero (skip filling with '0')

.fill_usec_with_zero:
        mov BYTE [rdi + rcx], '0'               ; fill missing characters with '0'
        dec rcx                                 ; decrement counter
        jnz .fill_usec_with_zero                ; restart filling with '0' if counter is not zero

.finished_usec:

        mov rdi, [ascii_timeAddress]            ; address of ascii_time

        mov rcx, [ascii_timeSecondsLen]         ; get amount of second-characters before decimal point
        add rcx, 7                              ; add 7 for the dot (1) and the microseconds (6)

        ; fill the rest of the string with NULL-bytes
.start_adding_NULL:
        cmp rcx, 27                             ; compare with max length of ascii_time 20 (seconds) + 1 (dot) + 6 (microseconds) = 27
        jae .end_function                       ; if end is reached, jump to end of function
        mov BYTE [rdi + rcx], BYTE 0            ; else, fill with NULL-byte
        inc rcx                                 ; increment counter
        jmp .start_adding_NULL                  ; restart loop

.end_function:
        pop rbx                                 ; restore callee-saved register
        mov rsp, rbp                            ; restore stack pointer of caller
        pop rbp                                 ; restore stack base of caller
        ret