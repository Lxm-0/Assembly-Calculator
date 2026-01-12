

org 100h

jmp start

msg_menu        db 13,10,'===== MALAK ADVANCED CALCULATOR =====',13,10
                db '1. Arithmetic Calculator',13,10
                db '   (+, -, *, /, %, ^, # (sqrt))',13,10
                db '2. Convert Binary to Decimal/Hex',13,10
                db '3. Convert Hex to Decimal/Binary',13,10
                db '4. Exit',13,10
                db 'Choose option (1-4): $'

; Arithmetic calculator messages
msg_welcome     db 13,10,'Malak Calculator! Note: write operators like (2+1-5*1) then click enter:',13,10
                db 'Supported: +, -, *, /, %, ^ (power), # (square root)',13,10
                db 'Example: 3 + #16 * 2 or #9 + #16',13,10,'$'
msg_result      db 13,10,'Result: $'
msg_decimal     db 13,10,'  Decimal: $'
msg_binary      db 13,10,'  Binary:  $'
msg_hex         db 13,10,'  Hex:     $'
msg_error       db 13,10,'Error! Invalid expression.$'
msg_divzero     db 13,10,'Error! Division by zero.$'
msg_continue    db 13,10,13,10,'Press any key to return to menu...$'

; Conversion messages
msg_enter_bin   db 13,10,'Enter binary number (max 16 bits): $'
msg_enter_hex   db 13,10,'Enter hexadecimal number (max 4 digits): $'
msg_invalid     db 13,10,'Error! Invalid number format.$'

; Buffers
input_buffer    db 50 dup(0)
result          dw 0
temp_num        dw 0
digit_flag      db 0  ; Flag to track if we parsed at least one digit

; ==================== MAIN PROGRAM ====================
start:
    call clear_screen
    
main_menu:
    ; Display main menu
    mov dx, offset msg_menu
    mov ah, 9
    int 21h
    
    ; Get menu choice
    mov ah, 1
    int 21h
    
    ; Process menu choice
    cmp al, '1'
    je arithmetic_calc
    cmp al, '2'
    je bin_to_others
    cmp al, '3'
    je hex_to_others
    cmp al, '4'
    je program_exit
    
    ; Invalid choice
    jmp main_menu

program_exit:
    mov ax, 4C00h
    int 21h

; ==================== ARITHMETIC CALCULATOR ====================
arithmetic_calc:
    call clear_screen
    
    mov dx, offset msg_welcome
    mov ah, 9
    int 21h
    
    mov si, offset input_buffer
    call get_input
    
    call evaluate_expression
    jc arithmetic_error
    
    mov [result], ax
    

    mov dx, offset msg_result
    mov ah, 9
    int 21h
    

    mov dx, offset msg_decimal
    mov ah, 9
    int 21h
    mov ax, [result]
    call print_number
    

    mov dx, offset msg_binary
    mov ah, 9
    int 21h
    mov ax, [result]
    call print_binary
    

    mov dx, offset msg_hex
    mov ah, 9
    int 21h
    mov ax, [result]
    call print_hex
    

    call wait_key
    jmp start

arithmetic_error:

    call wait_key
    jmp start


evaluate_expression:
    mov si, offset input_buffer
    
    call skip_spaces
    
    mov al, [si]
    cmp al, '#'
    je parse_sqrt_first
    

    call parse_number
    jc eval_error
    push ax
    jmp eval_main_loop

parse_sqrt_first:
    ; Handle expressions starting with #
    inc si           ; Skip #
    call skip_spaces
    call parse_number
    jc eval_error
    call calculate_sqrt
    jc eval_error
    push ax
    jmp eval_main_loop

eval_main_loop:
    ; Skip spaces
    call skip_spaces
    
    mov al, [si]
    cmp al, 0
    je eval_done
    cmp al, 13
    je eval_done
    
    call get_operator
    jc eval_error
    mov bl, al       
    
   
    call skip_spaces
    
    
    mov al, [si]
    cmp al, '#'
    je handle_sqrt_operand
    

    call parse_number
    jc eval_error
    mov cx, ax
    jmp perform_operation

handle_sqrt_operand:
    
    inc si          
    call skip_spaces
    call parse_number
    jc eval_error
    call calculate_sqrt
    jc eval_error
    mov cx, ax       
    
perform_operation:

    pop ax
    
    cmp bl, '+'
    je do_add
    cmp bl, '-'
    je do_sub
    cmp bl, '*'
    je do_mul
    cmp bl, '/'
    je do_div
    cmp bl, '%'
    je do_mod
    cmp bl, '^'
    je do_power
    
    jmp eval_error

do_add:
    add ax, cx
    jo eval_overflow
    jmp push_result

do_sub:
    sub ax, cx
    jo eval_overflow
    jmp push_result

do_mul:
    imul cx
    jo eval_overflow
    jmp push_result

do_div:
    test cx, cx
    jz eval_divzero
    cwd
    idiv cx
    jmp push_result

do_mod:
    test cx, cx
    jz eval_divzero
    cwd
    idiv cx
    mov ax, dx      
    jmp push_result

do_power:
    
    call calculate_power
    jmp push_result

push_result:
    push ax         
    jmp eval_main_loop

eval_done:
    pop ax          
    clc
    ret

eval_error:
    mov dx, offset msg_error
    mov ah, 9
    int 21h
    stc
    ret

eval_overflow:
    mov dx, offset msg_error
    mov ah, 9
    int 21h
    stc
    ret

eval_divzero:
    mov dx, offset msg_divzero
    mov ah, 9
    int 21h
    stc
    ret

; Calculate power: AX ^ CX
calculate_power:
    push bx
    push cx
    push dx
    
    mov bx, ax      
    mov ax, 1       
    

    test cx, cx
    jz power_done
    
power_loop:
    imul bx         
    jo power_overflow
    loop power_loop
    
power_done:
    pop dx
    pop cx
    pop bx
    ret

power_overflow:
    pop dx
    pop cx
    pop bx
    stc
    ret

calculate_sqrt:
    push bx
    push cx
    push dx
    
    mov bx, ax
    
    test ax, ax
    jz sqrt_zero
    js sqrt_error   
    

    xor cx, cx      
    
sqrt_loop:
    inc cx          
    
    mov ax, cx
    mul cx          
    
    
    cmp ax, bx
    jbe sqrt_loop  
    

    dec cx
    mov ax, cx
    
sqrt_done:
    pop dx
    pop cx
    pop bx
    clc
    ret

sqrt_zero:
    xor ax, ax
    jmp sqrt_done

sqrt_error:
    pop dx
    pop cx
    pop bx
    stc
    ret

get_operator:
    mov al, [si]
    cmp al, '+'
    je valid_op
    cmp al, '-'
    je valid_op
    cmp al, '*'
    je valid_op
    cmp al, '/'
    je valid_op
    cmp al, '%'
    je valid_op
    cmp al, '^'
    je valid_op
    
    stc
    ret

valid_op:
    inc si         
    clc
    ret

; ==================== CONVERSION FUNCTIONS ====================
bin_to_others:
    call clear_screen
    

    mov dx, offset msg_enter_bin
    mov ah, 9
    int 21h
    
    mov si, offset input_buffer
    call get_input
    
    call parse_binary
    jc conversion_error
    
    mov [result], ax
    jmp display_all_conversions

hex_to_others:
    call clear_screen
    
    mov dx, offset msg_enter_hex
    mov ah, 9
    int 21h
    
    mov si, offset input_buffer
    call get_input
    
    call parse_hex
    jc conversion_error
    
    mov [result], ax

display_all_conversions:
    mov dx, offset msg_result
    mov ah, 9
    int 21h
    
    ; Display decimal
    mov dx, offset msg_decimal
    mov ah, 9
    int 21h
    mov ax, [result]
    call print_number
    
    ; Display binary
    mov dx, offset msg_binary
    mov ah, 9
    int 21h
    mov ax, [result]
    call print_binary
    
    ; Display hexadecimal
    mov dx, offset msg_hex
    mov ah, 9
    int 21h
    mov ax, [result]
    call print_hex
    
    call wait_key
    jmp start

conversion_error:
    mov dx, offset msg_invalid
    mov ah, 9
    int 21h
    call wait_key
    jmp start

parse_binary:
    push bx
    push cx
    push dx
    
    xor ax, ax
    xor cx, cx
    
parse_bin_loop:
    mov dl, [si]
    cmp dl, 0
    je parse_bin_done
    cmp dl, 13
    je parse_bin_done
    cmp dl, ' '
    je parse_bin_next
    
    cmp dl, '0'
    jb parse_bin_error
    cmp dl, '1'
    ja parse_bin_error
    
    sub dl, '0'
    
    ; Shift left and add bit
    shl ax, 1
    add al, dl
    
    inc si
    jmp parse_bin_loop

parse_bin_next:
    inc si
    jmp parse_bin_loop

parse_bin_done:
    clc
    jmp parse_bin_exit

parse_bin_error:
    stc

parse_bin_exit:
    pop dx
    pop cx
    pop bx
    ret

parse_hex:
    push bx
    push cx
    push dx
    
    xor ax, ax
    xor cx, cx
    
parse_hex_loop:
    mov dl, [si]
    cmp dl, 0
    je parse_hex_done
    cmp dl, 13
    je parse_hex_done
    cmp dl, ' '
    je parse_hex_next
    

    cmp dl, 'a'
    jb check_hex_digit
    cmp dl, 'f'
    ja check_hex_digit
    sub dl, 32     
    
check_hex_digit:
    cmp dl, '0'
    jb parse_hex_error
    cmp dl, '9'
    jbe hex_digit_parse
    cmp dl, 'A'
    jb parse_hex_error
    cmp dl, 'F'
    ja parse_hex_error
    
hex_digit_parse:

    cmp dl, '9'
    jbe hex_number
    sub dl, 'A' - 10
    jmp hex_add
    
hex_number:
    sub dl, '0'
    
hex_add:
    
    shl ax, 4
    add al, dl
    
    inc si
    jmp parse_hex_loop

parse_hex_next:
    inc si
    jmp parse_hex_loop

parse_hex_done:
    clc
    jmp parse_hex_exit

parse_hex_error:
    stc

parse_hex_exit:
    pop dx
    pop cx
    pop bx
    ret

; ==================== UTILITY FUNCTIONS ====================
clear_screen:
    mov ax, 3
    int 10h
    ret

get_input:
    ; Get input string, store at SI
    push si
    mov bx, si
    
input_loop:
    mov ah, 1
    int 21h
    
    cmp al, 13      
    je input_done
    
    cmp al, 8      
    je handle_backspace
    
    mov [si], al
    inc si
    jmp input_loop

handle_backspace:
    cmp si, bx      
    jbe input_loop  
    
    dec si
    ; Erase character on screen
    mov ah, 2
    mov dl, 8
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 8
    int 21h
    jmp input_loop

input_done:
    mov byte ptr [si], 0  
    pop si
    ret

wait_key:
    mov dx, offset msg_continue
    mov ah, 9
    int 21h
    
    mov ah, 1
    int 21h
    ret

skip_spaces:
    mov al, [si]
    cmp al, ' '
    jne skip_done
    inc si
    jmp skip_spaces
skip_done:
    ret

; Parse a number from string at SI - FIXED VERSION
parse_number:
    push bx
    push cx
    push dx
    
    xor ax, ax          ; Clear result
    mov [digit_flag], 0 ; Reset digit flag
    mov bx, 10          ; Base 10
    xor cx, cx          ; Clear sign flag (0 = positive, 1 = negative)
    
    mov dl, [si]
    cmp dl, '-'
    jne check_first_digit
    
    mov cx, 1           
    inc si
    
check_first_digit:
    mov dl, [si]
    cmp dl, '0'
    jb parse_no_digits
    cmp dl, '9'
    ja parse_no_digits
    
    mov [digit_flag], 1
    
parse_digit_loop:
    mov dl, [si]
    cmp dl, '0'
    jb parse_done
    cmp dl, '9'
    ja parse_done
    
    ; Convert digit to value
    sub dl, '0'
    
    ; Multiply current result by 10
    push dx
    mul bx
    pop dx
    
    ; Add the new digit
    add al, dl
    adc ah, 0
    
    inc si
    jmp parse_digit_loop

parse_done:
    ; Check if we parsed any digits
    cmp [digit_flag], 0
    je parse_error
    
    ; Apply sign if needed
    test cx, cx
    jz parse_success
    neg ax
    
parse_success:
    clc
    jmp parse_exit

parse_no_digits:
    ; If we had a minus sign but no digits, it's an error
    test cx, cx
    jz parse_error
    
    ; If we had "-" followed by non-digit, it's an error
    jmp parse_error

parse_error:
    stc

parse_exit:
    pop dx
    pop cx
    pop bx
    ret

; ==================== OUTPUT FORMATTING ====================
print_number:
    
    push ax
    push bx
    push cx
    push dx
    
    
    test ax, ax
    jns pos_num
    neg ax
    push ax
    mov dl, '-'
    mov ah, 2
    int 21h
    pop ax
    
pos_num:
    mov cx, 0
    mov bx, 10
    
div_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz div_loop
    
print_digits:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop print_digits
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

print_binary:
    ; Print number in AX as 16-bit binary
    push ax
    push cx
    push dx
    
    mov cx, 16
    
bin_loop:
    rol ax, 1
    push ax
    jc print_1
    mov dl, '0'
    jmp print_bit
    
print_1:
    mov dl, '1'
    
print_bit:
    mov ah, 2
    int 21h
    pop ax
    loop bin_loop
    
    pop dx
    pop cx
    pop ax
    ret

print_hex:
    
    push ax
    push cx
    push dx
    
    mov cx, 4
    
hex_loop:
    push cx
    mov cl, 4
    rol ax, cl
    pop cx
    
    push ax
    and ax, 0Fh
    
    cmp al, 10
    jb hex_print_digit
    add al, 'A' - 10
    jmp print_hex_char
    
hex_print_digit:
    add al, '0'
    
print_hex_char:
    mov dl, al
    mov ah, 2
    int 21h
    pop ax
    loop hex_loop
    
    pop dx
    pop cx
    pop ax
    ret

; ==================== END OF PROGRAM ====================