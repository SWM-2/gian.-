[org 0x7c00]
[bits 16]

xor di, di
xor ax, ax
mov ds, ax

;Load gian
mov si, DAPACK
mov ah, 0x42
int 0x13

push 0xB800
pop es
mov cx, 80*25
rep stosw

xor di, di
mov si, title
mov cx, 12
rep movsb

;gian execution
mov si, 0x8FF

gianloop:
    cmp si, 0x1000
    jg gianloop
    inc si
    mov al, [si]
    cmp al, 'g'
    je .rn
    cmp al, 'i'
    je parse_gian_a
    cmp al, 'a'
    je .pt

    jmp gianloop
    .rn:
        add byte [greg], 1
        jmp gianloop
    .pt:
        mov al, [greg]
        mov ah, 0x0E
        mov [es:di], ax
        add di, 2
        jmp gianloop
    
jmp $

parse_gian_a:
    mov dh, 0 ;Condition
    xor cx, cx
    mov ax, 0
    .condition_loop:
        inc si
        mov cl, [si]
        cmp [si], byte '+'
        je .cplus
        cmp [si], byte '-'
        je .cminus
        cmp [si], byte '.'
        je .tgt_loop_e

        mov dl, 10
        mul dl
        mov cl, [si]
        sub cl, 0x30
        add ax, cx
        jmp .condition_loop
    .cplus:
        mov dh, 1
        jmp .condition_loop
    .cminus:
        mov dh, 2
        jmp .condition_loop

    .tgt_loop_e:
    mov bx, ax
    xor ax, ax
    .tgt_loop:
        inc si
        cmp [si], byte '$'
        je .end

        mov dl, 10
        mul dl
        mov cl, [si]
        sub cl, 0x30
        add ax, cx
        jmp .tgt_loop
    .end:
        ;AX = Tgt
        ;BX = Test
        ;DH = Test
        mov cl, [gregb]
        test dh, 1
        jz .nop
            add cl, bl
            mov bl, cl
        .nop:
        test dh, 2
        jz .nom
            sub cl, bl
            mov bl, cl
        .nom:

        mov bh, [greg]

        cmp [greg], bl
        je .noinc
            add ax, 0x8FF
            mov si, ax
            jmp gianloop
        .noinc:
        mov bh, [greg]
        
        jmp gianloop

newline:
    mov ax, di
    mov dl, 160
    div dl
    mov al, 160
    sub al, ah
    xor ah, ah
    add di, ax
    ret

title: db "g",0x0E,"i",0x0E,"a",0x0E,"n",0x0E, "V", 0x0A, "1", 0x0B
DAPACK:
    db 0x10
    db 0
blkcnt: dw 1
db_add: dw 0x900
    dw 0
d_lba: dd 1
    dd 0

times 510-($-$$) db 0
greg:
db 0x55
gregb:
db 0xAA