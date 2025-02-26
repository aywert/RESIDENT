.model tiny
.code
org 100h

start:     
;----------------------------------------------------------------------------
;                           SETTING OF NEW 09 INTERRAPTION
;----------------------------------------------------------------------------
            xor ax, ax                  ; ax = 0000
            mov es, ax                  ; es = address of interruptions table in RAM 
            mov bx, 09h * 4             ; colculate address of New09 int

            mov ax, es:[bx]
            mov Old09RelAdrs, ax
            mov ax, es:[bx+2]
            mov Old09Segment, ax

            жint 09h                     ; calls old 9th interruptions

            cli                         ; resctiction to operate interruptions
            mov es:[bx], offset New09
            push cs
            pop  ax
            mov es:[bx+2], ax           ; segment address in th interruotion table
            sti                         ; permision to operate interruptions
            
            int 09h 

            mov ah, 31h
            mov dx, offset End_Of_Programm
            shr dx, 4
            inc dx
            int 21h

            
            ;mov bx, 0b800h
            ;mov es, bx
            ;mov bx, 5*80*2 + 40*2
            ;mov ah, 13
;---------------------------------------------------------------------------
;                               DRAW FRAME
;---------------------------------------------------------------------------
            ;mov si, offset StyleStr ;mov si, offset StyleStr

            ;mov bx, 0b800h
            ;mov es, bx
            ;call CntStartPosition
            ;mov ah, Color_style
        
            ;call DrawFrame
;---------------------------------------------------------------------------
New09       proc 
        ;mov ax, 1111h
        ;mov bx, 2222h
        ;mov cx, 3333h
        ;mov dx, 4444h
        ;mov es, 5555h
        ;mov si, 6666h
        ;mov ax, 1111h
        ;mov di, 7777h
        push ax
        push bx
        push cx
        push dx
        push es
        push si
        push ds
        push di
        
        ;push bp
        ;CX SI DI AX BX BP

        push cs
        pop ds

        mov ax, 0b800h
        mov es, ax
        mov ah, 4eh
        ;mov bx, 5*80*2 + 40*2

        in al, 60h
        cmp al, 58h
        jne NOFRAME
            ;---------------------------------------------------------------------------
            ;                               DRAW FRAME
            ;---------------------------------------------------------------------------
            mov si, offset StyleStr ;mov si, offset StyleStr

            mov bx, 0b800h
            mov es, bx
            call CntStartPosition
    
            call DrawFrame
            mov ah, Color_style
            ;mov bx, 0FABCh
            ;call Print_value
            call PrintRegisters
            ;---------------------------------------------------------------------------
        NOFRAME:
        ;mov es:[bx], ax

        ;in al, 61h
        ;mov ah, al
        ;or al, 80h
        ;out 61h, al
        ;mov al, ah
        ;out 61h, al

        ;mov al, 20h
        ;out 20h, al
        ;pop bp
        
        pop di
        pop ds
        pop si
        pop es
        pop dx
        pop cx
        pop bx
        pop ax

        db 0eah 
        Old09RelAdrs dw 0
        Old09Segment dw 0
        ;mov ax, 4c00h
        ;int 21h

        ;ret 
        endp








                                ;STUFF RELATED TO FRAME
;---------------------------------------------------------------------------------------------------
;---------------------------------------------------------------
;DrawFrame - draws a frame in video memory and print given string in the center
;Entry: SI - address of StyleString
;       ES - address og the video memory
;       DI - position of the beggining of the frame
;       AH - color attributes
;Exit:  None
;Destr: CX SI DI AX BX BP
;---------------------------------------------------------------
DrawFrame proc 
        xor ax, ax
        xor bx, bx
        xor dx, dx
        xor cx, cx
        mov ah, Color_style
        call DrawStr                            ;Print the first string

        xor cx, cx
        mov cx, Height
        sub cx, 2                               ;cx = Height - 2

        ;TODO: function that do this fignia
        Cycle:                                  ;Print middle strings
                call DrawStr
                sub si, 3
        loop Cycle

        add si, 3
        call DrawStr                            ;Print the last string

        ;call CntStringPosition                  ;mov di, (Begin_Y + Height/2 - 1)*80*2 + 2*(Begin_X + Len/2 - 1)
                                                
        ;mov si, offset String
        ;call CntLenString                       ;AX = lengths

        ;push ax                                 
        ;shr ax, 1
        ;shl ax, 1
        ;sub di, ax                              ;shifting DX on length/2
        ;pop ax
        
        ;call DrawRdmString

        ret 
        endp
        

;---------------------------------------------------------------
;DrawStr - draws a string according to a StyleString
;Entry: DS:[SI] - address of the begining of the style 
;       DI - relative address where to print first symbol
;       AH - color attributes
;Exit:  None
;Destr: DI AL SI
;---------------------------------------------------------------
DrawStr proc
        push cx   
        lodsb                           ;mov al, ds:[si]
                                        ;inc si
        stosw                           ;печатаю первый символ 3 байтовой последовательности 
        
        mov al, ds:[si]
        mov cx, Len
        sub cx, 2                       ;cx = Len - 2
                       
        rep stosw                       ;печатаю последовательность из второго символа len-2 раза
        
        inc si
        lodsb                           ;mov al, ds:[si]
                                        ;inc si
        stosw                           ;печатаю последний символ 3 байтовой последовательности
        
        pop cx

        mov bx, Len
        shl bx, 1
        mov dx, 160
        sub dx, bx
        add di, dx                      ;add di, 160 - 2*Len
        ret 
        endp

;---------------------------------------------------------------
;DrawRdmString - draws a given string in video memory
;Entry: AX - length of the string
;       SI - relative address of the string
;Exit:  None
;Destr: SI AX CX 
;---------------------------------------------------------------
DrawRdmString proc  
        mov cx, ax
    metkaRS:
        mov ax, [si]
        mov ah, Color_style
        stosw
        inc si
        loop metkaRS
        ret 
        endp

;---------------------------------------------------------------
;CntLenString - counts(without $) number of symbols in the given string 
;Entry: AH = color attributes
;Exit:  None
;Destr: AX BX CX
;---------------------------------------------------------------
CntLenString proc
        push si
        mov cx, 0
        mov ax, -1
    metkaCLS:
        mov cx, [si]
        sub cl, 35
        mov ch, 0
        inc si
        inc ax
        loop metkaCLS
        pop si
        ret 
        endp

;---------------------------------------------------------------
;CntStartPosition - counts the position where to start frame
;Enter: 
;Exit: DI - result of operation
;Destr: AX BX DI
;---------------------------------------------------------------
CntStartPosition proc           ;(Begin_Y-1)*80*2 + (Begin_X-1)*2

        mov ax, Begin_Y                 ;mov ax, [offset Begin_Y]
        dec ax
        mov bx, 160
        mul bx
        
        mov bx, Begin_X                 ;mov bx, [offset Begin_X]
        dec bx
        shl bx, 1
        add ax, bx
        mov di, ax
        ret

        endp


;----------------------------------------------------------------
;INT to ACSII - prints number
;Enter: AX - number to print
;Exit :
;Destr: DI SI CX
;----------------------------------------------------------------
PrintRegisters    proc

        call CntStartPosition
        add di, 2*2 + 80*2*2 
        mov si, offset RegisterString

        mov bx, sp
        add bx, 18 
        mov cx, num_of_registers ; Number 0f registers
PrintCycle:
        sub bx, 2
        
        
        ;mov dx, bx
        ;mov al, 09h
        ;int 21h
        call PrintStrReg

        mov dx, ss:[bx]

        call Print_value
        add di, 142

       loop PrintCycle


        ret

        endp

;-----------------------------------------------------------------
;PrintStrReg
;enter: AL - number to translate 
;exit:  AL - value  to print
;-----------------------------------------------------------------
PrintStrReg proc
        push cx
        mov cx, num_of_elements
        mov ah, Color_style
        PRINT_REGISTER:                         ;|prints: "ax = "
                lodsb                           ;|
                stosw                           ;|
        loop PRINT_REGISTER
        pop cx

        ret
        endp
;-----------------------------------------------------------------
;INT to ACSII
;enter: AL - number to translate 
;exit:  AL - value  to print
;-----------------------------------------------------------------
int_to_acsii proc
        mov ah, Color_style
        cmp al, 10
        js DIGIT
        sub al, 10
        add al, 'A'
        
        jmp SKIP
        DIGIT:
        add al, '0'
        
        SKIP:

        ret
        endp

;-----------------------------------------------------------------
;Print_value
;enter: BX - value 
;exit:
;Destr:
;-----------------------------------------------------------------
Print_value proc
        

        mov ax, dx
        and ah, 0F0h
        shr ah, 4
        mov al, ah
        ;mov ah, Color_style
        call  int_to_acsii
        stosw

        mov ax, dx
        and ah, 0Fh
        mov al, ah
        ;mov ah, Color_style
        call int_to_acsii
        stosw

        mov ax, dx
        shr al, 4
        call int_to_acsii
        stosw

        mov ax, dx
        ;mov ah, Color_style
        and al, 0Fh
        ;shr al, 4
        call int_to_acsii
        stosw

        ret
        endp
;---------------------------------------------------------------
;CntStartPosition - counts the position where to start frame
;Enter: 
;Exit: DI - result of operation
;Destr: AX BX
;---------------------------------------------------------------
        CntStringPosition proc ;(Begin_Y + Height/2 - 1)*80*2 + 2*(Begin_X + Len/2 - 1)
        ;(
        mov ax, Begin_Y
        dec ax
        
        mov bx, Height
        shr bx, 1
        add ax, bx
        mov bx, 160
        mul bx
        mov di, ax
        ;)

        ;+

        ;(
        mov ax, Begin_X
        dec ax
        
        mov bx, Len
        shr bx, 1
        add ax, bx
        shl ax, 1
        add di, ax
        ;)

        ret
        endp




.data 
AdrInStack dw 0
String db 'Hello its me$'
RegisterString db 'ax = bx = cx = dx = es = si = ds = di = $'
num_of_registers = 8
num_of_elements = 5
StyleStr db '1-1&^&7#7$'
Color_style db 01011010b
Begin_X    dw 16
Begin_Y    dw 5
Height     dw 16
Len        dw 26
Regym      dw 0

Space = 20h
Num_9 = 39h
Num_0 = 30h
End_Of_Programm:

end start
