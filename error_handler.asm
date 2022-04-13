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

%include "syscall.inc"

SECTION .data
        inpuError db 'Input Error - incorrect input', 10
        inputError_len equ $-inpuError
        sorted_error db 'Sorted Error - order of timestamp incorrect', 10
        sorted_error_len equ $-sorted_error
        memory_allocation_error db 'Memory Error - allocation of Memory was not possible', 10
        memory_allocation_error_len equ $-memory_allocation_error
        maxInputError db 'Input Error - maximum count of timestamps', 10
        maxInputError_len equ $-maxInputError

inputErrorIdx equ 0
sortedErorIdx equ 1
memoryErrorIdx equ 2
maxInputErrorIdx equ 3

;----------------------------------------------------------------------------
sys_read equ 3
sys_write equ 4
stdout equ 1
stdin equ 2
;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text


;-----------------------------------------------------------------------------
; Display Error Funktion
;-----------------------------------------------------------------------------
        global displayError:function
displayError:
        push rbp                                ; save stack base of caller
        mov rbp, rsp                            ; set stack pointer to stack base of callee
        cmp rdi, inputErrorIdx                  ; check which messsage to print
        je .displayInputError
        cmp rdi, sortedErorIdx
        je .displaySortedError
        cmp rdi, memoryErrorIdx
        je .displayMemoryError
        cmp rdi, maxInputErrorIdx
        je .displayMaxInputError

.displayInputError:
        mov eax, sys_write                      ; Sys-Call Number (Write)
        mov ebx, stdout                         ; file discriptor (STD OUT)
        mov ecx, inpuError                      ; Message to write
        mov edx, inputError_len                 ; length of the Message
        int 80h                                 ; call Kernel
        jmp .end_function                       ; end function

.displaySortedError:
        mov eax, sys_write                      ; Sys-Call Number (Write)
        mov ebx, stdout                         ; file discriptor (STD OUT)
        mov ecx, sorted_error                   ; Message to write
        mov edx, sorted_error_len               ; length of the Message
        int 80h                                 ; call Kernel
        jmp .end_function                       ; end function

.displayMemoryError:
        mov eax, sys_write                      ; Sys-Call Number (Write)
        mov ebx, stdout                         ; file discriptor (STD OUT)
        mov ecx, memory_allocation_error        ; Message to write
        mov edx, memory_allocation_error_len    ; length of the Message
        int 80h                                 ; call Kernel
        jmp .end_function                       ; end function        

.displayMaxInputError:
        mov eax, sys_write                      ; Sys-Call Number (Write)
        mov ebx, stdout                         ; file discriptor (STD OUT)
        mov ecx, maxInputError                  ; Message to write
        mov edx, maxInputError_len              ; length of the Message
        int 80h                                 ; call Kernel
        jmp .end_function                       ; end function        

.end_function:
        mov rsp, rbp                            ; restore stack pointer of caller
        pop rbp                                 ; restore stack base of caller
        ret