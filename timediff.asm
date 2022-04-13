;-----------------------------------------------------------------------------
; timediff.asm - cat test.txt | ./timediff
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

%include "syscall.inc"  ; OS-specific system call macros

;---Function declerations----------------------------------------------------
extern ASCII_to_timeval
extern timeval_to_ASCII
extern timeval_to_daystring
extern uint_to_ASCII
extern displayError

extern list_init
extern list_size
extern list_is_sorted
extern list_add
extern list_find
extern list_get
;----Constants----------------------------------------------------------------
stdin equ 0
stdout equ 1
sys_read equ 3
sys_write equ 4

BUFFER_SIZE equ 80

;-----------------------------------------------------------------------------
; SECTION DATA
;-----------------------------------------------------------------------------
SECTION .data
timeval:
        tv_sec  dq 0
        tv_usec dq 0

        possible_timechar db '                            '     ; 28 characters to hold timeval input (S+.M+)
        possible_timechar_len equ $-possible_timechar
        timestampSecondDigits dq 0              ; holds the amount of read second digits

        ;-----------------------------------------------------------
        ; ALLOCATE MEMORY FOR OUTPUT
        ;-----------------------------------------------------------
        amountOfTimestamps dw 0                 ; holds the amount of timestamps in the list
        requiredMemory dq 0                     ; holds the required memory for the ouput in Bytes
        outputAddress dq 0                      ; holds the start address of the output buffer
        currentWritingAddress dq 0              ; holds the current writing address in the output buffer
        nextTimestamp dw 0                      ; holds the index of the next timestamp in the list

timevalOne:
        tv_secOne dq 0
        tv_usecOne dq 0
timevalTwo:
        tv_secTwo dq 0
        tv_usecTwo dq 0
timevalDiff:
        tv_secDiff dq 0
        tv_usecDiff dq 0
        
        ;-----------------------------------------------------------
        ; MEMORY FOR OUTPUT END
        ;-----------------------------------------------------------

;-----------------------------------------------------------------------------
; SECTION BSS
;-----------------------------------------------------------------------------
SECTION .bss
                align 128               ; make sure that buffer adress is a multiple of 128
        buffer  resb BUFFER_SIZE        ; buffersize for input
                resb 128                ; zero after buffer so that buffer end can be determined

;-----------------------------------------------------------------------------
; SECTION TEXT
;-----------------------------------------------------------------------------
SECTION .text

        ;-----------------------------------------------------------
        ; PROGRAM'S START ENTRY
        ;-----------------------------------------------------------
        global _start:function                  ; make label available to linker

_start:                                         ; Programm Start

        ; call void list_init(void)
        call list_init                          ; Setup the list
        ;------------------------------------------------------
        ; Startig with the Input
        ;------------------------------------------------------
.init:
        mov r12, 0                              ; ctr for the possible timechar index
        mov r15, 0                              ; ctr for complete timestamps
.read_next_string:
        ; Read from STD in
        mov rax, sys_read                       ; Sys-Call Number (Read)
        mov rbx, stdin                          ; file discriptor (STD IN)
        mov rcx, buffer                         ; input is stored into buffer
        mov rdx, BUFFER_SIZE                    ; size of Input
        int 80h                                 ; call Kernel
        test rax,rax                            ; check system call return value
        jz .finshed_input                       ; jump to exit if nothing is read (end)
        lea rsi, [buffer]                       ; loads adress of first char into rsi
        mov byte [buffer+rax], 128              ; determines the End of the Buffer

.next_char:      
        mov dl, byte [rsi]                      ; load next char from buffer
        cmp dl, 127                             ; check if its a char
        ja  .read_next_string                   ; jump if no char
        cmp dl, 10                              ; check for linefeed
        je .timestamp_finished                  ; jump if timestamp detected
        cmp r12, 27                             ; check if input length is max
        je .input_error
        mov [possible_timechar + r12], dl
        inc r12                                 ; inc possible timechar index
        inc rsi                                 ; inc adress in Buffer
        jmp .next_char



.timestamp_finished:
        inc r15                                 ; increment foreach completed timestamp
        cmp r15, 10001                          ; check if maxmimum count
        je .error_max_timestamp                 ; if max Count jump to error

        ; Check for correct syntax
        mov r13, 0                              ; Index for each char
        mov r14, 0                              ; Counter for the correct chars

.verify_before_dot:
        cmp r14, 21                             ; check if there are more than 20 numbers before the point
        je .input_error
        mov dl, byte [possible_timechar + r13]  ; load the char to dl
        cmp dl, 46                              ; check for .
        je .point_detected
        cmp dl, 57                              ; check if ist numeric upper end
        jg .input_error
        cmp dl, 48                              ; check if ist numeric lower end
        jl .input_error
        inc r13                                 ; inc char index
        inc r14                                 ; inc correct char Counter
        jmp .verify_before_dot


.point_detected:
        cmp r14,0                               ; check if there numbers before the point
        je .input_error
        add [timestampSecondDigits], r14        ; add the number of digits before the point to the counter (needed for output later)
        mov r14, 0
        inc r13
        cmp r13, r12                            ; check if the index is on the End r12 is the length
        je .input_error                         ; if than verification in finished

.verify_after_dot:
        cmp r14, 6                              ; check if there are more than 6 numbers after the point
        je .input_error
        mov dl, byte [possible_timechar + r13]  ; load the char to dl
        cmp dl, 57                              ; check if ist numeric upper end
        jg .input_error
        cmp dl, 48                              ; check if ist numeric lower end
        jl .input_error
        inc r13         
        inc r14
        cmp r13, r12                            ; check if the index is on the End r12 is the length
        je .verified_finish                     ; if than verification in finished
        jmp .verify_after_dot        

.verified_finish:                               ; Syntax verification completed

        ; call bool ASCII_to_timeval(struct timeval *tv, char *ascii_time, short len)
        push rsi                                ; save register to stack
        push rdx                                ; save register to stack
        mov rdi, timeval
        mov rsi, possible_timechar
        xor rdx, rdx
        mov dx, r12w
        call ASCII_to_timeval
        pop rdx                                 ; get register back from stack
        pop rsi                                 ; get register back from stack
        cmp rax, 0                              ; check if conversation was false
        je .input_error                         ; if so, exit programnm
        
        ; call short list_add(struct timeval *tv)
        push rsi
        push rdx
        mov rdi, timeval
        call list_add
        pop rdx
        pop rsi
        ; placeholder reinitialize
        mov r12, 0
.loop_reinit_placholder:                        ; mov ' ' on each index of possible_timechar
        mov dl, byte 32
        mov [possible_timechar + r12], dl       ; mov ' ' 
        inc r12
        cmp r12, 27                             ; check if end of buffer
        jne .loop_reinit_placholder
        mov r12, 0                              ; reset indexctr for possible_timestamp
        inc rsi                                 ; inc buffer index for next char
        jmp .next_char                          ; start reading the next timestamp
.finshed_input:

        ;-----------------------------------------------------------
        ; ALL INPUTS ARE DONE, START WITH OUTPUT
        ;-----------------------------------------------------------

.start_output:
        ; call short list_size(void)
        call list_size                          ; get the amount of timestamps in the list
        mov [amountOfTimestamps], ax            ; store the amount of timestamps in the list
        cmp WORD [amountOfTimestamps], 0        ; check if the list is empty
        je .input_error                         ; exit because no input

        ; call bool list_is_sorted(void)
        call list_is_sorted                     ; check if the list is sorted
        cmp rax, 0                              ; check if false
        je .not_sorted_error                    ; exit because list not sorted

        ; min. 1 timestamp in list and list is sorted
.calculate_required_memory:
        xor rax, rax                            ; reset rax to hold the amount of bytes needed
        add rax, [timestampSecondDigits]        ; add the amount of digits for the seconds of all timestamps (evaluated during input)
        
        ; first line: 8 BYTEs
        add rax, 8                              ; add momory for first line '.' + microseconds + line feed

        mov cx, WORD [amountOfTimestamps]       ; set counter to amount of timestamps
.calculate_space_following_line:
        dec cx                                  ; decrement counter
        jz .allocate_memory                     ; if counter is 0, allocate memory
        ; following lines: 8 (separator) + 8 (timestamp: '.' + microseconds + line feed) + 38 (timediff) = 54 BYTEs
        add rax, 54                             ; add memory for following line
        jmp .calculate_space_following_line     ; repeat

.allocate_memory:
        mov [requiredMemory], rax               ; store the required memory in requiredMemory

        ; set the first breakpoint
        mov rax, 45                             ; load sys_brk into rax
        xor rbx, rbx                            ; clear rbx needed for sys_brk
        int 80h                                 ; call kernel -> first breakpoint

        cmp rax, 0                              ; check if sys_brk was successful (-1 if not)
        jl .memory_error                        ; exit because memory could not be allocated
        mov [outputAddress], rax                ; store the address of the allocated memory in outputAddress

        ; set the second breakpoint
        add rax, [requiredMemory]               ; add the required memory to the start address
        mov rbx, rax                            ; set rbx to the last address
        mov rax, 45                             ; load sys_brk into rax
        int 80h

        cmp rax, 0                              ; check if sys_brk was successful (-1 if not)
        jl .memory_error                        ; exit because memory could not be allocated

        ; memory is allocated

.fill_allocated_memory:
        ; add first timestamp to output
        ; call bool list_get(struct timeval *tv, short idx)
        mov rdi, timevalOne                     ; set tv to timevalOne
        movzx rsi, WORD [nextTimestamp]         ; set idx to 0 -> get first element
        
        call list_get                           ; get the first timestamp
        
        cmp rax, 0                              ; check if list_get was successful
        je .exit                                ; exit because list_get was not successful
        
        ; first timestamp in timevalOne
        inc WORD [nextTimestamp]                ; increment lastGotTimestamp
        ; call short timeval_to_ASCII(char *ascii_time, struct timeval *tv)
        mov rdi, [outputAddress]                ; set ascii_time to the start address of the allocated memory
        mov rsi, timevalOne                     ; set tv to timevalOne
        
        call timeval_to_ASCII                   ; convert the timestamp to ASCII

        ; add linebreak after first timestamp
        mov rdi, [outputAddress]                ; set rdi to the start address of the allocated memory
        add rdi, rax                            ; get to the end of the first timestamp (rax from timeval_to_ASCII)
        mov BYTE [rdi], 10                      ; add linebreak after first timestamp

        ; update the new writing address
        inc rdi                                 ; increment rdi to the start address of the next timestamp
        mov [currentWritingAddress], rdi        ; store the current writing address in currentWritingAddress

        ; first timestamp is written -> check if there are more timestamps
        mov cx, WORD [amountOfTimestamps]       ; set counter to amount of timestamps
        dec cx                                  ; decrement counter (first timestamp is written)
        jz .print_output

.add_following_timestamps:
        ; add separator
        ; call short uint_to_ASCII(char *string, long number, short length, char fillCharacter, bool printZero)
        mov rdi, [currentWritingAddress]        ; set string to the start address of the separator
        mov rsi, 0                              ; set number to 0
        mov dx, 7                               ; set length to 7
        mov cl, '='                             ; set fillCharacter to '='
        mov r8, 0                               ; set printZero to false
        call uint_to_ASCII                      ; convert the number to ASCII (here misused for printing separator)

        ; add linebreak after separator
        mov rdi, [currentWritingAddress]        ; set rdi to the start address of the separator
        add rdi, rax                            ; get to the end of the separator (rax from uint_to_ASCII)
        mov BYTE [rdi], 10                      ; add linebreak after separator

        ; update the new writing address
        inc rdi                                 ; increment rdi to the start address of the next timestamp
        mov [currentWritingAddress], rdi        ; store the current writing address in currentWritingAddress

        ; add next timestamp to output
        ; call bool list_get(struct timeval *tv, short idx)
        mov rdi, timevalTwo                     ; set tv to timevalTwo
        movzx rsi, WORD [nextTimestamp]         ; set idx to the next timestamp index
        
        call list_get                           ; get the next timestamp

        cmp rax, 0                              ; check if list_get was successful
        je .exit                                ; exit because list_get was not successful

        ; next timestamp in timevalTwo
        inc WORD [nextTimestamp]                ; increment lastGotTimestamp
        ; call short timeval_to_ASCII(char *ascii_time, struct timeval *tv)
        mov rdi, [currentWritingAddress]        ; set ascii_time to the current address of the allocated memory
        mov rsi, timevalTwo                     ; set tv to timevalTwo

        call timeval_to_ASCII                   ; convert the timestamp to ASCII

        ; add linebreak after timestamp
        mov rdi, [currentWritingAddress]        ; set rdi to the start current of the allocated memory
        add rdi, rax                            ; get to the end of the timestamp (rax from timeval_to_ASCII)
        mov BYTE [rdi], 10                      ; add linebreak after timestamp

        ; update the new writing address
        inc rdi                                 ; increment rdi to the start address of the next timestamp/diff
        mov [currentWritingAddress], rdi        ; store the current writing address in currentWritingAddress

        ; calculate difference
        mov rax, [timevalTwo + 8]               ; set rax to tv_usecTwo
        sub rax, [timevalOne + 8]               ; subtract tv_usecOne from tv_usecTwo
        jnc .positive_value                     ; jump if rax is positive
        add rax, 1000000                        ; negative rax -> add 1000000 to get positive value (does create CF too so sbb will work fine later on)

.positive_value:
        mov [timevalDiff + 8], rax              ; store the difference in tv_usecDiff

        mov rax, [timevalTwo]                   ; set rax to tv_secOne
        sbb rax, [timevalOne]                   ; subtract tv_secTwo from tv_secOne (with carry)
        mov [timevalDiff], rax                  ; store the difference in tv_secDiff

        ; difference is now in timevalDiff
        ; call short timeval_to_daystring(char *daystring, struct timeval *tv)
        mov rdi, [currentWritingAddress]        ; set daystring to the current address of the allocated memory
        mov rsi, timevalDiff                    ; set tv to timevalDiff

        call timeval_to_daystring               ; convert the difference to daystring

        ; add linebreak after daystring
        mov rdi, [currentWritingAddress]        ; set rdi to the start address of the allocated memory
        add rdi, rax                            ; get to the end of the daystring (rax from timeval_to_daystring)
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
        mov rcx, [outputAddress]                ; set start address of printing area
        mov rdx, [currentWritingAddress]        ; load current writing address into rdx
        sub rdx, [outputAddress]                ; subtract start address to get the amount of bytes to print
        int 80h
        jmp .exit

        ;------------------------------------------------------
        ; Jump Labels to call the Error handler
        ;------------------------------------------------------
.input_error:
        mov rdi, 0                              ; push idx of error Msg
        call displayError                       ; function call
        jmp .exit

.not_sorted_error:
        mov rdi, 1                              ; push idx of error Msg
        call displayError                       ; function call
        jmp .exit

.memory_error:
        mov rdi, 3                              ; push idx of error Msg
        call displayError                       ; function call
        jmp .exit

.error_max_timestamp:
        mov rdi, 4                              ; push idx of error Msg
        call displayError                       ; function call
        jmp .exit

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