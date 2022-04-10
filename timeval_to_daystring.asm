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
; Authors:       Henry Schuler
;
;----------------------------------------------------------------------------

extern uint_to_ASCII

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        daystringBase dq 0
        tvBase dq 0
        seconds db 0
        minutes db 0
        hours db 0
        days dq 0

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text


;-----------------------------------------------------------------------------
; extern void timeval_to_daystring(char *daystring, struct timeval *tv);
; daystring: pointer to the string where the time will be stored (37 BYTE)
;       max: 'DDDDDDDDDDDDDDD days, HH:MM:SS.UUUUUU' -> 37 chars
;-----------------------------------------------------------------------------
        global timeval_to_daystring:function
timeval_to_daystring:
        push rbp				; save stack base of caller
        mov rbp, rsp				; set stack pointer to stack base of callee
        push rbx				; save callee-saved register

        mov [daystringBase], rdi		; save pointer to daystring
        mov [tvBase], rsi                       ; save pointer to timeval struct

        mov rax, [tvBase]                       ; get pointer to timeval struct
        mov rax, [rax]                          ; get tv_sec

.evaluate_all_elements:
        mov rbx, 60                             ; set divisor to 60
        xor rdx, rdx                            ; reset rdx for division
        div rbx                                 ; divide seconds by 60
        mov [seconds], dl                       ; save remainder in seconds
        xor rdx, rdx                            ; reset rdx for division
        div rbx                                 ; divide minutes by 60
        mov [minutes], dl                       ; save remainder in minutes
        mov rbx, 24                             ; set divisor to 24
        xor rdx, rdx                            ; reset rdx for division
        div rbx                                 ; divide hours by 24
        mov [hours], dl                         ; save remainder in hours
        mov [days], rax                         ; save rax in days

        cmp BYTE [days], 0                      ; check if days is 0
        ja .check_one_day                       ; if not jump to write_days
.clear_days:
        mov rdi, [daystringBase]                ; set string to daystring
        mov rsi, 0                              ; write nothing to daystring
        mov dx, 22                              ; clear first 22 chars of daystring (output for days)
        mov cl, 0                               ; replace with 0 -> not displayed
        call uint_to_ASCII
        jmp .write_hours                        ; continue with writing hours

.check_one_day:
        cmp BYTE [days], 1                      ; check if days is 1
        ja .write_days                          ; if not jump to write_days
        mov rdi, [daystringBase]                ; get pointer to daystring
        mov BYTE [rdi + 19], 0                  ; remove plural 's'

.write_days:
        mov rdi, [daystringBase]                ; set string to daystring
        mov rsi, [days]                         ; set number to days
        mov dx, 15                              ; set length of day string
        mov cl, BYTE 0                          ; set fill character to 0 -> not displayed 
        call uint_to_ASCII

.write_hours:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, 22                             ; add offset to hour part of string
        movzx rsi, BYTE [hours]                 ; set number to hours
        mov dx, 2                               ; set length of hour string
        mov cl, BYTE '0'                        ; set fill character to '0' 
        call uint_to_ASCII

.write_minutes:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, 25                             ; add offset to minute part of string
        movzx rsi, BYTE [minutes]               ; set number to minutes
        mov dx, 2                               ; set length of minute string
        mov cl, BYTE '0'                        ; set fill character to '0' 
        call uint_to_ASCII

.write_seconds:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, 28                             ; add offset to second part of string
        movzx rsi, BYTE [seconds]               ; set number to seconds
        mov dx, 2                               ; set length of second string
        mov cl, BYTE '0'                        ; set fill character to '0' 
        call uint_to_ASCII

.write_microseconds:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, 31                             ; add offset to microsecond part of string
        mov rsi, [tvBase]                       ; get pointer to timeval struct
        mov rsi, [rsi + 8]                      ; set number to tv_usec of timeval struct
        mov dx, 6                               ; set length of microsecond string
        mov cl, BYTE '0'                        ; set fill character to '0' 
        call uint_to_ASCII

.end_function:
        pop rbx					; restore callee-saved register
        mov rsp, rbp				; restore stack pointer of caller
        pop rbp					; restore stack base of caller
        ret
