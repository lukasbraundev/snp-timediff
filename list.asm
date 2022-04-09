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

sys_read equ 3
sys_write equ 4
stdout equ 1
stdin equ 2
extern printf

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        startAdress dq 0                 ; start adress of the program currently 0, filled in later by the list_init function
        secondBreak dq 0                 ; second ram-breakpoint (maybe not needed)
        listSize    dq 0                 ; size of the list
        errorMsg db 'Error in list.asm!' ; error message
        lenErrorMsg equ $-errorMsg       ; length of the error message
        intInAscii db '                ' ; buffer for the debug output
        formatStrInt:
	        db `---> rax: %ld\n`, 0
        formatStrString:
	        db `- %c: `, 0
;-----------------------------------------------------------------------------
; extern void list_init(void)
;-----------------------------------------------------------------------------
        global list_init:function
list_init:
        push    rbp
        mov     rbp,rsp

        mov	rax, 45		        ; load sys_brk (allocate mem) into eax
        xor	rbx, rbx                ; clear rbx
        int	80h                     ; call sys_brk
        ; call    print_int_rax           ; DEBUG: print the return value of sys_brk

        mov     [startAdress], rax      ; save start adress of the program in startAdress
        add	rax, 160000	        ; number of bytes to be reserved ()
        mov	rbx, rax                ; save the number of bytes to be reserved in rbx
        mov	rax, 45		        ; load sys_brk (allocate mem) into eax
        int	80h                     ; call sys_brk
                
        cmp	rax, 0                  ; check if the allocation was successful (-1 if not)
        jl	exit	                ; if not, exit the program 
        ; call    print_int_rax         ; DEBUG: print the return value of sys_brk
        mov	rdi, rax	        ; EDI = highest available address

        mov     rsp,rbp
        pop     rbp
        ret

;-----------------------------------------------------------------------------
; extern short list_size(void);
;-----------------------------------------------------------------------------
        global list_size:function
list_size:
        push    rbp
        mov     rbp,rsp

        mov     rax, [listSize]       ; load the size of the list into rax
        push    rax                   ; push the size of the list into the stack (return value)

        mov     rsp,rbp
        pop     rbp
        ret


;-----------------------------------------------------------------------------
; extern bool list_is_sorted(void);
;-----------------------------------------------------------------------------
        global list_is_sorted:function
list_is_sorted:
        push    rbp
        mov     rbp,rsp

        ; push all used registers onto the stack
        ; push    rbx
        ; push    rcx
        ; push    rax
        ; push    r8
        ; push    r9

        ; immediately return false if the list is empty
        mov     rax, [listSize]       ; load the size of the list into rax
        cmp     rax, 0                ; check if the list is empty
        je      exit_not_sorted       ; if so, return false

        ; check if the list is sorted
        mov     rbx, [startAdress]    ; load the start adress of the list into rax
        mov     rcx, 1                ; set counter to 1
        mov     rdx, 1                ; set return value to true

loop_check_if_sorted: 

        mov     r8, [rbx]             ; load the first element of the list into rbx 
        mov     r9, [rbx+16]          ; load the second element of the list into rdi

        cmp     r9, r8                ; check if the first element is smaller than the second element
        jl      exit_not_sorted       ; if not, return false
        jg      already_bigger_tv_sec

        mov     r8, [rbx+8]           ; load the first element of the list into rbx 
        mov     r9, [rbx+24]          ; load the second element of the list into rdi

        cmp     r9, r8                ; check if the first element is smaller than the second element
        jle     exit_not_sorted       ; if not, return false

already_bigger_tv_sec:

        add     rbx, 16                ; add the size of the list elements to the start adress of the list
        inc     rcx                    ; increment the counter
        cmp     rcx, [listSize]        ; check if the counter is equal to the size of the list
        je      exit_loop_check_if_sorted  ; if so, the list is gone through -> return true
        jne     loop_check_if_sorted   ; if not, go to the beginning of the loop


exit_not_sorted:

        mov     rdx, 0                 ; return false

exit_loop_check_if_sorted:
        mov     rax, rdx               ; return the return value
        push    rax                    ; push the return value into the stack

        ; pop     r8                     ; pop the used registers from the stack TODO: why isn't this working?
        ; pop     r9
        ; pop     rax
        ; pop     rcx
        ; pop     rbx

        mov     rsp,rbp
        pop     rbp
        ret




;-----------------------------------------------------------------------------
; extern short list_add(struct timeval *tv);
;-----------------------------------------------------------------------------
        global list_add:function
list_add:

        push    rbp
        mov     rbp, rsp
        push    rbx
        push    rcx
        push    rdx


        ; mov     rax, [listSize]         ; DEBUG: load the size of the list into rax
        ; call    print_int_rax           ; DEBUG: print the size of the list        
        mov     rbx, [startAdress]      ; load the start adress of the list in rax
        xor     rcx, rcx                ; clear rcx (counter = 0)

loop_to_get_right_adress:

        cmp     rcx, [listSize]         ; check if the counter is bigger than the size of the list
        je      exit_loop_to_get_right_adress

        add     rbx, 16                 ; add 16 to the current adress
        inc     rcx                     ; increment the counter
        cmp     rcx, [listSize]         ; check if the counter is equal to the size of the list
        jne     loop_to_get_right_adress

exit_loop_to_get_right_adress:
        
        mov     rax, rbx                ; load the current adress in rax
        ; call    print_int_rax           ; DEBUG: print the current adress

        mov     rax, [rdi]              ; load the timeval.tv_sec into rax
        ; call    print_int_rax           ; DEBUG: print timeval.tv_sec
        mov     [rbx], rax              ; load the timeval.tv_sec into memory at the right adress (startAdress + 16*listSize)
        
        mov     rax, [rdi+8]            ; load the timeval.tv_usec into rax
        ; call    print_int_rax           ; DEBUG: print timeval.tv_usec
        mov     [rbx + 8], rax          ; load the timeval.tv_usec into memory at the right adress (startAdress + 16*listSize + 8)
        
        ; mov     rax, [startAdress]      ; DEBUG: load the first adress of the list into rax
        ; mov     rax, [rax]              ; DEBUG: load the first value of the list into rax
        ; call    print_int_rax           ; DEBUG: print the first value of the list

        mov     rax, [listSize]         ; load the size of the list into rax
        ; call    print_int_rax           ; DEBUG: print the new size of the list
        inc     rax                     ; increase the size of the list by 1
        mov     [listSize], rax         ; save the new size of the list in listSize
        dec     rax                     ; decrease the size of the list by 1 to get current position
        push    rax                     ; return the current position of the list

        pop     rdx
        pop     rcx
        pop     rbx

        mov     rsp, rbp
        pop     rbp


;-----------------------------------------------------------------------------
; extern short list_find(struct timeval *tv);
;-----------------------------------------------------------------------------
        global list_find:function
list_find:
        push    rbp
        mov     rbp,rsp

        mov     r8, [rdi]                   ; load the struct timeval.tv_sec into r8
        mov     r9, [rdi+8]                 ; load the struct timeval.tv_usec into r9

        ; mov     rax, r8                     ; DEBUG: load the timeval.tv_sec into rax
        ; call    print_int_rax               ; DEBUG: print the timeval.tv_sec
        ; mov     rax, r9                     ; DEBUG: load the timeval.tv_usec into rax
        ; call    print_int_rax               ; DEBUG: print the struct timeval.tv_usec

        mov     rbx, [startAdress]          ; load the start adress of the list into rbx
        xor     rcx, rcx                    ; clear rcx (counter = 0)

list_find_loop:

        cmp     rcx, [listSize]             ; check if the counter is bigger than the size of the list
        je      list_find_not_found         ; if so, return -1

        mov     rax, [rbx]                  ; load the current tv_sec of the list into rax
        cmp     rax, r8                     ; check if the current tv_sec is equal to the tv_sec of the searched timeval
        jne     list_find_skip_check_usec   ; if not equal, go to the next element of the list

        mov     rax, [rbx+8]                ; load the current tv_usec of the list into rax
        cmp     rax, r9                     ; check if the current tv_usec is equal to the tv_usec of the searched timeval
        je      list_find_match             ; if so -> match -> return the current position of the list

list_find_skip_check_usec

        add     rbx, 16                     ; add 16 to the current adress
        inc     rcx                         ; increment the counter
        jmp     list_find_loop

list_find_not_found:

        mov     rax, -1                     ; return -1 to indicate that the searched timeval was not found
        push    rax                         ; return the return value

        mov     rsp,rbp
        pop     rbp
        ret

list_find_match:

        mov     rax, rcx                    ; return the current position of the list
        push    rax                         ; return the return value

        mov     rsp,rbp
        pop     rbp
        ret


;-----------------------------------------------------------------------------
; extern bool list_get(struct timeval *tv, short idx);
;-----------------------------------------------------------------------------
        global list_get:function
list_get:
        push    rbp
        mov     rbp,rsp

        ; your code goes here

        mov     rsp,rbp
        pop     rbp
        ret



exit:
        push    rbp
        mov     rbp,rsp

        mov     rax, sys_write              ; Sys-Call Number (Write)
        mov     rbx, stdout                 ; file discriptor (STD OUT)
        mov     rcx, errorMsg               ; Message to write
        mov     rdx, lenErrorMsg            ; length of the Message
        int     80h                         ; call Kernel

        mov     rsp,rbp
        pop     rbp
        ret


print_int_rax:
        push    rbp
        mov     rbp, rsp
        push    rsi 
        push    rax
        push    rdi
        push    r8
        push    r9
        push    rbx
        push    rcx
        push    rdx

        mov     rdi, formatStrInt       ; first argument: format string
        mov     rsi, rax                ; second argument (for format string below): integer to print
        mov     al, 0                   ; magic for varargs (0==no magic, to prevent a crash!)

        call    printf
        
        pop     rdx
        pop     rcx
        pop     rbx
        pop     r9
        pop     r8
        pop     rdi
        pop     rax
        pop     rsi

        mov     rsp, rbp
        pop     rbp
        ret


