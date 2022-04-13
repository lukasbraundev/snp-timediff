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
        tvBase dq 0
        ascii_timeBase dq 0
        ascii_timeLen dw 0
        dotIndex db 0

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text


;-----------------------------------------------------------------------------
; extern bool ASCII_to_timeval(struct timeval *tv, char *ascii_time, short len);
; returns: 1 if success, 0 if error
;-----------------------------------------------------------------------------
        global ASCII_to_timeval:function
ASCII_to_timeval:
        push rbp                                ; save stack base of caller
        mov rbp, rsp                            ; set stack pointer to stack base of callee
        push rbx                                ; save callee-saved register

        mov [tvBase], rdi                       ; store pointer to struct timeval in tvBase
        mov [ascii_timeBase], rsi               ; store pointer to ascii_time in ascii_timeBase
        mov [ascii_timeLen], dx                 ; store len in ascii_timeLen

        ; search ASCII '.' = 46 in ascii_time
        mov rax, [ascii_timeBase]               ; load ascii_timeBase into rax
        xor rcx, rcx                            ; set counter to 0

.start_search:
        cmp cl, BYTE [ascii_timeLen]            ; compare counter with length of ascii_time (= len)
        je .not_found                           ; if character 21 has been read without finding '.', exit loop -> error
        cmp BYTE [rax + rcx], 46                ; compare ascii_time[rcx] with ASCII '.'
        je .found_dot                           ; if found, jump to .found_dot
        inc cl                                  ; increment counter
        jmp .start_search                       ; jump to .start_search

.found_dot:
        mov [dotIndex], BYTE cl                 ; save index of '.' in dotIndex

        ; evaluate tv_sec from ascii_time
        mov rsi, [ascii_timeBase]               ; load address of first seconds char in rsi (source register)

        xor rcx, rcx                            ; set counter to 0

        xor rax, rax                            ; reset rax to hold seconds as decimal

        mov rbx, 10                             ; set multiply value to 10

.start_eval_sec:
        cmp cl, [dotIndex]                      ; check with length of characters before '.'
        je .eval_sec_done                       ; if counter == number of charackters before '.', jump to .eval_sec_done
        mul rbx                                 ; multiply seconds by 10
        xor r9, r9                              ; clear r9
        mov r9b, BYTE [rsi + rcx]               ; load next ascci digit into r9b
        add rax, r9                             ; add r9 to rax (64bit addition)
        sub rax, 48                             ; subtract ASCII '0' from rax
        inc rcx                                 ; increment counter
        jmp .start_eval_sec                     ; jump to .start_eval_sec

.eval_sec_done:
        ; move rax to tv_sec
        mov rdi, [tvBase]                       ; load pointer to timeval into rdi
        mov [rdi], rax                          ; store seconds in tv_sec

        ; evaluate tv_usec from ascii_time

        mov rsi, [ascii_timeBase]
        add sil, [dotIndex]
        inc rsi                                 ; set rsi to address of first microseconds char

        xor rcx, rcx                            ; set counter to 0

        xor rax, rax                            ; reset rax to hold microseconds as decimal

        mov rbx, 10                             ; set multiply value to 10

        mov r8b, BYTE [ascii_timeLen]
        sub r8b, [dotIndex]                     ; save length of millisecond characters in r8
        dec r8b                                 ; subtract 1 because of the dot

.start_eval_usec:
        cmp cl, 6                               ; 6 positions for microseconds
        je .eval_usec_done                      ; if counter == 6, jump to .eval_usec_done
        mul rbx                                 ; multiply microseconds by 10
        cmp cl, r8b                             ; check if counter is smaller than length of microseconds
        jnb .string_usec_end                    ; if not, jump to .string_usec_end
        xor r9, r9                              ; clear r9
        mov r9b, BYTE [rsi + rcx]               ; load next ascci digit into r9b
        add rax, r9                             ; add r9 to rax (64bit addition)
        sub rax, 48                             ; subtract ASCII '0' from rax
.string_usec_end:
        inc rcx                                 ; increment counter
        jmp .start_eval_usec                    ; jump to .start_eval_usec

.eval_usec_done:
        ; move rax to tv_usec
        mov rdi, [tvBase]                       ; load pointer to timeval into rdi
        mov [rdi + 8], rax                      ; store microseconds in tv_usec

        mov eax, 1                              ; set return value to true

        jmp .end_function

.not_found:
        mov eax, 0                              ; set return value to false

.end_function:
        pop rbx                                 ; restore callee-saved register
        mov rsp, rbp                            ; restore stack pointer of caller
        pop rbp                                 ; restore stack base of caller
        ret
