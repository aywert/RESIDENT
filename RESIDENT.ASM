.model tiny
.code
org 100h

start:      mov bx, 0b800h
            mov es, bx
            mov bx, 5*80*2 + 40*2
            mov ah, 13

Next:       in al , 60h
            mov es:[bx], ax
            cmp al, 1
            jne Next

            mov ax, 4c00h
            int 21h
String db "Fuck you, Nvidia!$"

end start