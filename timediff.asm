;-----------------------------------------------------------------------------
; timediff.asm - 
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
; Authors:
;
;----------------------------------------------------------------------------

%include "syscall.inc"  ; OS-specific system call macros

extern ASCII_to_timeval
extern timeval_to_ASCII
extern timeval_to_daystring
extern uint_to_ASCII

;---Function declerations----------------------------------------------------
extern displayError
extern list_init
extern list_size
extern list_is_sorted
extern list_add
extern list_find
extern list_get
;----------------------------------------------------------------------------
sys_read equ 3
sys_write equ 4
stdout equ 1
stdin equ 2

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
        userMsg db 'Please enter a timestamp (to end write "F"): ' ;Message to ask the User to Enter a new timestamp
        lenUserMsg equ $-userMsg                ;The length of the message

timeval:
        tv_sec  dq 0
        tv_usec dq 0

; Example: implementation of the function ASCII_to_timeval and timeval_to_ASCII
        timestamp db '12345678901234567890.123456'
        lenTimestamp equ $-timestamp
        time_char db 'abcdfghijklmnopqrstupabcdef', 10
        lenTimeChar equ $-time_char
; Example: END

; Example: implementation of the function timeval_to_daystring
        daystring db 'DDDDDDDDDDDDDDD days, HH:MM:SS.UUUUUU', 10
        lenDaystring equ $-daystring
; Example: END

        ;-----------------------------------------------------------
        ; ALLOCATE MEMORY FOR OUTPUT
        ;-----------------------------------------------------------
        amountOfTimestamps dw 0
        requiredMemory dq 0
        outputAddress dq 0
        currentWritingAddress dq 0

timevalOne:
        tv_secOne dq 0
        tv_usecOne dq 0
timevalTwo:
        tv_secTwo dq 0
        tv_usecTwo dq 0
timevalDiff:
        tv_secDiff dq 0
        tv_usecDiff dq 0
        
        nextTimestamp dw 0

        ;-----------------------------------------------------------
        ; MEMORY FOR OUTPUT END
        ;-----------------------------------------------------------

;-----------------------------------------------------------------------------
; SECTION BSS
;-----------------------------------------------------------------------------
SECTION .bss
        timestamp_input resb 128

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
        global _start:function          ; make label available to linker

_start:                                 ; Programm Start

; Example: implementation of the function ASCII_to_timeval and timeval_to_ASCII
        ; ; bool ASCII_to_timeval(struct timeval *tv, char *ascii_time, short len)
        ; mov rdi, timeval
        ; mov rsi, timestamp
        ; xor rdx, rdx
        ; mov dx, lenTimestamp
        ; call ASCII_to_timeval
        ; ; rax now holds 1 if successful, 0 if not

        ; ; void timeval_to_ASCII(char *ascii_time, struct timeval *tv)
        ; mov rdi, time_char
        ; mov rsi, timeval
        ; call timeval_to_ASCII

        ; ; Write time_char
        ; mov eax, sys_write              ; Sys-Call Number (Write)
        ; mov ebx, stdout                 ; file discriptor (STD OUT)
        ; mov ecx, time_char              ; Message to write
        ; mov edx, lenTimeChar            ; length of the Message
        ; int 80h                         ; call Kernel

; Example: END

; Example: implementation of the function timeval_to_daystring
        ; ; void timeval_to_daystring(char *daystring, struct timeval *tv)
        ; mov rdi, daystring
        ; mov rsi, timeval
        ; call timeval_to_daystring

        ; ; Write daystring
        ; mov rax, sys_write              ; Sys-Call Number (Write)
        ; mov rbx, stdout                 ; file discriptor (STD OUT)
        ; mov rcx, daystring              ; Message to write
        ; mov rdx, lenDaystring           ; length of the Message
        ; int 80h                         ; call Kernel

; Example: END

readNextTimestamp:
        
        ; Write the initial User Message
        mov eax, sys_write              ; Sys-Call Number (Write)
        mov ebx, stdout                 ; file discriptor (STD OUT)
        mov ecx, userMsg                ; Message to write
        mov edx, lenUserMsg             ; length of the Message
        int 80h                         ; call Kernel

        ;Read and store the user input
        mov eax, sys_read               ; Sys-Call Number (Read)
        mov ebx, stdin                  ; file discriptor (STD IN)
        mov ecx, timestamp_input        ; input is stored into timestamp_input
        mov edx, 128                    ; size of Input
        int 80h                         ; call Kernel

        ;Compare if timestamp is F
        lea     rsi, [timestamp_input]  ; load the address of buffer to rsi
        movzx   rdx, byte [rsi]         ; load first char to
        cmp     rdx, 70                 ; check if first char is "F"
        je      finishedInput           ; if its F input is finished
        ;TODO --> Add to list
        jne     readNextTimestamp       ; not F input not finished

finishedInput:
        ;Test Purpose to test the Jump
        mov eax, sys_write              ; Sys-Call Number (Write)
        mov ebx, stdout                 ; file discriptor (STD OUT)
        mov ecx, userMsg                ; Message to write
        mov edx, lenUserMsg             ; length of the Message
        int 80h                         ; call Kernel


        ;-----------------------------------------------------------
        ; ALL INPUTS ARE DONE, START WITH OUTPUT
        ; Author: Henry Schuler
        ;-----------------------------------------------------------

.start_output:
        ; call short list_size(void)
        call list_size                          ; get the amount of timestamps in the list
        mov [amountOfTimestamps], ax            ; store the amount of timestamps in the list
        cmp WORD [amountOfTimestamps], 0        ; check if the list is empty
        je .exit                                ; TODO: exit because no input

        ; call bool list_is_sorted(void)
        call list_is_sorted                     ; check if the list is sorted
        cmp ax, 0                               ; check if false
        je .exit                                ; TODO: exit because list not sorted

        ; min. 1 timestamp in list and list is sorted
.calculate_required_memory:
        ; first line: 28 BYTEs
        ; following lines: 8 (separator) + 28 (timestamp) + 38 (timediff) = 74 BYTEs
        mov cx, WORD [amountOfTimestamps]       ; set counter to amount of timestamps
        mov rax, 28                             ; add momory for first line
.calculate_space_following_line:
        dec cx                                  ; decrement counter
        jz .allocate_memory                     ; if counter is 0, allocate memory
        add rax, 74                             ; add memory for following line
        jmp .calculate_space_following_line     ; repeat

.allocate_memory:
        mov [requiredMemory], rax               ; store the required memory in requiredMemory

        push rbx                                ; save rbx
        ; set the first breakpoint
        mov rax, 45                             ; load sys_brk into rax
        xor rbx, rbx                            ; clear rbx needed for sys_brk
        int 80h                                 ; call kernel -> first breakpoint

        cmp rax, 0                              ; check if sys_brk was successful (-1 if not)
        jl .exit                                ; TODO: exit because memory could not be allocated
        mov [outputAddress], rax                ; store the address of the allocated memory in outputAddress

        ; set the second breakpoint
        add rax, [requiredMemory]               ; add the required memory to the start address
        mov rbx, rax                            ; set rbx to the last address
        mov rax, 45                             ; load sys_brk into rax
        int 80h

        cmp rax, 0                              ; check if sys_brk was successful (-1 if not)
        jl .exit                                ; TODO: exit because memory could not be allocated

        ; memory is allocated
        pop rbx                                 ; restore rbx

.fill_allocated_memory:
        ; add first timestamp to output
        ; call bool list_get(struct timeval *tv, short idx)
        mov rdi, timevalOne                     ; set tv to timevalOne
        mov rsi, [nextTimestamp]                ; set idx to 0 -> get first element
        
        call list_get                           ; get the first timestamp
        
        cmp rax, 0                              ; check if list_get was successful
        je .exit                                ; TODO: exit because list_get was not successful
        
        ; first timestamp in timevalOne
        inc WORD [nextTimestamp]                ; increment lastGotTimestamp
        ; call void timeval_to_ASCII(char *ascii_time, struct timeval *tv)
        mov rdi, [outputAddress]                ; set ascii_time to the start address of the allocated memory
        mov rsi, timevalOne                     ; set tv to timevalOne
        
        call timeval_to_ASCII                   ; convert the timestamp to ASCII

        ; add linebreak after first timestamp
        mov rdi, [outputAddress]                ; set rdi to the start address of the allocated memory
        add rdi, 27                             ; get to the end of the first timestamp
        mov BYTE [rdi], 10                      ; add linebreak after first timestamp

        ; first timestamp is written -> check if there are more timestamps
        mov cx, WORD [amountOfTimestamps]       ; set counter to amount of timestamps
        dec cx                                  ; decrement counter (first timestamp is written)
        jz .print_output


        mov rax, [outputAddress]
        add rax, 28                             ; get to the start of the second timestamp
        mov [currentWritingAddress], rax        ; store the current writing address in currentWritingAddress
.add_following_timestamps:
        ; add separator
        ; call void uint_to_ASCII(char *string, long number, short length, char fillCharacter, bool printZero)
        mov rdi, [currentWritingAddress]        ; set string to the start address of the separator
        mov rsi, 0                              ; set number to 0
        mov dx, 7                               ; set length to 7
        mov cl, '='                             ; set fillCharacter to '='
        mov r8, 0                               ; set printZero to false
        call uint_to_ASCII                      ; convert the number to ASCII (here misused for printing separator)

        ; add linebreak after separator
        mov rdi, [currentWritingAddress]        ; set rdi to the start address of the separator
        add rdi, 7                              ; get to the end of the separator
        mov BYTE [rdi], 10                      ; add linebreak after separator

        ; update the new writing address
        inc rdi                                 ; increment rdi to the start address of the next timestamp
        mov [currentWritingAddress], rdi        ; store the current writing address in currentWritingAddress

        ; add next timestamp to output
        ; call bool list_get(struct timeval *tv, short idx)
        mov rdi, timevalTwo                     ; set tv to timevalTwo
        mov rsi, [nextTimestamp]                ; set idx to the next timestamp index
        
        call list_get                           ; get the next timestamp

        cmp rax, 0                              ; check if list_get was successful
        je .exit                                ; TODO: exit because list_get was not successful

        ; next timestamp in timevalTwo
        inc WORD [nextTimestamp]                ; increment lastGotTimestamp
        ; call void timeval_to_ASCII(char *ascii_time, struct timeval *tv)
        mov rdi, [currentWritingAddress]        ; set ascii_time to the current address of the allocated memory
        mov rsi, timevalTwo                     ; set tv to timevalTwo

        call timeval_to_ASCII                   ; convert the timestamp to ASCII

        ; add linebreak after timestamp
        mov rdi, [currentWritingAddress]        ; set rdi to the start current of the allocated memory
        add rdi, 27                             ; get to the end of the timestamp
        mov BYTE [rdi], 10                      ; add linebreak after timestamp

        ; update the new writing address
        inc rdi                                 ; increment rdi to the start address of the next timestamp/diff
        mov [currentWritingAddress], rdi        ; store the current writing address in currentWritingAddress

        ; calculate difference
        mov rax, [timevalTwo + 8]               ; set rax to tv_usecTwo
        sub rax, [timevalOne + 8]               ; subtract tv_usecOne from tv_usecTwo
        mov [timevalDiff + 8], rax              ; store the difference in tv_usecDiff

        mov rax, [timevalOne]                   ; set rax to tv_secOne
        sbb rax, [timevalTwo]                   ; subtract tv_secTwo from tv_secOne (with carry)
        mov [timevalDiff], rax                  ; store the difference in tv_secDiff

        ; difference is now in timevalDiff
        ; call void timeval_to_daystring(char *daystring, struct timeval *tv)
        mov rdi, [currentWritingAddress]        ; set daystring to the current address of the allocated memory
        mov rsi, timevalDiff                    ; set tv to timevalDiff

        call timeval_to_daystring               ; convert the difference to daystring

        ; add linebreak after daystring
        mov rdi, [currentWritingAddress]        ; set rdi to the start address of the allocated memory
        add rdi, 37                             ; get to the end of the daystring
        mov BYTE [rdi], 10                      ; add linebreak after daystring

        ; update the new writing address
        inc rdi                                 ; increment rdi to the start address of the next timestamp/diff
        mov [currentWritingAddress], rdi        ; store the current writing address in currentWritingAddress

        mov ax, WORD [amountOfTimestamps]       ; set rax to amountOfTimestamps
        cmp ax, WORD [nextTimestamp]            ; check if the last timestamp was printed (amountOfTimestamps == nextTimestamp) because nextTimestamp is a index and therfore the amount of read timestamps
        je .print_output                        ; if yes, print the output

        ; move timevalTwo to timevalOne
        mov rax, [timevalTwo]                   ; set rax to tv_secTwo
        mov [timevalOne], rax                   ; move timevalTwo to timevalOne
        mov rax, [timevalTwo + 8]               ; set rax to tv_usecTwo
        mov [timevalOne + 8], rax               ; move tv_usecTwo to tv_usecOne

        jmp .add_following_timestamps           ; go to the next timestamp

.print_output:
        mov rax, sys_write
        mov rbx, stdout
        mov rcx, [outputAddress]
        mov rdx, [requiredMemory]
        int 80h

        ;-----------------------------------------------------------
        ; OUTPUT IS DONE, EXIT PROGRAM
        ;-----------------------------------------------------------

        ;-----------------------------------------------------------
        ; call system exit and return to operating system / shell
        ;-----------------------------------------------------------
.exit:  SYSCALL_2 SYS_EXIT, 0
        ;-----------------------------------------------------------
        ; END OF PROGRAM
        ;-----------------------------------------------------------