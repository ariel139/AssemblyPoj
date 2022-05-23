IDEAL
MODEL small
 
 

STACK 0f500h

SCREEN_WIDTH = 320  
 

 
 


SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40



 
FILE_NAME_IN equ 'gamebg.bmp'


DATASEG


    ScrLine 	db SCREEN_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	PUBLIC FileName
	FileName 	db FILE_NAME_IN ,0
 
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ',FILE_NAME_IN, 0dh, 0ah,'$'
	ErrorFile           db 0
    BB db "BB..",'$'
	; array for mouse int 33 ax=09 (not a must) 64 bytes
	
	 
	 
	Color db ?
	Xclick dw ?
	Yclick dw ?
	Xp dw ?
	Yp dw ?
	SquareSize dw ?
	
	PUBLIC BmpLeft
	BmpLeft dw ?
	PUBLIC BmpTop 
	BmpTop dw ?
	PUBLIC BmpWidth
	BmpWidth dw ?
	PUBLIC BmpHeight
	BmpHeight dw ?
	giant db "E:/tasm/project/giant2/gianta16.bmp",0
	direction db ?
	tower db "E:/tasm/project/towers/tower.bmp",0
	
	PUBLIC BufferTop
	BufferTop dw ?
	PUBLIC BufferLeft
	BufferLeft dw ?
	Buffer db 35  dup('f')
	
CODESEG





;input [BufferTop] = y, [BufferLeft] = x, cx = how much to movwe
PUBLIC moveBlueGiant
proc moveBlueGiant
	mov [BmpLeft],180
	mov [BmpTop],130
	
	jmp @@start
@@load:
	call loadBuffer
@@start:
	dec [BmpTop]
	dec [BufferTop]
	call copyBuffer
	call MoveGiantBlue
	call _200MiliSecDelay
	loop @@load
	
	ret
endp moveBlueGiant


PUBLIC showBlueTowers
proc showBlueTowers
	mov [BmpTop], 130
	mov [BmpLeft],180
	mov [BmpWidth], 30
	mov [BmpHeight],39
	mov dx, offset tower
	call OpenTransBmp
	
	mov [BmpLeft],100
	mov dx, offset tower
	call OpenTransBmp
	
	ret
endp showBlueTowers

PUBLIC showTowersFacesBlue
proc showTowersFacesBlue
	
endp showTowersFacesBlue


PUBLIC showRedTowers
proc showRedTowers
	mov [BmpTop], 20
	mov [BmpLeft],180
	mov [BmpWidth], 30
	mov [BmpHeight],39
	mov dx, offset tower
	call OpenTransBmp
	
	mov [BmpLeft],100
	mov dx, offset tower
	call OpenTransBmp
	
	ret
endp showRedTowers

PUBLIC _200MiliSecDelay
proc _200MiliSecDelay
	push cx
	
	mov cx ,1000 
@@Self1:
	
	push cx
	mov cx,600 

@@Self2:	
	loop @@Self2
	
	pop cx
	loop @@Self1
	
	pop cx
	ret
endp _200MiliSecDelay

PUBLIC copyBuffer
proc copyBuffer
	push es
	push ds
	push ax
	
	
	mov ax, ds
	mov es,ax
	mov ax,0a000h 
	mov ds,ax


	mov ax, [es:BufferTop]


	mov cx, ax
@@mul320:
	add ax,320
	loop @@mul320
	
	sub ax, [es:BufferTop]
	add ax, [es:BufferLeft]
	;di
	mov di,offset Buffer
	mov si,ax
	
	mov cx,20
@@cols:
	push cx
	mov cx, 20
	rep movsb
	pop cx
	add si,320
	sub si,20
	loop @@cols
	
	pop ax
	pop ds
	pop es
	ret
endp copyBuffer


PUBLIC loadBuffer
proc loadBuffer
	push ax
	
	mov si, offset Buffer

	mov ax, 0a000h
	mov es,ax
	
	mov cx,[BufferTop]
	mov di,0
@@add320:
	add di,320
	loop @@add320
	add di, [BufferLeft]
	
	mov cx,20
@@cols:
	push cx
	
	mov cx,20
	rep movsb
	
	pop cx
	add di,320
	sub di,20
	loop @@cols
	pop ax
	ret
endp loadBuffer

PUBLIC MoveGiantBlue
proc MoveGiantBlue
	push ax
	push dx

	
	mov [BmpWidth],20
	mov [BmpHeight],20
	mov dx, offset giant
	
	mov al, [giant+30]
	cmp al,'6'
	je @@add
	cmp al,'7'
	je @@dec
@@add:
	inc al
	jmp @@run
@@dec:
	dec al
	
@@run:
	mov [giant+30], al
	call OpenTransBmp
	
	
	pop dx
	pop ax
ret	
endp MoveGiantBlue


public showBg
proc showBg
	mov dx, offset FileName
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320	
	mov [BmpHeight] ,200
	
	call OpenShowBmp	
	ret
endp showBg

proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

proc OpenTransBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowTransBMP
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenTransBmp

 
 
	
; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	mov al, 0
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile
 
 
 



proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette


 
 
proc DrawHorizontalLine	near
	push si
	push cx
DrawLine:
	cmp si,0
	jz ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	 
	
	inc cx
	dec si
	jmp DrawLine
	
	
ExitDrawLine:
	pop cx
    pop si
	ret
endp DrawHorizontalLine



proc DrawVerticalLine	near
	push si
	push dx
 
DrawVertical:
	cmp si,0
	jz @@ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	
	 
	
	inc dx
	dec si
	jmp DrawVertical
	
	
@@ExitDrawLine:
	pop dx
    pop si
	ret
endp DrawVerticalLine



; cx = col dx= row al = color si = height di = width 
proc Rect
	push cx
	push di
NextVerticalLine:	
	
	cmp di,0
	jz @@EndRect
	
	cmp si,0
	jz @@EndRect
	call DrawVerticalLine
	inc cx
	dec di
	jmp NextVerticalLine
	
	
@@EndRect:
	pop di
	pop cx
	ret
endp Rect



proc DrawSquare
	push si
	push ax
	push cx
	push dx
	
	mov al,[Color]
	mov si,[SquareSize]  ; line Length
 	mov cx,[Xp]
	mov dx,[Yp]
	call DrawHorizontalLine

	 
	
	call DrawVerticalLine
	 
	
	add dx ,si
	dec dx
	call DrawHorizontalLine
	 
	
	
	sub  dx ,si
	inc dx
	add cx,si
	dec cx
	call DrawVerticalLine
	
	
	 pop dx
	 pop cx
	 pop ax
	 pop si
	 
	ret
endp DrawSquare




 
PUBLIC SetGraphic
proc  SetGraphic near
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

proc ShowTransBMP near
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
 
	mov ax,[BmpWidth] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	mov bp, 0
	and ax, 3
	cmp ax, 0 
	jz @@row_ok
	mov bp,4
	sub bp,ax

@@row_ok:	
	mov cx,[BmpHeight]
    dec cx
	add cx,[BmpTop] ; add the Y on entire screen
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	add di,[BmpLeft]
	cld ; Clear direction flag, for movsb forward
	
	mov cx, [BmpHeight]
@@NextLine:
	push cx
 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpWidth]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory es:di
	mov cx,[BmpWidth]  
	mov si,offset ScrLine
@@draw:
	cmp [byte ptr si], 0ffh
	je @@trans
	movsb
	jmp @@end
@@trans:
	inc di
	inc si
	
	
@@end:
	loop @@draw
	
	rep  ; Copy line to the screen


	sub di,[BmpWidth]            ; return to left bmp
	sub di,SCREEN_WIDTH  ; jump one screen line up
	
	pop cx
	loop @@NextLine
	
	pop cx
	ret

endp ShowTransBMP

 
 
proc ShowBMP near
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpHeight lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
 
	mov ax,[BmpWidth] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	mov bp, 0
	and ax, 3
	cmp ax, 0 
	jz @@row_ok
	mov bp,4
	sub bp,ax

@@row_ok:	
	mov cx,[BmpHeight]
    dec cx
	add cx,[BmpTop] ; add the Y on entire screen
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	add di,[BmpLeft]
	cld ; Clear direction flag, for movsb forward
	
	mov cx, [BmpHeight]
@@NextLine:
	push cx
 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpWidth]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory es:di
	mov cx,[BmpWidth]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	sub di,[BmpWidth]            ; return to left bmp
	sub di,SCREEN_WIDTH  ; jump one screen line up
	
	pop cx
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP


 
 


 


proc ShowAxDecimal near
       push ax
	   push bx
	   push cx
	   push dx
	   jmp PositiveAx
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
	   mov dl, ','
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   ret
endp ShowAxDecimal




END