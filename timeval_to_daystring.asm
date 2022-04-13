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
; extern short timeval_to_daystring(char *daystring, struct timeval *tv);
; daystring: pointer to the string where the time will be stored (37 BYTE)
;       max: 'DDDDDDDDDDDDDDD days, HH:MM:SS.UUUUUU' -> 37 chars
; return: amount of chars written to daystring
;-----------------------------------------------------------------------------
        global timeval_to_daystring:function
timeval_to_daystring:
        push rbp                                ; save stack base of caller
        mov rbp, rsp                            ; set stack pointer to stack base of callee
        push rbx                                ; save callee-saved register
        push r12                                ; save callee-saved register

        mov [daystringBase], rdi                ; save pointer to daystring
        mov [tvBase], rsi                       ; save pointer to timeval struct

        xor r12, r12                            ; clear counter for written characters

.evaluate_all_elements:
        mov rax, [tvBase]                       ; get pointer to timeval struct
        mov rax, [rax]                          ; get tv_sec
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

.check_no_days:
        cmp BYTE [days], 0                      ; check if days is 0
        je .write_hours                         ; if so, jump to write hours

.write_days:
        mov rdi, [daystringBase]                ; set string to daystring
        mov rsi, [days]                         ; set number to days
        mov dx, 15                              ; set length of day string
        mov cl, 0                               ; set fill character to 0 -> not displayed 
        mov r8, 0                               ; set printZero flag to false
        call uint_to_ASCII
        add r12w, ax                            ; add number of written characters to counter

.write_string_day:
        mov BYTE [rdi + r12], ' '               ; write space
        inc r12w                                ; increment written characters
        mov BYTE [rdi + r12], 'd'               ; write 'd'
        inc r12w                                ; increment written characters
        mov BYTE [rdi + r12], 'a'               ; write 'a'
        inc r12w                                ; increment written characters
        mov BYTE [rdi + r12], 'y'               ; write 'y'
        inc r12w                                ; increment written characters

        cmp BYTE [days], 1                      ; check if days is 1 -> skip plural 's'
        je .write_string_day_complete           ; if so, jump to write_string_day_complete

        mov BYTE [rdi + r12], 's'               ; write 's'
        inc r12w                                ; increment written characters

.write_string_day_complete:
        mov BYTE [rdi + r12], ','               ; write ','
        inc r12w                                ; increment written characters
        mov BYTE [rdi + r12], ' '               ; write space
        inc r12w                                ; increment written characters

.write_hours:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, r12                            ; add offset to hour part of string
        movzx rsi, BYTE [hours]                 ; set number to hours
        mov dx, 2                               ; set length of hour string
        mov cl, '0'                             ; set fill character to '0' 
        mov r8, 0                               ; set printZero flag to false
        call uint_to_ASCII
        add r12w, ax                            ; add number of written characters to counter

        mov BYTE [rdi + rax], ':'               ; write ':'
        inc r12w                                ; increment written characters

.write_minutes:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, r12                            ; add offset to minute part of string
        movzx rsi, BYTE [minutes]               ; set number to minutes
        mov dx, 2                               ; set length of minute string
        mov cl, '0'                             ; set fill character to '0' 
        mov r8, 0                               ; set printZero flag to false
        call uint_to_ASCII
        add r12w, ax                            ; add number of written characters to counter

        mov BYTE [rdi + rax], ':'               ; write ':'
        inc r12w                                ; increment written characters

.write_seconds:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, r12                            ; add offset to second part of string
        movzx rsi, BYTE [seconds]               ; set number to seconds
        mov dx, 2                               ; set length of second string
        mov cl, '0'                             ; set fill character to '0' 
        mov r8, 0                               ; set printZero flag to false
        call uint_to_ASCII
        add r12w, ax                            ; add number of written characters to counter

        mov BYTE [rdi + rax], '.'               ; write '.'
        inc r12w                                ; increment written characters

.write_microseconds:
        mov rdi, [daystringBase]                ; set string to daystring
        add rdi, r12                            ; add offset to microsecond part of string
        mov rsi, [tvBase]                       ; get pointer to timeval struct
        mov rsi, [rsi + 8]                      ; set number to tv_usec of timeval struct
        mov dx, 6                               ; set length of microsecond string
        mov cl, '0'                             ; set fill character to '0' 
        mov r8, 0                               ; set printZero flag to false
        call uint_to_ASCII
        add r12w, ax                            ; add number of written characters to counter

.end_function:
        xor rax, rax                            ; reset return value
        mov ax, r12w                            ; set return value to written characters

        pop r12                                 ; restore callee-saved register
        pop rbx                                 ; restore callee-saved register
        mov rsp, rbp                            ; restore stack pointer of caller
        pop rbp                                 ; restore stack base of caller
        ret
