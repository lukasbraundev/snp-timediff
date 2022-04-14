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
        mov     rax, 45	                ; load sys_brk (allocate mem) into eax
        xor     rbx, rbx                ; clear rbx (needed for sys_brk)
        int     80h                     ; call sys_brk (first breakpoint)

        ; check if the first breakpoint was set correctly
        cmp     rax, 0                  ; check if the allocation was successful (-1 if not)
        jl      exit	                ; if not, exit the program 

        ; set the second breakpoint (end of the list)
        mov     [startAdress], rax      ; save start adress of the program in startAdress
        add     rax, 1048576            ; add number of bytes to be reserved (65 536 (16 bit) * 2 (tv_sec + tv_usec) * 8)
        mov     rbx, rax                ; save the adress of second breakpoint in rbx
        mov     rax, 45                 ; load sys_brk (allocate mem) into eax
        int     80h                     ; call sys_brk (second breakpoint)
                
        ; check if the second breakpoint was set correctly
        cmp     rax, 0                  ; check if the allocation was successful (-1 if not)
        jl      exit	                ; if not, exit the program 

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
        mov     rax, [listSize]         ; load the size of the list into rax

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
        mov     rax, [listSize]         ; load the size of the list into rax
        cmp     rax, 0                  ; check if the list is empty
        je      .exit_not_sorted        ; if so, return false

        ; begin to check if the list is sorted
        mov     rbx, [startAdress]      ; load the start adress of the list into rax
        mov     rcx, 1                  ; set counter to 1
        mov     rdx, 1                  ; set return value to true

.loop: 

        ; load the two tv_sec to compare
        mov     r8, [rbx]               ; load the current tv_sec of the list into r8 
        mov     r9, [rbx+16]            ; load the next tv_sec of the list into r9

        ; compare the two tv_sec values
        cmp     r9, r8                  ; check if the next tv_sec is bigger than the current tv_sec
        jb      .exit_not_sorted        ; if not, return false
        ja      .already_bigger_tv_sec

        ; load the two tv_usec to compare
        mov     r8, [rbx+8]             ; load the current tv_usec of the list into r8
        mov     r9, [rbx+24]            ; load the next tv_usec of the list into r9

        ; compare the two tv_usec values
        cmp     r9, r8                  ; check if the next tv_usec is bigger than the current tv_usec
        jle     .exit_not_sorted        ; if not, return false

.already_bigger_tv_sec:

        ; the tv_usec values are not relevant if the tv_sec values are already not equal
        add     rbx, 16                 ; increase the current adress by 16 bytes (size of one tv_sec)
        inc     rcx                     ; increment the counter by 1
        cmp     rcx, [listSize]         ; check if the counter is equal to the size of the list
        je      .loop_exit              ; if so, the list is gone through -> return true
        jne     .loop                   ; if not, go to the beginning of the loop

.exit_not_sorted:
        
        ; return false
        mov     rdx, 0                  ; return false

.loop_exit:

        ; all elements are gone through -> return true
        mov     rax, rdx                ; return the return value

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

.loop:

        ; check if the right adress is reached
        cmp     rcx, [listSize]         ; check if the counter is equal the size of the list
        je      .loop_exit              ; if so, the right adress is reached

        ; increment the counter
        add     rbx, 16                 ; add 16 to the current adress
        inc     rcx                     ; increment the counter
        jmp     .loop

.loop_exit:
        
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
        push    r12
        push    r13
        push    r14

        ; store given tv
        mov     r10, rdi                ; write the adress of the tv in r10

        ; immediately return 0 if the list is empty
        mov     rax, [listSize]         ; load the size of the list into rax
        cmp     rax, 0                  ; check if the list is empty
        je      .exit_not_found         ; if so, return false

        ; check if tv is smaller or equal than the smallest tv
        mov     rdi, r10                ; write adress of given tv in rdi (for compare_timevals())
        mov     rsi, [startAdress]      ; write start adress of list in rsi (for compare_timevals())
        mov     rbx, 0                  ; current comparison at index 0 (for return) 
        call    compare_timevals        ; compaires tv at rdi and rsi 
        cmp     rax, 1                  ; rax: 0 (rdi<rsi), 1 (rdi==rsi), 2 (rdi>rsi), 
        je      .exit_found             ; if equal -> found already
        jb      .exit_not_found         ; if smaller the tv is not in the list

        ; check if tv is bigger or equal than the biggest tv
        mov     rdi, [listSize]         ; write current list size in rdi
        dec     rdi                     ; decrement it (getting last tv's index)
        mov     rbx, rdi                ; current comparison at last (for return) 
        call    get_adress_by_index     ; get adress from index in rdi in rax
        mov     rdi, r10                ; write adress of given tv in rdi (for compare_timevals())
        mov     rsi, rax                ; write adress of last tv in rsi (for compare_timevals())
        call    compare_timevals        ; compaires tv at rdi and rsi 
        cmp     rax, 1                  ; rax: 0 (rdi<rsi), 1 (rdi==rsi), 2 (rdi>rsi), 
        je      .exit_found             ; if equal -> found already
        ja      .exit_not_found         ; if smaller the tv is not in the list
        
        ; start binary search loop
        ; define borders (r11, r13)
        mov     r11, 0                  ; set lower border
        mov     r13, [listSize]
        dec     r13                     ; set higher border

.loop:

        ; get middle of borders (r12)
        mov     rax, r13
        sub     rax, r11                ; rax: higher border - lower border
        mov     r14, 2                  ; set divisor
        xor     rdx, rdx                ; clear output register
        div     r14
        add     rax, r11                ; add lower border to get middle
        mov     r12, rax                ; save middle of borders

        ; compair middle with 
        mov     rbx, r12                ; current comparison at middle (for return) 
        ; call long get_address_by_index(int index);
        mov     rdi, r12
        call    get_adress_by_index     ; get middle adress

        ; call int compare_timevals(struct timeval *tv1, struct timeval *tv2)
        mov     rdi, r10                ; write adress of given tv in rdi (for compare_timevals())
        mov     rsi, rax                ; write middle adress in rsi (for compare_timevals())
        call    compare_timevals
        cmp     rax, 1
        jb      .lower
        ja      .higher
        je      .exit_found

.lower:

        cmp     r11, r13
        je      .exit_not_found

        ; higher bound = middle
        mov     r13, r12
        jmp    .loop

.higher:

        ; check if lower border == middle 
        cmp     r11, r12
        cmove   r11, r13                ; if lower border == middle -> set higher border to lower border -> force checking higher border value

        ; if not: lower bound = middle
        cmovne     r11, r12
        jmp    .loop

.exit_not_found:

        mov     rax, -1
        jmp     .end_return

.exit_found:

        mov     rax, rbx
        jmp     .end_return 

.end_return:

        pop     r14
        pop     r13
        pop     r12
        pop     rbx

        mov     rsp,rbp
        pop     rbp
        ret


;-----------------------------------------------------------------------------
; extern long get_adress_by_index(int index);
; rdi (index) -> rax (adress)   NOTE: can be improved 
;-----------------------------------------------------------------------------
        global get_adress_by_index:function
get_adress_by_index: 

        push    rbp
        mov     rbp,rsp

        push    rbx
        
        xor     rcx, rcx                ; clear counter
        mov     rbx, [startAdress]      ; start adress in rbx

.loop:

        cmp     rcx, rdi                ; compair the current index with the given index
        je      .loop_exit              ; if equal -> finished

        add     rbx, 16                 ; increment the current adress with 16
        inc     rcx                     ; increment the current index (counter) with 1
        jmp     .loop                   ; next index
   
.loop_exit:

        mov     rax, rbx                ; return the current adress

        pop     rbx

        mov     rsp,rbp
        pop     rbp
        ret


;-----------------------------------------------------------------------------
; int compare_timevals(struct timeval *tv1, struct timeval *tv2) (RDX, RSI)
; returns in RAX:
;       0 if tv1 < tv2
;       1 if tv1 == tv2
;       2 if tv1 > tv2
;-----------------------------------------------------------------------------
        global compare_timevals:function
compare_timevals:

        push    rbp
        mov     rbp, rsp

        ; load the two tv_sec to compare
        mov     r8, [rdi]               ; load first tv_sec into r8
        mov     r9, [rsi]               ; load second tv_sec into r8

        ; compare the two tv_sec values
        cmp     r8, r9                  ; compare the two tv_sec
        jb      .smaller                ; if already smaller return 0
        ja      .bigger                 ; if already bigger return 2
        
        ; load the two tv_usec to compare
        mov     r8, [rdi+8]             ; load first tv_usec into r8
        mov     r9, [rsi+8]             ; load second tv_usec into r9

        ; compare the two tv_usec values
        cmp     r8, r9                  ; compare the two tv_sec
        jb      .smaller                ; if smaller return 0
        ja      .bigger                 ; if bigger return 2
        je      .equal                  ; if equal return 1

.smaller:

        mov     rax, 0                  ; return 0 
        call    .compaired


.bigger:

        mov     rax, 2                  ; return 2
        call    .compaired


.equal:

        mov     rax, 1                  ; return 1
        call    .compaired

.compaired:

        mov     rsp, rbp
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
        mov     rax, [listSize]                 ; load the size of the list into rax
        cmp     rax, 0                          ; check if the size is 0
        je      .not_found                      ; if so, return false

        ; check if the index is bigger than the list size
        mov     rax, [listSize]                 ; load the size of the list into rax
        cmp     rsi, rax                        ; check if the param index is bigger than the size of the list
        jge     .not_found                      ; if so, return false

        ; check if the index is smaller than 0
        cmp     rsi, 0                          ; check if the param index is smaller than 0
        jl      .not_found                      ; if so, return false


        ; get the offset to the adress of the given index
        mov     rax, rsi                        ; load the index into rax
        mov     rbx, 16                         ; set the offset for one address in rbx (multiplyer)
        xor     rdx, rdx                        ; clear the output register
        mul     rbx                             ; rax * rbx = offset

        ; calculate the adress of the given index (rbx)
        mov     rbx, [startAdress]              ; load the start adress of the list into rbx
        add     rbx, rax                        ; add the offset to the start adress to get the adress of the given index

        ; get the timeval.tv_sec of the list element with the given index
        mov     rax, [rbx]                      ; load the tv_sec of the list element into rax
        mov     [rdi], rax                      ; save the tv_sec of the list element into the given adress

        ; get the timeval.tv_usec of the list element with the given index
        mov     rax, [rbx+8]                    ; load the tv_usec of the list element into rax
        mov     [rdi+8], rax                    ; save the tv_usec of the list element into the given adress

.done:

        ; return true
        mov     rax, 1                          ; return 1 to indicate that the timeval was found and copied to the adress

        ; exit the function
        pop     rbx
        mov     rsp,rbp
        pop     rbp
        ret

.not_found:

        ; return false
        mov     rax, 0                          ; return 0 to indicate that the timeval was not found

        ; exit the function
        mov     rsp,rbp
        pop     rbp
        ret



exit:
        push    rbp
        mov     rbp,rsp
        push    rbx

        mov     rax, sys_write          ; Sys-Call Number (Write)
        mov     rbx, stdout             ; file discriptor (STD OUT)
        mov     rcx, errorMsg           ; Message to write
        mov     rdx, lenErrorMsg        ; length of the Message
        int     80h                     ; call Kernel

        pop     rbx
        mov     rsp,rbp
        pop     rbp
        ret
