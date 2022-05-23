IDEAL
 

macro DEBUG_XY APARAM , BPARAM
	push ax
	mov ax,APARAM
	DEBUG_AX
	mov ax,BPARAM
	DEBUG_AX
	pop ax
endm

macro DEBUG_A_D APARAM , BPARAM, CPARAM, DPARAM
	push ax
	mov ax,APARAM
	DEBUG_AX
	mov ax,BPARAM
	DEBUG_AX
	mov ax,CPARAM
	DEBUG_AX
	mov ax,DPARAM
	DEBUG_AX
	pop ax
endm

macro DEBUG_X APARAM 
	push ax
	mov ax,APARAM
	DEBUG_AX
	pop ax
endm

macro PRINT_CHAR   CHAR
	push ax
	push dx
	mov dl,CHAR
	mov ah,2
	int 21h
	mov dl,' '
	int 21h
	pop dx
	pop ax
endm

macro PRINT_STR STRPARAM
	push ax
	push dx
	mov dx, offset STRPARAM
	mov ah,9
	int 21h
	pop dx
	pop ax
endm

macro NEWLINE 
	push ax
	push dx
	mov dl,10
	mov ah,2
	int 21h
	mov dl,13
	int 21h
	pop dx
	pop ax
endm

macro INC_CNT_AND_STOP
	push ax
	PRINT_STR CounterMsg
	mov ax,[DEBUG_CNT]
	DEBUG_AX
	inc [DEBUG_CNT]
	mov ah,0
	int 16h
	 
	pop ax
endm



macro DELAY t1
	local lb1,lb2
	push cx
	
	mov cx,t1
lb1:
	push cx
	mov cx,10
lb2: loop lb2
	pop cx
	loop lb1
	pop cx
endm 
		


macro DEBUG_STOP
	push ax
	push dx
	mov dl,13
	mov ah,2
	int 21h
	mov ah,0
	int 16h
	pop dx
	pop ax
endm



; check if cx dx clicked on rectangle  
macro CHECK_CLICK x1,y1 , x2 ,y2
	local l1
	mov [IsInClick],0
	
	cmp cx,x1
	jb l1
 	
	cmp cx,x2
	jae l1
	
	cmp dx,y1
	jb l1
 	
	cmp dx,y2
	jae l1
	mov [IsInClick],1
l1:
endm


Macro absolute a
	local l1
	cmp a, 0
	jge l1
	neg a
l1:
Endm

macro DEBUG_AX
	push ax
	PRINT_CHAR 13
	call Show_Ax_Dec
	;call ShowAxHex
	PRINT_CHAR ' '
	
	pop ax

endm


MODEL small
	STACK 100h
DATASEG
	StartMsg db "Start", 10,13,'$'
	EndMsg db "End.", 10,13,'$'
	CounterMsg db 13,"  Counter:$"
	newline db 13,10,'$'
	DEBUG_CNT dw 0
	IsInClick db 0
	
CODESEG



;start:
	; mov ax, @data
	; mov ds, ax
	
	; PRINT_STR   StartMsg
	; inc [DEBUG_CNT]
	; mov cx, [DEBUG_CNT]
	; inc cx
    ; DEBUG_XY [DEBUG_CNT] , cx
	; inc [DEBUG_CNT]
    ; DEBUG_X [DEBUG_CNT]
	
	; NEWLINE
    ; PRINT_CHAR  'A'
	; mov cl , 'B'
	; PRINT_CHAR  cl
	
	; NEWLINE 
    ; PRINT_CHAR  'L'
	; PRINT_CHAR  'O'
	; PRINT_CHAR  'O'
	; PRINT_CHAR  'P'
	; NEWLINE 
	
	; mov cx, 5
	; mov [DEBUG_CNT],1
; again:
	
	; INC_CNT_AND_STOP
	; loop again
	
	; PRINT_STR EndMsg
	
; exit:
	; mov ax, 4c00h
	; int 21h
	
	

	
	
 
	
;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX  
;================================================
proc Show_Ax_Dec
	   push ax
       push bx
	   push cx
	   push dx
	   
	   push ax
	   
	   ; check if negative
	   test ax,08000h
	   jz @@PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
@@PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
@@put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg @@put_mode_to_stack

	   cmp ax,0
	   jz @@pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
@@pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop @@pop_next
		
	   mov dl, ','
       mov ah, 2h
	   int 21h
		
	  pop ax
	 
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp Show_Ax_Dec
 

proc ShowAxHex
	push ax
	push bx
	push cx
	push dx
	
	
	mov bx,ax
	mov cx,4
@@Next:
	
	mov dx,0f000h
	and dx,bx
	rol dx, 4          
	cmp dl, 9
	ja @@n1
	add dl, '0'
	jmp @@n2

@@n1:	 
	add dl, ('A' - 10)

@@n2:
	mov ah, 2
	int 21h
	shl bx,4
	loop @@Next
	
	mov dl,'h'
	mov ah, 2
	int 21h
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
endp ShowAxHex


     
