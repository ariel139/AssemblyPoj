IDEAL
MODEL small
 
 



CODESEG


proc moveBluehammer
	mov [BmpLeft],180
	mov [BmpTop],110
	
	jmp @@start
@@load:
	
	call loadBuffer
@@start:
	push cx
	dec [BmpTop]
	dec [BufferTop]
	call copyBuffer
	call moveBlueHmmer
	call _200MiliSecDelay
	pop cx
	loop @@load
	
	ret
endp moveBluehammer

END