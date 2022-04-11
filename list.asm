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
	        db `---> rax: %ld\n`, 0  ; format string for the debug output


;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

;-----------------------------------------------------------------------------
; extern void list_init(void)
;-----------------------------------------------------------------------------
        global list_init:function
list_init:
        push    rbp
        mov     rbp,rsp

        push    rbx

        ; set the first breakpoint (start of the list)
        mov	rax, 45		        ; load sys_brk (allocate mem) into eax
        xor     rbx, rbx		; clear rbx (needed for sys_brk)
        int	80h                     ; call sys_brk (first breakpoint)

        ; check if the first breakpoint was set correctly
        cmp	rax, 0                  ; check if the allocation was successful (-1 if not)
        jl	exit	                ; if not, exit the program 

        ; set the second breakpoint (end of the list)
        mov     [startAdress], rax      ; save start adress of the program in startAdress
        add	rax, 160000	        ; add number of bytes to be reserved (10 000 * 2 * 8)
        mov	rbx, rax                ; save the adress of second breakpoint in rbx
        mov	rax, 45		        ; load sys_brk (allocate mem) into eax
        int	80h                     ; call sys_brk (second breakpoint)
                
        ; check if the second breakpoint was set correctly
        cmp	rax, 0                  ; check if the allocation was successful (-1 if not)
        jl	exit	                ; if not, exit the program 

        pop     rbx

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

        ; return the list size
        mov     rax, [listSize]       ; load the size of the list into rax

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

        push    rbx

        ; immediately return false if the list is empty
        mov     rax, [listSize]       ; load the size of the list into rax
        cmp     rax, 0                ; check if the list is empty
        je      list_is_sorted_exit_not_sorted       ; if so, return false

        ; begin to check if the list is sorted
        mov     rbx, [startAdress]    ; load the start adress of the list into rax
        mov     rcx, 1                ; set counter to 1
        mov     rdx, 1                ; set return value to true

list_is_sorted_loop: 

        ; load the two tv_sec to compare
        mov     r8, [rbx]             ; load the current tv_sec of the list into r8 
        mov     r9, [rbx+16]          ; load the next tv_sec of the list into r9

        ; compare the two tv_sec values
        cmp     r9, r8                ; check if the next tv_sec is bigger than the current tv_sec
        jl      list_is_sorted_exit_not_sorted       ; if not, return false
        jg      list_is_sorted_already_bigger_tv_sec

        ; load the two tv_usec to compare
        mov     r8, [rbx+8]           ; load the current tv_usec of the list into r8
        mov     r9, [rbx+24]          ; load the next tv_usec of the list into r9

        ; compare the two tv_usec values
        cmp     r9, r8                ; check if the next tv_usec is bigger than the current tv_usec
        jle     list_is_sorted_exit_not_sorted       ; if not, return false

list_is_sorted_already_bigger_tv_sec:

        ; the tv_usec values are not relevant if the tv_sec values are already not equal
        add     rbx, 16                ; increase the current adress by 16 bytes (size of one tv_sec)
        inc     rcx                    ; increment the counter by 1
        cmp     rcx, [listSize]        ; check if the counter is equal to the size of the list
        je      list_is_sorted_loop_exit ; if so, the list is gone through -> return true
        jne     list_is_sorted_loop    ; if not, go to the beginning of the loop

list_is_sorted_exit_not_sorted:
        
        ; return false
        mov     rdx, 0                 ; return false

list_is_sorted_loop_exit:

        ; all elements are gone through -> return true
        mov     rax, rdx               ; return the return value

        pop     rbx

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

        ; start the loop
        mov     rbx, [startAdress]      ; load the start adress of the list in rax
        xor     rcx, rcx                ; clear rcx (counter = 0)

list_add_loop:

        ; check if the right adress is reached
        cmp     rcx, [listSize]         ; check if the counter is equal the size of the list
        je      list_add_loop_exit      ; if so, the right adress is reached

        ; increment the counter
        add     rbx, 16                 ; add 16 to the current adress
        inc     rcx                     ; increment the counter
        jmp     list_add_loop

list_add_loop_exit:
        
        ; write tv_sec into memory
        mov     rax, [rdi]              ; load the timeval.tv_sec into rax
        mov     [rbx], rax              ; load the timeval.tv_sec into memory at the right adress (startAdress + 16*listSize)
        
        ; write tv_usec into memory
        mov     rax, [rdi+8]            ; load the timeval.tv_usec into rax
        mov     [rbx + 8], rax          ; load the timeval.tv_usec into memory at the right adress (startAdress + 16*listSize + 8)

        ; increase the size of the list
        mov     rax, [listSize]         ; load the size of the list into rax
        inc     rax                     ; increase the size of the list by 1
        mov     [listSize], rax         ; save the new size of the list in listSize
        
        ; return the new position of the element
        dec     rax                     ; decrease the size of the list by 1 to get current position

        pop     rbx 

        mov     rsp, rbp
        pop     rbp
        ret



;-----------------------------------------------------------------------------
; extern short list_find(struct timeval *tv);
;-----------------------------------------------------------------------------
        global list_find:function
list_find:

        push    rbp
        mov     rbp,rsp

        push    rbx

        ; load the values of the timeval into r8 and r9
        mov     r8, [rdi]                   ; load the struct timeval.tv_sec into r8
        mov     r9, [rdi+8]                 ; load the struct timeval.tv_usec into r9

        ; start the loop
        mov     rbx, [startAdress]          ; load the start adress of the list into rbx
        xor     rcx, rcx                    ; clear rcx (counter = 0)

list_find_loop:

        ; check if the counter is equal than the size of the list
        cmp     rcx, [listSize]             ; check if the counter is equal the size of the list
        je      list_find_not_found         ; if so, the element was not found -> return -1

        ; check if the tv_sec of the current element is equal to the given timeval.tv_sec
        mov     rax, [rbx]                  ; load the current tv_sec of the list into rax
        cmp     rax, r8                     ; check if the current tv_sec is equal to the tv_sec of the searched timeval
        jne     list_find_skip_check_usec   ; if not equal, go to the next element of the list (skip the check of the tv_usec)

        ; check if the tv_usec of the current element is equal to the given timeval.tv_usec
        mov     rax, [rbx+8]                ; load the current tv_usec of the list into rax
        cmp     rax, r9                     ; check if the current tv_usec is equal to the tv_usec of the searched timeval
        je      list_find_match             ; if so -> match -> return the current position of the list

list_find_skip_check_usec:

        ; increment the adress by 16 and increment the counter by 1
        add     rbx, 16                     ; add 16 to the current adress
        inc     rcx                         ; increment the counter
        jmp     list_find_loop

list_find_not_found:

        ; if the loop goes through the whole list and the element was not found, return -1
        mov     rax, -1                     ; return -1 to indicate that the searched timeval was not found

        pop     rbx

        mov     rsp,rbp
        pop     rbp
        ret

list_find_match:

        ; if the element was found inside the loop, return the current counter (position of the element)
        mov     rax, rcx                    ; return the current counter (position of the found element)

        pop     rbx

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

        push    rbx

        ; check if the list size is 0
        mov     rax, [listSize]            ; load the size of the list into rax
        cmp     rax, 0                     ; check if the size is 0
        je      list_get_not_found         ; if so, return false

        ; check if the index is bigger than the list size
        mov     rax, [listSize]            ; load the size of the list into rax
        cmp     rsi, rax                   ; check if the param index is bigger than the size of the list
        jge     list_get_not_found         ; if so, return false

        ; check if the index is smaller than 0
        cmp     rsi, 0                     ; check if the param index is smaller than 0
        jl      list_get_not_found         ; if so, return false


        ; get the adress of the list element with the given index
        mov     rbx, [startAdress]         ; load the start adress of the list into rbx
        xor     rcx, rcx                   ; clear rcx (counter = 0)

list_get_loop:

        ; check if the counter is equal the index
        cmp     rcx, rsi                   ; check if the counter is equal the index
        je      list_get_loop_exit         ; if so, exit the loop

        ; increment the adress by 16 and the counter by 1
        add     rbx, 16                    ; add 16 to the current adress
        inc     rcx                        ; increment the counter
        jmp     list_get_loop              ; go to the next element of the list

list_get_loop_exit:

        ; get the timeval.tv_sec of the list element with the given index
        mov     rax, [rbx]                 ; load the tv_sec of the list element into rax
        mov     [rdi], rax                 ; save the tv_sec of the list element into the given adress

        ; get the timeval.tv_usec of the list element with the given index
        mov     rax, [rbx+8]               ; load the tv_usec of the list element into rax
        mov     [rdi+8], rax               ; save the tv_usec of the list element into the given adress

list_get_done:

        ; return true
        mov     rax, 1                     ; return 1 to indicate that the timeval was found and copied to the adress

        ; exit the function
        pop     rbx
        mov     rsp,rbp
        pop     rbp
        ret

list_get_not_found:

        ; return false
        mov     rax, 0                     ; return 0 to indicate that the timeval was not found

        ; exit the function
        mov     rsp,rbp
        pop     rbp
        ret



exit:                                      ; TODO: maybe link to error_handler.asm
        push    rbp
        mov     rbp,rsp
        push    rbx

        mov     rax, sys_write              ; Sys-Call Number (Write)
        mov     rbx, stdout                 ; file discriptor (STD OUT)
        mov     rcx, errorMsg               ; Message to write
        mov     rdx, lenErrorMsg            ; length of the Message
        int     80h                         ; call Kernel

        pop     rbx
        mov     rsp,rbp
        pop     rbp
        ret
