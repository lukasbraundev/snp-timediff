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
        inpuError db 'Input Error - incorrcet input', 10
        inputError_len equ $-inpuError
        sorted_error db 'Sorted Error - Orde of timestamp incorrect', 10
        sorted_error_len equ $-sorted_error
        memory_allocation_error db 'Memory Error - Allocation of Memory was not possible', 10
        memory_allocation_error_len equ $-memory_allocation_error

inputErrorIdx equ 0
sortedErorIdx equ 1
memoryErrorIdx equ 2

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
        push rbp				; save stack base of caller
        mov rbp, rsp				; set stack pointer to stack base of callee
        push rdi				; save callee-saved register (index of Error Message is in rdi)
        cmp rdi, inputErrorIdx
        je .displayInputError
        cmp rdi, sortedErorIdx
        je .displaySortedError
        cmp rdi, memoryErrorIdx
        je .displayMemoryError

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


.end_function:
        pop rdi					; restore callee-saved register
        mov rsp, rbp				; restore stack pointer of caller
        pop rbp					; restore stack base of caller
        ret