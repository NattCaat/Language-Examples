; Running the program
; This program has been written in x86 assembly 64-bit mode and gets assembled 
; with the Netwide Assembler (NASM) to finally get linked with the GNU linker (ld)
;  ________________________________________________
; |                                                |
; | $ nasm -f elf64 -o calc1.o calc1.asm           |
; | $ ld -m elf_x86_64 -o calc1 calc1.o            |
; |________________________________________________|
; That gives you the executable "calc1"
;
; IMPORTANT! 
; - This program uses Linux interrupts, so it probably won't work on other operation systems
; - The x86 assembly language has been used, so it will only work on devices based on x86 architecture, don't even try it on ARM devices

; _____________________________________________________________________________

; calculator version
%define VERSION '1.0'

; define system states
SYS_EXIT    equ 0x01
SYS_READ    equ 0x03
SYS_WRITE   equ 0x04
STDIN       equ 0x00
STDOUT      equ 0x01

; define ANSI escape codes
%define END     0x1b, '[0m'
%define BOLD    0x1b, '[1m'
%define UNDERL  0x1b, '[4m'
%define RED     0x1b, '[31m'
%define GREEN   0x1b, '[32m'
%define YELLOW  0x1b, '[33m'
%define PURPLE  0x1b, '[35m'
; move cursor to home and erase screen
%define CLEAR   0x1b, '[H', 0x1b, '[2J', 0x1b, '[3J'

; display string on terminal with system write call
; usage: printString stringStart, len
%macro printString 2
    mov rax, SYS_WRITE
    mov rbx, STDOUT
    mov rcx, %1
    mov rdx, %2
    int 0x80
%endmacro

; get input with system read call
; usage: readString storeLocation, len
%macro readString 2
    mov rax, SYS_READ
    mov rbx, STDIN
    mov rcx, %1
    mov rdx, %2
    int 0x80
%endmacro

; print input prompt and get user input and transform it to base-16 number
; usage: getInput
%macro getInput 0
    printString inputStr, inputStr.len
    mov qword[input+8], 0x00
    mov qword[input], 0x00
    readString input, 0x10
    printString newline, newline.len
    push qword[input+8]
    push qword[input]
    call _readNumber
    add rsp, 0x10
%endmacro

; swap two values with help of arithmetic operations
; usage: swap val1, val2
%macro swap 2
    add %1, %2
    sub %2, %1
    add %1, %2
    xor %2, 0xffffffffffffffff
    inc %2
%endmacro

; _____________________________________________________________________________
section .data
; this section contains text needed by the program 
    ; CLI text
    interface:
        db BOLD, UNDERL, 'x86_64 NASM Assembly CLI calc V', VERSION, END, 0x0a, 0x0a
        db 'Choose a ', PURPLE, 'function', END, ':', 0x0a
        db GREEN, '1', END, ' - ', PURPLE, 'Add          '
        db GREEN, '3', END, ' - ', PURPLE, 'Multiply     '
        db GREEN, '5', END, ' - ', PURPLE, 'Exponentation', 0x0a
        db GREEN, '2', END, ' - ', PURPLE, 'Subtract     '
        db GREEN, '4', END, ' - ', PURPLE, 'Divide       '
        db GREEN, '6', END, ' - ', PURPLE, 'Quit         ', END, 0x0a
        .len: equ $ - interface

    ; template operation information
    ; usage: data_opStr 'function', 'symbol'
    %macro data_opStr 2
        db 'You chose: ', PURPLE, %1, END, 0x0a
        db 'Please choose two numbers ', GREEN, 'a', END,' and ', GREEN,'b', END,' to calculate '
        db GREEN, 'a', PURPLE, %2, GREEN, 'b', END, 0x0a
    %endmacro
    addStr:
        data_opStr 'Addition', '+'
        .len: equ $ - addStr
    subStr:
        data_opStr 'Subtraction', '-'
        .len: equ $ - subStr
    mulStr:
        data_opStr 'Multiplication', '*'
        .len: equ $ - mulStr
    divStr:
        data_opStr 'Division', '/'
        .len: equ $ - divStr
    expStr:
        data_opStr 'Exponentation', '^'
        db YELLOW, 'Note: ', END, 'If ', GREEN, 'b', END, ' < 0, the result gets displayed as '
        db BOLD, '0 R ', GREEN, BOLD, 'a', PURPLE, BOLD, '^', GREEN, BOLD, 'b', END, 0x0a
        .len: equ $ - expStr

    ; messages, warnings and errors
    enterRestart:
        db 'Press Enter to restart...', 0x0a
        .len: equ $ - enterRestart
    modeError:
        db BOLD, '[', RED, BOLD, 'ERROR', END, BOLD, '] ', END
        db 'Please only enter whole numbers between ', GREEN, '1', END, ' and ', GREEN, '6', END, 0x0a
        .len: equ $ - modeError
    numberOF:
        db BOLD, '[', YELLOW, BOLD, 'WARNING', END, BOLD, '] ', END
        db 'Result approaches ', BOLD, 'infinity',END, 0x0a
        .len: equ $ - numberOF
    exitMes:
        db 'Exiting program...', 0x0a
        .len: equ $ - exitMes

    ; miscellaneous words
    clearScreen:
        db CLEAR
        .len: equ $ - clearScreen
    newline:
        db 0x0a
        .len: equ $ - newline
    inputStr:
        db GREEN, '>>> ', END
        .len: equ $ - inputStr
    resultStr:
        db 'Result: ', BOLD
        .len: equ $ - resultStr
    endStr:
        db END, 0x0a
        .len: equ $ - endStr
    restStr:
        db ' R '
        .len: equ $ - restStr

; _____________________________________________________________________________
section .bss
    ; used to store user input
    input:      resq 2
    ; stores label of function operator
    mode:       resq 1
    ; store remainder of divisions
    remainder:  resq 1
    ; allows to easily print digits with help of macro printString
    digit:      resb 1
    ; scratch bool, it can store up to 8 conditional states
    bool:       resb 1

; _____________________________________________________________________________
section .text
    ; declaration for linker (gcc)
    global _start

    ; arithmetic functions ____________________________________________________

    ; get absolut the absolut value and tell if if the input value was negative
    ; parameters: value
    ; return values:
    ;   accumulator: absolut value
    ;   data register: 0 if value was positive, 1 if value was negative
    _absolut:
        push rbp
        mov rbp, rsp
        ; set accumulator to value and data register to 0
        mov rax, qword[rbp+0x10]
        mov rdx, 0x00
        ; check if value is less than 0
        cmp rax, 0x00
        jnl __absolut_end
            ; get opposite sign of accumulator by using 2's complement
            xor rax, 0xffffffffffffffff
            inc rax
            ; set data register to 1
            mov rdx, 0x01
        __absolut_end:
        mov rsp, rbp
        pop rbp
        ret

    ; add two values a and b
    ; parameters: a, b
    ; return values:
    ;   accumulator: a + b
    _addition:
        push rbp
        mov rbp, rsp
        mov rax, qword[rbp+0x18]
        add rax, qword[rbp+0x10]
        mov rdx, 0x00
        mov rsp, rbp
        pop rbp
        ret

    ; subtract value b from value a
    ; parameters: a, b
    ; return values:
    ;   accumulator: a - b
    _subtraction:
        push rbp
        mov rbp, rsp
        mov rax, qword[rbp+0x18]
        sub rax, qword[rbp+0x10]
        mov rdx, 0x00
        mov rsp, rbp
        pop rbp
        ret

    ; multiply values a and b
    ; parameters: a, b
    ; return values:
    ;   accumulator: a * b
    _multiplication:
        push rbp
        mov rbp, rsp
        mov rax, qword[rbp+0x18]
        imul qword[rbp+0x10]
        mov rdx, 0x00
        mov rsp, rbp
        pop rbp
        ret

    ; divide b through a
    ; parameters: a, b
    ; return values:
    ;   accumulator: quotient
    ;   data register: remainder
    _division:
        push rbp
        mov rbp, rsp
        ; set overlow flag and skip function, if divisor is 0
        cmp qword[rbp+0x10], 0x00
        jne __division_skipZeroDivision
            pushf
            or word[rsp], 0x0800
            popf
            jmp __division_end
        __division_skipZeroDivision:
        ; get absolute value of dividend
        push qword[rbp+0x18]
        call _absolut
        add rsp, 0x08
        ; change sign of divisor, if dividend was negative
        cmp rdx, 0x00
        je __division_skipMinus
            xor qword[rbp+0x10], 0xffffffffffffffff
            inc qword[rbp+0x10]
        __division_skipMinus:
        ; signed division
        mov rdx, 0x00
        idiv qword[rbp+0x10]
        __division_end:
        mov rsp, rbp
        pop rbp
        ret

    ; calculates a exponent b
    ; parameters: a, b
    ; return values:
    ;   accumulator: a^b if b >= 0
    ;   data register: a^b if b < 0
    _exponentation:
        push rbp
        mov rbp, rsp
        ; bool to check if exponent b is negative
        mov byte[bool], 0x00
        ; get absolute value of exponent
        push qword[rbp+0x10]
        call _absolut
        add rsp, 0x08
        mov byte[bool], dl
        ; move exponent into counter and store 1 inot accumulator
        mov rcx, rax
        mov rax, 0x01
        __exponentation_loop:
            ; if counter is 0, break loop
            cmp rcx, 0x00
            je __exponentation_division
            ; multiply accumulator by base
            imul qword[rbp+0x18]
            jo __exponentation_end
            ; decrease counter
            dec rcx
            jmp __exponentation_loop
        __exponentation_division:
        ; move accumulator into data register, if exponent was negative
        cmp byte[bool], 0x00
        je __exponentation_end
            mov rdx, rax
            mov rax, 0x00
        __exponentation_end:
        mov rsp, rbp
        pop rbp
        ret

    ; print and read number ___________________________________________________

    ; display number by iterating from highest order digit to lowest
    ; parameters: number
    ; return values: None
    _printNumber:
        push rbp
        mov rbp, rsp
        push qword[rbp+0x10]
        ; get absolute value of number
        call _absolut
        add rsp, 0x08
        cmp rdx, 0x00
        je __printNumber_skipMinus
            ; print '-' if number is negative
            push rax
            mov byte[digit], '-'
            printString digit, 0x01
            pop rax
        __printNumber_skipMinus:
        ; strore highest power of 10 in 64-bit mode into iterator
        mov rcx, 1000000000000000000
        ; bool to check if digit could be a NULL instead of 0
        mov byte[bool], 0x00
        ; print '0' if number is 0 and exit function
        cmp rax, 0x00
        jne __printNumber_loop
            mov byte[digit], '0'
            printString digit, 0x01
            jmp __printNumber_end
        __printNumber_loop:
            ; divide number by power of 10 to get digit
            mov rdx, 0x00
            div rcx
            ; store digit and push remainder and iterator on stack
            mov byte[digit], al
            push rdx
            push rcx
            ; the following block avoids outputs like '00034'
            ; check if digit could be a NULL
            cmp byte[bool], 0x00
            jne ___printNumber_loop_notNull
                ; if digit is equal to 0, it is a NULL -> skip print
                cmp byte[digit], 0x00
                je ___printNumber_loop_finalize
            ___printNumber_loop_notNull:
            ; when first digit gets displayed, it can no longer be NULL
            mov byte[bool], 0x01
            ; transform digit in its ascii code and display it
            add byte[digit], '0'
            printString digit, 0x01
            ___printNumber_loop_finalize:
            ; divide iterator by 10
            pop rax
            mov rcx, 0x0a
            mov rdx, 0x00
            div rcx
            mov rcx, rax
            ; pop remainder of first division of the loop into accumulator
            pop rax
            ; finish loop when iterator reaches 0
            cmp rcx, 0x00
            jne __printNumber_loop
        __printNumber_end:
        mov rax, 0x00
        mov rdx, 0x00
        mov rsp, rbp
        pop rbp
        ret

    ; translate ascii chars to base-16 number
    ; parameters: higerBits lowerBits
    ; return values:
    ;   accumulator: base-16 number 
    _readNumber:
        push rbp
        mov rbp, rsp
        ; in this function, scratch bool gets used to store two conditions:
        ;   lowest bit: higerBits has already been read
        ;   second lowest bit: base-16 return value is negative
        mov byte[bool], 0x00
        ; store lower bits into data register
        mov rdx, qword[rbp+0x18]
        rol rdx, 0x08
        ; store 0 into accumulator and counter, push multiple of ten on stack
        mov rax, 0x00
        mov rcx, 0x00
        push 0x01
        __readNumber_loop:
            ; check if char contains a digit 0-9
            cmp dl, '-'
            jne ___readNumber_loop_noMinus
                or byte[bool], 0x02
                jmp ___readNumber_loop_skip
            ___readNumber_loop_noMinus:
            cmp dl, '0'
            jl ___readNumber_loop_skip
            cmp dl, '9'
            jg ___readNumber_loop_skip
                ; save input string
                push rdx
                ; convert lowest order ascii char into base-16 digit
                and rdx, 0x00000000000000ff
                sub rdx, '0'
                ; multiply base-16 digit with multiple of 10
                swap rax, rdx
                push rcx
                mov rcx, qword[rsp+0x10]
                push rdx
                mul rcx
                pop rdx
                ; add base-16 digit * multiple of 10 to accumulator
                swap rax, rdx
                add rax, rdx
                ; multiply multiple of 10 with 10
                swap rax, qword[rsp+0x10]
                mov rcx, 0x0a
                mul rcx
                swap rax, qword[rsp+0x10]
                ; pop counter and input string back
                pop rcx
                pop rdx
            ___readNumber_loop_skip:
            ; rotate input string to left and increase counter
            rol rdx, 0x08
            inc rcx
            cmp rcx, 0x08
            jne __readNumber_loop
        ; check if higher bits has been read
        mov dl, 0x00
        add dl, byte[bool]
        and dl, 0x01
        cmp dl, 0x00
        jne __readNumber_checkSigne
            or byte[bool], 0x01
            ; store higher bits into data register
            mov rdx, qword[rbp+0x10]
            rol rdx, 0x08
            ; reset counter and enter loop again
            mov rcx, 0x00
            jmp __readNumber_loop
        __readNumber_checkSigne:
        ; check if there was a '-' in the ascii chars
        and byte[bool], 0x02
        cmp byte[bool], 0x00
        je __readNumber_end
            ; get opposite of number
            xor rax, 0xffffffffffffffff
            inc rax
        __readNumber_end:
        mov rdx, 0x00
        mov rsp, rbp
        pop rbp
        ret


    ; entry point of program __________________________________________________
    _start:
        __start_mainLoop:
            ; clear screen and display CLI
            printString clearScreen, clearScreen.len
            printString interface, interface.len
            getInput
            ; macro to check for the correct mode
            ; usage: start_checkMode modeNum, skipLabel, operationLabel, modeStr
            %macro start_checkMode 4
                ; check mode
                cmp rax, %1
                ; jump to skipLabel
                jne %2
                    ; store operationLabel into mode
                    mov qword[mode], %3
                    ; print message
                    printString %4, %4.len
                    ; correct mode found -> skip other checks
                    jmp ___start_mainLoop_valInput
            %endmacro
            cmp rax, 0x06
            ; jump to exit program
            je __start_end
            ; check for entered operation
            start_checkMode 0x05, ___start_mainLoop_noExp, _exponentation, expStr
            ___start_mainLoop_noExp:
            start_checkMode 0x04, ___start_mainLoop_noDiv, _division, divStr
            ___start_mainLoop_noDiv:
            start_checkMode 0x03, ___start_mainLoop_noMul, _multiplication, mulStr
            ___start_mainLoop_noMul:
            start_checkMode 0x02, ___start_mainLoop_noSub, _subtraction, subStr
            ___start_mainLoop_noSub:
            start_checkMode 0x01, ___start_mainLoop_noAdd, _addition, addStr
            ___start_mainLoop_noAdd:
            ; print error message and restart program, if user entered invalid mode
            printString modeError, modeError.len
            printString enterRestart, enterRestart.len
            readString input, 0x01
            jmp __start_mainLoop
            ___start_mainLoop_valInput:
            ; get a and b from user input and call stored operation
            getInput
            push rax
            getInput
            push rax
            call qword[mode]
            ; restart program, if overflow flag has been risen
            jno ___start_mainLoop_skipOF
                add rsp, 0x10
                printString numberOF, numberOF.len
                jmp ___start_mainLoop_end
            ___start_mainLoop_skipOF:
            add rsp, 0x10
            ; store remainder into reserved location
            mov qword[remainder], rdx
            ; print number
            push rax
            printString resultStr, resultStr.len
            call _printNumber
            add rsp, 0x08
            ; print remainder, if it is not equal to 0
            cmp qword[remainder], 0x00
            je ___start_mainLoop_end
                printString restStr, restStr.len
                push qword[remainder]
                call _printNumber
                add rsp, 0x08
            ___start_mainLoop_end:
            ; print restart prompt and wait for enter
            printString endStr, endStr.len
            printString newline, newline.len 
            printString enterRestart, enterRestart.len
            readString input, 0x01
            ; restart loop
            jmp __start_mainLoop
        __start_end:
        ; exit program
        printString exitMes, exitMes.len
        mov rax, SYS_EXIT
        mov rbx, STDIN
        int 0x80