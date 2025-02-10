determinant_sarrus_new:

org 100h

jmp begin

msg_inp db "Enter 9 elements of the matrix in the following order: x1 x2 x3 x4 x5 x6 x7 x8 x9", 0Dh, 0Ah, "$"
msg_out db 0Dh, 0Ah, "Determinant: $"
msg_end db 0Dh, 0Ah, "Press any key to exit...$"
newl db 0Dh, 0Ah, "$" 

; --- matrix storage -----
mat_data dw 9 dup(?)
; -----------------------

det_val dw 0

begin:
    mov dx, offset msg_inp
    mov ah, 9
    int 21h
    
    mov cx, 9
    mov di, 0
input_loop:
    call get_number
    mov mat_data[di], bx
    
    mov dx, offset newl
    mov ah, 9
    int 21h
    
    add di, 2
    loop input_loop
    mov di, 0
    mov ax, mat_data[di]    ; x1
    mov di, 8
    mul mat_data[di]        ; x9
    mov di, 16
    mul mat_data[di]        ; x6
    
    add det_val, ax
    xor ax, ax
    
    mov di, 2
    mov ax, mat_data[di]    ; x4
    mov di, 10
    mul mat_data[di]        ; x2
    mov di, 12
    mul mat_data[di]        ; x8
    
    add det_val, ax
    xor ax, ax
    
    mov di, 4
    mov ax, mat_data[di]    ; x7
    mov di, 6
    mul mat_data[di]        ; x5
    mov di, 14
    mul mat_data[di]        ; x3
    
    add det_val, ax
    xor ax, ax
    
    mov di, 4
    mov ax, mat_data[di]    ; x7
    mov di, 8
    mul mat_data[di]        ; x6
    mov di, 12
    mul mat_data[di]        ; x2
    
    sub det_val, ax
    xor ax, ax             
    
    mov di, 2
    mov ax, mat_data[di]    ; x4
    mov di, 6
    mul mat_data[di]        ; x5
    mov di, 16
    mul mat_data[di]        ; x9
    
    sub det_val, ax
    xor ax, ax             
    
    mov di, 0
    mov ax, mat_data[di]    ; x1
    mov di, 10
    mul mat_data[di]        ; x8
    mov di, 14
    mul mat_data[di]        ; x3
    
    sub det_val, ax
    xor ax, ax
    
    mov dx, offset msg_out
    mov ah, 9
    int 21h
    
    mov ax, det_val
    call print_number

    mov dx, offset msg_end
    mov ah, 9
    int 21h
    mov ah, 0
    int 16h
    
    mov ax, 4C00h
    int 21h    
    
ret

get_number PROC NEAR
    PUSH DX
    PUSH AX
    PUSH SI
    
    MOV BX, 0
    MOV CS:neg_flag, 0

read_digit:

    MOV AH, 00h
    INT 16h
    MOV AH, 0Eh
    INT 10h

    CMP AL, '-'
    JE set_neg

    CMP AL, 0Dh
    JNE not_enter
    JMP finish_input
not_enter:

    CMP AL, '0'
    JAE valid_input
    JMP ignore_invalid
valid_input:        
    CMP AL, '9'
    JBE valid_digit
ignore_invalid:       
    PUTC 8    
    PUTC ' '  
    PUTC 8     
    JMP read_digit       
valid_digit:

    PUSH AX
    MOV AX, BX
    MUL CS:decimal_const
    MOV BX, AX
    POP AX

    CMP DX, 0
    JNE overflow_check

    SUB AL, 30h

    MOV AH, 0
    ADD BX, AX

    JMP read_digit

set_neg:
    MOV CS:neg_flag, 1
    JMP read_digit

overflow_check:
    MOV BX, DX  
    MOV DX, 0  
overflow_cleanup:
    MOV AX, BX
    DIV CS:decimal_const  
    MOV BX, AX
    PUTC 8     
    PUTC ' '  
    PUTC 8    
    JMP read_digit
        
finish_input:
    CMP CS:neg_flag, 0
    JE not_negative
    NEG BX
not_negative:

    POP SI
    POP AX
    POP DX
    RET
neg_flag  DB ?
get_number ENDP

PUTC MACRO char
    PUSH AX
    MOV AL, char
    MOV AH, 0Eh
    INT 10h     
    POP AX
ENDM

print_number PROC NEAR
    PUSH DX
    PUSH AX

    CMP AX, 0
    JNZ not_zero

    PUTC '0'
    JMP printed

not_zero:
    CMP AX, 0
    JNS positive
    NEG AX

    PUTC '-'

positive:
    CALL print_unsigned
printed:
    POP AX
    POP DX
    RET
print_number ENDP

print_unsigned PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 1
    MOV BX, 10000       

    CMP AX, 0
    JZ print_zero

start_print:

    CMP BX, 0
    JZ end_print

    CMP CX, 0
    JE calc_step
    CMP AX, BX
    JB skip_digit
calc_step:
    MOV CX, 0

    MOV DX, 0
    DIV BX  

    ADD AL, 30h    
    PUTC AL

    MOV AX, DX  

skip_digit:
    PUSH AX
    MOV DX, 0
    MOV AX, BX
    DIV CS:decimal_const  
    MOV BX, AX
    POP AX

    JMP start_print
        
print_zero:
    PUTC '0'
        
end_print:

    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_unsigned ENDP

decimal_const DW 10