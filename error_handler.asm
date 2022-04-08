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
        inpuError db 'Input Error - falsche Eingabe'
        inputError_len equ $-inpuError


;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text


;-----------------------------------------------------------------------------
; Display Error Funktion
;-----------------------------------------------------------------------------
        global displayError:function
displayError:
        nop             ;TODO
        ret
