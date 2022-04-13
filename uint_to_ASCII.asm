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
        stringBase dq 0
        number dq 0
        length dw 0
        fillCharacter db 0
        printZero dq 0

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

;-----------------------------------------------------------------------------
; extern short uint_to_ASCII(char *string, long number, short length, char fillCharacter, bool printZero);
; fillCharacter: 0 = left-aligned without filling, rest: print right-aligned with fillCharacter
; printZero: 0 = false, 1 = true
; return: number of characters written to string
;-----------------------------------------------------------------------------
        global uint_to_ASCII:function
uint_to_ASCII:
        push rbp                                ; save stack base of caller
        mov rbp, rsp                            ; set stack pointer to stack base of callee
        push rbx                                ; save callee-saved register

        mov [stringBase], rdi                   ; save pointer to string
        mov [number], rsi                       ; save number to convert
        mov [length], dx                        ; save length of string
        mov [fillCharacter], cl                 ; save fill character
        mov [printZero], r8                     ; save printZero flag

        movzx rsi, BYTE [fillCharacter]         ; set fill character
        mov rdi, [stringBase]                   ; set pointer to string
        mov rax, [number]                       ; load number to convert
        movzx rcx, WORD [length]                ; set counter to length of string
        mov rbx, 10                             ; set divisor to 10
        xor r9, r9                              ; set counter for written digits to 0

.evaluate_length:                               ; if var length is zero, evaluate length
        cmp rsi, 0                              ; check if fill character is zero
        jne .evaluate_printZero                 ; if not, jump to next step
        xor r8, r8                              ; reset r8 to hold evaluated length
.start_evaluate_length:                         ; start evaluation of length
        test rax, rax                           ; 
        jz .end_evaluate_length                 ; if number is zero, evaluation is done
        xor rdx, rdx
        div rbx                                 ; divide number by divisor
        inc r8                                  ; increment evaluated length
        jmp .start_evaluate_length              ; repeat evaluation
.end_evaluate_length:
        mov rax, [number]                       ; restore number
        cmp r8, rcx                             ; compare evaluated length with length
        ja .evaluate_printZero                  ; if evaluated length is greater, jump to next step (=> use length)
        mov rcx, r8                             ; else set length to evaluated length

.evaluate_printZero:
        mov r8, [printZero]                     ; load printZero flag
        cmp r8, 0                               ; check if printZero flag is false
        je .start_conversion                    ; if flag is not set, jump to start conversion
        cmp rax, 0                              ; check if number is zero
        jne .start_conversion                   ; if number is not zero, jump to start conversion
        test rcx, rcx                           ; check if counter is zero
        jz .printZero                           ; if counter is zero, print zero
        dec rcx                                 ; decrement counter to get the index of the last character
.printZero:
        mov BYTE [rdi + rcx], '0'               ; set last character to '0'
        inc r9w                                 ; increment written digits
        test rcx, rcx                           ; check if counter is zero
        jz .end_function                        ; if counter is zero, jump to end function
        jmp .fill_with_fillCharacter            ; jump to fill with fill character to fill the rest of the string

.start_conversion:
        test rax, rax                           ; check if number is zero
        jz .fill_with_fillCharacter             ; if so, fill string with fill character
        dec rcx                                 ; decrement counter to get index
        xor rdx, rdx                            ; reset rdx for division
        div rbx                                 ; divide number by 10
        add dl, '0'                             ; add '0' to dl to get ASCII value of dl
        mov BYTE [rdi + rcx], dl                ; store ASCII value in string
        inc r9w                                 ; increment written digits
        cmp rcx, 0                              ; check if counter is 0
        jne .start_conversion
        je .end_function

.fill_with_fillCharacter:
        test rcx, rcx                           ; test counter
        jz .end_function                        ; if counter is zero, jump to end function
        dec rcx                                 ; decrement counter to get index
        mov BYTE [rdi + rcx], sil               ; fill string with fill character
        inc r9w                                 ; increment written digits
        jmp .fill_with_fillCharacter            ; repeat filling

.end_function:
        xor rax, rax                            ; clear return value
        mov ax, r9w                             ; set return value to written digits

        pop rbx                                 ; restore callee-saved register
        mov rsp, rbp                            ; restore stack pointer of caller
        pop rbp                                 ; restore stack base of caller
        ret
