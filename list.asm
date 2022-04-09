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
        formatStr:
	        db `---> rax: %ld\n`, 0
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


loop_check_if_sorted:        


exit_loop_check_if_sorted:



        mov     rsp,rbp
        pop     rbp
        ret


;-----------------------------------------------------------------------------
; extern short list_add(struct timeval *tv);
;-----------------------------------------------------------------------------
        global list_add:function
list_add:
        push    rbp
        mov     rbp,rsp
        
        push    rcx                     ; save rcx

        ; mov     rax, [listSize]         ; DEBUG: load the size of the list into rax
        ; call    print_int_rax           ; DEBUG: print the size of the list        

        mov     rbx, [startAdress]      ; load the start adress of the program in rax
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
        call    print_int_rax           ; DEBUG: print the current adress

        mov     rax, [rdi]              ; load the timeval.tv_sec into rax
        call    print_int_rax           ; DEBUG: print timeval.tv_sec
        mov     [rbx], rax              ; load the timeval.tv_sec into memory at the right adress (startAdress + 16*listSize)
        
        mov     rax, [rdi+8]            ; load the timeval.tv_usec into rax
        call    print_int_rax           ; DEBUG: print timeval.tv_usec
        mov     [rbx + 8], rax          ; load the timeval.tv_usec into memory at the right adress (startAdress + 16*listSize + 8)
        
        mov     rax, [startAdress]      ; DEBUG: load the first adress of the list into rax
        mov     rax, [rax]              ; DEBUG: load the first value of the list into rax
        call    print_int_rax           ; DEBUG: print the first value of the list

        mov     rax, [listSize]         ; load the size of the list into rax
        call    print_int_rax           ; DEBUG: print the new size of the list
        inc     rax                     ; increase the size of the list by 1
        mov     [listSize], rax         ; save the new size of the list in listSize
        dec     rax                     ; decrease the size of the list by 1 to get current position
        push    rax                     ; return the current position of the list

        pop     rcx                     ; restore rcx (NOTE: doens't this just get the value of rax?)

        mov     rsp,rbp
        pop     rbp
        ret


;-----------------------------------------------------------------------------
; extern short list_find(struct timeval *tv);
;-----------------------------------------------------------------------------
        global list_find:function
list_find:
        push    rbp
        mov     rbp,rsp

        ; your code goes here

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

        mov     rdi, formatStr          ; first argument: format string
        mov     rsi, rax                  ; second argument (for format string below): integer to print
        mov     al, 0                   ; magic for varargs (0==no magic, to prevent a crash!)

        call printf
        
        pop     rdi
        pop     rax
        pop     rsi

        mov     rsp, rbp
        pop     rbp
        ret
