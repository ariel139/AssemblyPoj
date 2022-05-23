IDEAL
MODEL compact



STACK 0f500h



SCREEN_WIDTH = 320


SMALL_BMP_HEIGHT = 40
SMALL_BMP_WIDTH = 40

include 'Macros.asm'
MACRO START_MOUSE
	mov ax,0
	int 33h
ENDM

MACRO SHOW_MOUSE
	mov ax,1
	int 33h
ENDM

MACRO HIDE_MOUSE
	mov ax,2
	int 33h
ENDM

;input :cx = x dx = y
;output: al = color
MACRO READ_PIXEL
	mov ah,0dh
	int 10h
ENDM


MACRO MOVE_MOUSE_TO_MIDDLE
	mov cx, 310
	mov dx, 100
	mov ax,4
	int 33h
ENDM

MACRO SET_MOUSE_BOUNDRIES_TO_MAP
	mov ax,7
	mov cx,216*2
	mov dx, 90*2
	int 33h
	mov ax, 8
	mov cx,25
	mov dx, 165
	int 33h
ENDM

MACRO UN_SET_MOUSE_BOUNDRIES_TO_MAP
	mov ax,7
	mov cx,0
	mov dx, 320*2
	int 33h
ENDM

MACRO GET_MOUSE_POSITION
	mov ax,3
	int 33h
ENDM

MACRO SET_MOUSE_POSTION_TO_CARDS
	mov cx, 510
	mov dx, 100
	mov ax,4
	int 33h
ENDM

MACRO ELIXER
	
	mov ah,2
	mov dh,0
	mov dl,5
	mov bh,0
	
	int 10h
	mov dl,[ElixerUser]
	mov ah,2
	int 21h

ENDM 
MACRO ASSUME_MAIN
	push ax
    ASSUME DS: main
    mov ax, main
    mov ds, ax
    pop ax
ENDM
MACRO ASSUME_MAP
	push ax
    ASSUME DS: mapArr
    mov ax, mapArr
    mov ds, ax
    pop ax
ENDM
MACRO ELIXERSENTENCE

	mov ah,9
	mov dx ,offset elixerSent
	int 21h
	
	ELIXER
	
ENDM
FILE_NAME_IN equ 'gamebg.bmp'



segment main

    ScrLine 	db SCREEN_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	FileName 	db FILE_NAME_IN ,0

	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	elixerSent db 'blop:','$'

	BmpFileErrorMsg    	db 'Error At Opening Bmp File ',FILE_NAME_IN, 0dh, 0ah,'$'
	ErrorFile           db 0
    BB db "BB..",'$'
	; array for mouse int 33 ax=09 (not a must) 64 bytes

	startGameImage db 'start.bmp',0
	RndCurrentPos dw start
	Color db ?
	Xclick dw ?
	Yclick dw ?
	Xp dw ?
	Yp dw ?
	lineWidth dw ?
	lineheight dw ?
	SquareSize dw ?
	playerdied db ?
	colorPlayer db ?
	xHit dw ?
	yHit dw ?
	selectORput db 0
	notOnline db 'notcon.bmp',0
	BmpLeft dw ?
	BmpTop dw ?
	BmpWidth dw ?
	BmpHeight dw ?
	direction db ?
	side db ?
	giant db 'xmenwB0.bmp',0 ;blue
	gianthitB db 'xmhitB0.bmp',0
	gianthitR db 'xmhitR0.bmp',0
	giantred db 'xmenrW0.bmp',0 ; red one
	tower db 'tower.bmp',0
	towerblue db 'bluet1.bmp',0
	towerRed db 'redt1.bmp',0
	bothOnline db ?
	giantCard db 'gbcard.bmp',0
	hammerCardi db 'amcard.bmp',0
	wrcard db 'wr.bmp',0
	wrriorBlue db 'warb0.bmp',0
	bluehammer db 'hamrb5.bmp',0
	towerType dw ?
	hitWrriorBim db 'wrab1.bmp',0
	hitWrriorRim db 'wrar1.bmp',0
	hitHamerBim db 'hamr0.bmp',0
	hitHammerR db 'rhmr1.bmp',0
	cardX dw ?
	cardY dw ?
	putten db 9
	DataFile db 'data.txt',0
	usersFile db 'users.txt',0
	availableFile db 'avl.txt',0
	player db 5 dup(?),0ah,0dh
	canceld db 0
	blue db 'B',0
	red db 'R',0
	towerdead db 1
	playerType db -1
	playerRead db ?
	takenStat db ?
	playerTypePut db 0
	redTowersLife dw 200,200
	blueTowersLife dw 200,200
	counter dw 0
	won db 0
	dead db 0
	takenIm db "taken.bmp",0
	ElixerUser db '0'
	ElixerBoot db 0
	stop db 0
	playersPositions dw 375 dup(?)
	positionIndexeder dw 0
	nearplayerIndex dw -1
	currentPlayerindex dw ?
	BufferTop dw ?
	BufferLeft dw ?
	Buffer db 20  dup('f')
	

ends

segment mapArr
	mapLeft dw ?
	mapTop dw ?
	widthB dw 20 ;default  value
	heightB dw 20 ;default  value
	map db 127*161 dup (0)
ends


CODESEG




start:
	mov ax, @data
	mov ds, ax



	call SetGraphic
		 ASSUME_MAIN

	call startGamei
	mov dx, offset FileName
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200

	call OpenShowBmp



	call showBlueTowers
	 call showRedTowers
	call showTowersFacesBlue
	 call showTowersFacesRed
	 call drawGiantCard
	 call hammerCard
	call wrriorCard
	call loadMap

	ELIXERSENTENCE
	SHOW_MOUSE

	call asyncMouseCard
	
mainLoop:
	call DrawPlayersArray
	call checkRedLeftTowerDown
	call checkRedRightTowerDown
	; call addElixer2
	; ELIXER
	call checkWinner
	cmp [won],0
	je mainLoop
	
	

	jmp exit

exitError:

	mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h


exit:
	

	

	mov ax,2
	int 10h
	
	mov dl, [won]
	mov ah,2
	int 21h
	
	mov ax, 4c00h
	int 21h



;==========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================
proc startGamei
	mov [BmpTop],0
	mov [BmpLeft],0
	mov [BmpWidth],320
	mov [BmpHeight],200
	mov dx, offset startGameImage
	call OpenShowBmp
	SHOW_MOUSE
@@looper:
	GET_MOUSE_POSITION
	shr cx,1 
	
	cmp bx, 2
	je exit
	cmp bx,1
	je @@next
	jmp @@looper
	@@next:
	HIDE_MOUSE
	ret
endp startGamei
proc addElixer
	cmp [counter],25

	jae @@checkNext
	jmp @@end
@@checkNext:
	mov ax, 1
	
	mov [counter],0
	cmp [ElixerUser],'0'+9
	jb @@add
	jmp @@end
@@add:
	inc [ElixerUser]	
	inc [ElixerBoot]
@@end:
	inc [counter]
	
ret
endp addElixer
proc addElixer2
	cmp [counter],50000

	je @@checkNext
	jmp @@end
@@checkNext:
	mov ax, 1
	
	mov [counter],0
	cmp [ElixerUser],'0'+9
	jb @@add
	jmp @@end
@@add:
	inc [ElixerUser]	
	inc [ElixerBoot]
@@end:
	inc [counter]
	
ret
endp addElixer2
proc boot 
	push cx
	cmp [ElixerBoot],'4'
	;jbe @@end
	
	mov dx,0
	mov ax, [positionIndexeder]
	mov cl,14
	div cl
	mov ah,0
	mov cx,ax
	cmp cx,0
	je @@end
@@DrawEnemy:
	; call addElixer
	; ELIXER
	je @@end
	;zzzz
	mov si, offset playersPositions
	mov ax,14
	mul cx
	add si,ax
	sub si,14
	push cx
	
	mov bx, [si+6]
	cmp bl, 'B'
	jne @@looper
	
	cmp [word si+14], 1
	je @@looper
	cmp [word si+4],127
	jbe @@left
	
	cmp [word si+4],161
	jae @@right
	jmp @@looper
@@left:
	mov cx, 161

	jmp @@cont	
@@right:	
	mov cx, 127

@@cont:	
	mov [ word si+14],1
	mov dx, 40
	push 'GR'
	call MovePosition
	
@@looper:
	pop cx
	loop @@DrawEnemy
@@end:
	pop cx
ret
endp boot
proc DrawPlayersArray
	mov dx,0
	mov ax, [positionIndexeder]
	mov cl,14
	div cl
	mov ah,0
	mov cx,ax
	cmp cx,0
	je @@ENDR
@@DrawPlayer:
	; call addElixer
	; ELIXER
	mov si, offset playersPositions
	mov ax,14
	mul cx
	add si,ax
	sub si,14

	mov dx, [si+4]
	mov ax,[si+2]
	mov bx, [si+6]
	;call makeTheDraw
	JMP @@NEXTER	
@@ENDR:
	JMP @@END
@@NEXTER:
	cmp bx,0
	je @@next

	push ax
	mov ax, [si+12]
	mov [currentPlayerindex],ax
	call checkIfplayerEnemynearForAll
	pop ax
	push cx
	cmp bl, 'R'
	je @@checkRed
	jmp @@cntw

@@lp:
	jmp @@DrawPlayer
@@cntw:
	call cheangeDirectionBasedOnLiveTowersForBlue
	jmp @@cont
@@checkRed:
	call cheangeDirectionBasedOnLiveTowersForRed
@@cont:
	;for x cord
	mov ax, [si+2]
	mov [BmpLeft],ax	

	;for y cord
	mov ax, [si+4]	
	mov [BmpTop],ax
	
	;for index	
	mov bx, [si+6]
	
	mov ax, [si+8]
	mov [direction],al
	
	call checkIfenemyTowerNear
	cmp [towerdead],0
	je @@looper
	
@@draw:

	call makeTheDraw
	call boot
@@looper:
	
	mov [towerdead],1
	call dodelaybyCx
	pop cx
	
@@next:
	loop @@lp

@@end:
	ret
endp DrawPlayersArray
proc makeTheDraw
	mov dx, [si+4]
	mov ax,[si+2]
	mov bx, [si+6]
	mov ax, [si+8]
	mov [direction],al
	call checkDirectionAndAct 
	
	call DrawPlayer
ret
endp makeTheDraw
;input = gets player index 
proc checkIfplayerEnemynearForAll
	push si
	push di
	push ax
	push bx 
	push cx
	;in di the player to check
	mov di, offset playersPositions
	add di, [currentPlayerindex]
	
	mov dx,0
	mov ax, [positionIndexeder]
	mov cl,14
	div cl
	mov ah,0
	mov cx,ax
	cmp cx,0
	je @@tohighJmpTOEnd
@@DrawPlayer:
	push cx
	mov si, offset playersPositions
	mov ax,14
	mul cx
	add si,ax
	sub si,14
	
	;other player index  = [si+12]

	;to check they not same
	mov ax, [di+12]
	mov dx,[si+12]
	cmp ax,dx
	je @@tohighJmpTocont

	;to check that parm not dead
	cmp [word di+10],0
	je @@tohighJmpTocont

	;to check that chcker not dead
	cmp [word si+10],0
	jl @@tohighJmpTocont

	jmp @@contproc1

@@tohighJmpTOEnd:
	jmp @@end

@@contproc1:
	jmp @@contproc2

@@tohighJmpTocont:
	jmp @@cont

@@contproc2:
	;to check they not same type
	mov bx, [di+6]
	mov dx, [si+6]
	cmp bx,dx
	je @@cont
	jmp @@cont3
@@loopback:
	jmp @@DrawPlayer
@@cont3:
	;to check closeness= y
	mov ax, [di+4]
	cmp bl, 'R'
	je @@add 
	cmp bl,'B'
	je @@dec
	jmp @@cont
@@dec :
	sub ax,18
	;PRINT_CHAR 'B'
	jmp @@comp
@@add:
	add ax,18
@@comp:
	cmp ax, [si+4]
	jne @@cont
	;to check closnes = x
	mov ax, [di+2]
	cmp ax, [si+2]
	jne @@cont

	;start hit
@@hit:
	mov ax, [di+2]
	mov dx, [di+4]
	mov [xHit],ax
	mov [yHit],dx
	mov bx, [di+6]
	xchg bl,bh
	call hitBasedOnPlayerTypeToenemy
	sub [word di+10],100
	cmp [word di+10],0
	jle @@medead
	cmp [word si+10],0
	jle @@himdead
	jmp @@conthit
@@medead:
	mov [word di+10],0
	mov [word di+6],0
	jmp @@cont
@@himdead:
	mov [word si+10],0
	mov [word si+6],0
	jmp @@cont
@@conthit:	
	call decOrAddByType
	
@@cont:
	pop cx
	loop @@loopback
@@end:
	pop cx
	pop bx
	pop ax
	pop di
	pop si
ret
endp checkIfplayerEnemynearForAll
proc decOrAddByType
	cmp bh ,'R'
	je @@red
	cmp bh, 'B'
	je @@blue
	jmp @@end
@@red:
	sub [word di+4],4
	add [word si+4],4
	jmp @@end
@@blue:
	add [word di+4],4
	sub [word si+4],4
@@end:
ret
endp decOrAddByType
proc dodelaybyCx
	push cx
	push ax
	push dx
	
	mov ax,1000
	xor dx,dx
	inc cx
	div cx
	mov cx, ax
	push cx
@@Self1:

	push cx
	mov cx,300

@@Self2:
	loop @@Self2

	pop cx
	loop @@Self1

	pop cx
	pop dx
	pop ax
	pop cx
	ret
endp dodelaybyCx

;input= currentPlayerindex- the index of player you want to check
proc checkifEnemyNearAndAct
	mov dx,0
	mov ax, [positionIndexeder]
	mov cl,10
	div cl
	mov ah,0
	mov cx,ax
	cmp cx,0
	je @@end
@@check:
	mov si, offset playersPositions
	mov ax,10
	mul cx
	add si,ax
	sub si,10
	
	;enemies index 
	mov bx, [si+6]
	cmp bl, 'B'
	je @@looper
	;for y position of enemy 
	mov ax, [si+4]
	mov di,offset playersPositions
	add di,[currentPlayerindex]
	cmp [di+4],ax
		
@@looper:
	loop @@check
	
	
@@end:
	ret	
endp checkifEnemyNearAndAct
;input = currentPlayerindex
;output = nearplayerIndex, if== -1 there is no player
proc checkIfenemyTowerNear
	;check the y
	cmp [word si+4], 40
	ja @@redAction	
	mov bx, [si+6]
	cmp bl, 'R'
	je @@redAction
	cmp bl, 'B'
	je @@BlueAction
	jmp @@end

@@redAction:

	jmp @@end

@@BlueAction:
	cmp [word si+2], 107
	jbe @@checkLeft
	cmp [word si+2], 181
	jae @@checkRight
	jmp @@end
@@checkLeft:
	call checkIfLeftRedTowerDown
	cmp [dead],1
	je @@chengeToDead
	jmp @@hitred

@@checkRight:

	call checkIfRightRedTowerDown
	cmp [dead],1
	je @@chengeToDead
	jmp @@hitred
	
@@hitred:
	xchg bl,bh
	mov dx, [si+4]
	mov ax, [si+2]
	mov [towerdead],0
	call hitBasedOnPlayerTypeToTowerBlue
	jmp @@end

@@chengeToDead:
	
	mov [towerdead],1
	
@@end:
	ret
endp checkIfenemyTowerNear
proc checkIfLeftRedTowerDown
	cmp [word redTowersLife],0
	jle @@dead
	jmp @@notdead
@@dead:
	mov [dead],1
	jmp @@end
@@notdead:
	mov [dead],0	
@@end:
ret
endp checkIfLeftRedTowerDown
proc checkIfRightRedTowerDown
	cmp [word redTowersLife+2],0
	jle @@dead
	jmp @@notdead
@@dead:
	mov [dead],1
	jmp @@end
@@notdead:
	mov [dead],0
@@end:
	

ret
endp checkIfRightRedTowerDown


proc checkIfLeftBlueTowerDown
	cmp [word blueTowersLife],0
	jle @@dead
	jmp @@notdead
@@dead:
	mov [dead],1
	jmp @@end
@@notdead:
	mov [dead],0	
@@end:
ret
endp checkIfLeftBlueTowerDown
proc checkIfRightBlueTowerDown
	cmp [word blueTowersLife+2],0
	jle @@dead
	jmp @@notdead
@@dead:
	mov [dead],1
	jmp @@end
@@notdead:
	mov [dead],0
@@end:

ret
endp checkIfRightBlueTowerDown

;input:
;1. bl = player type
;2. dx = top
;3. ax =left
proc hitBasedOnPlayerTypeToTowerBlue
	
	cmp bl ,'H'
	je @@hitHammer
	cmp bl , 'G'
	je @@hitGiant
	cmp bl, 'W'
	je @@hitWrrior
	jmp @@end

@@hitHammer:
	
	call hitHammer
	call getPlayerSide
	call lowerRedLifeTower
	jmp @@end
@@hitWrrior:
	call hitWrrior
	call getPlayerSide
	call lowerRedLifeTower
	jmp @@end
@@hitGiant:
	push ax
	call hitGiant
	pop ax
	call getPlayerSide
	call lowerRedLifeTower
@@end:
	
	ret
endp hitBasedOnPlayerTypeToTowerBlue
proc hitBasedOnPlayerTypeToTowerRed
	
	cmp bl ,'H'
	je @@hitHammer
	cmp bl , 'G'
	je @@hitGiant
	cmp bl, 'W'
	je @@hitWrrior
	jmp @@end

@@hitHammer:
	
	call hitHammer
	call getPlayerSide
	call lowerBlueLifeTower
	jmp @@end
@@hitWrrior:
	call hitWrrior
	call getPlayerSide
	call lowerBlueLifeTower
	jmp @@end
@@hitGiant:
	push ax
	call hitGiant
	pop ax
	call getPlayerSide
	call lowerBlueLifeTower
@@end:
	
	ret
endp hitBasedOnPlayerTypeToTowerRed
;input:
;1. bl = player type
;2. dx = top
;3. ax =left
proc hitBasedOnPlayerTypeToenemy
	push bx
	push dx
	push si
	push di
	
	mov ax, [xHit]
	mov dx, [yHit]
	cmp bl ,'H'
	je @@hitHammer
	cmp bl , 'G'
	je @@hitGiant
	cmp bl, 'W'
	je @@hitWrrior
	jmp @@end

@@hitHammer:
	
	call hitHammer
	jmp @@end
@@hitWrrior:
	call hitWrrior

	jmp @@end
@@hitGiant:

	call hitGiant
	
@@end:
	pop di
	pop si
	pop dx
	pop bx
	ret
endp hitBasedOnPlayerTypeToenemy

;input :
;1. ax = left
;2. output = bh- 'A' = left or 'B' = right
proc getPlayerSide
	cmp ax,161
	jae @@right

	cmp ax,127
	jbe @@left
	jmp @@end
@@right:
	mov [side],'B'
	jmp @@end
@@left:
	mov [side], 'A'
@@end:
	ret
endp getPlayerSide
;input = bx
;bl = player type
;bh = 'A'-for left tower or 'B'- for right tower
proc lowerRedLifeTower
	mov di , offset redTowersLife
	cmp [side], 'B'
	je @@right
	jmp @@cont
@@right:

	add di,2
@@cont:

	cmp bl ,'H'
	je @@hit20
	cmp bl, 'W'
	je @@hit50
	cmp bl,'G'
	je @@hit35
	jmp @@end
	
@@hit20:
	
	sub [word di],20
	jmp @@end
@@hit35:
	
	sub [word di],35
	jmp @@end
@@hit50:
	
	sub [word di],50
@@end:
	; mov al, [redTowersLife+1]
	; xor ah,ah
	; call ShowAxDecimal
	ret
endp lowerRedLifeTower
proc lowerBlueLifeTower
	mov di , offset blueTowersLife
	cmp [side], 'B'
	je @@right
	jmp @@cont
@@right:

	add di,2
@@cont:

	cmp bl ,'H'
	je @@hit20
	cmp bl, 'W'
	je @@hit50
	cmp bl,'G'
	je @@hit35
	jmp @@end
	
@@hit20:
	
	sub [word di],20
	jmp @@end
@@hit35:
	
	sub [word di],35
	jmp @@end
@@hit50:
	
	sub [word di],50
@@end:
	; mov al, [redTowersLife+1]
	; xor ah,ah
	; call ShowAxDecimal
	ret
endp lowerBlueLifeTower



; x = ax, y = dx
proc cheangeDirectionBasedOnLiveTowersForBlue

	cmp [word redTowersLife],0
	jle @@checkXYLeftBlue
@@checkRight:
	cmp [word redTowersLife+2],0
	jle @@checkXYRightBlue
	
	jmp @@reg
	
@@checkXYLeftBlue:
	
	cmp dx, 40
	jbe @@checkXLeftBlue
	jmp @@checkRight
@@checkXLeftBlue:
	cmp ax,127
	jbe @@checngeDirectionBLueLeft
	jmp @@checkRight
@@checngeDirectionBLueLeft:
	mov [word si+8],3
	jmp @@end
	
@@checkXYRightBlue:

	cmp [word si+4], 40
	jbe @@checkXRightBlue
	jmp @@end
@@checkXRightBlue:
	
	cmp [word si+2],161
	jae @@checngeDirectionRightBlue
	jmp @@end
@@checngeDirectionRightBlue:
	mov [word si+8],2
	jmp @@end
@@reg:
	
	;mov [word si+8],0
	
@@end:
	

ret
endp cheangeDirectionBasedOnLiveTowersForBlue

proc cheangeDirectionBasedOnLiveTowersForRed
	
	cmp [blueTowersLife+2],0
	jle @@checkXYLeftRed
@@checkRight:
	cmp [blueTowersLife],0
	jle @@checkXYRightRed

	jmp @@end
	
@@checkXYLeftRed:
	cmp dx, 50
	jae @@checkXLeftRed
	jmp @@checkRight
@@checkXLeftRed:
	cmp ax,107
	jae @@checngeDirectionRedLeft
	jmp @@checkRight
@@checngeDirectionRedLeft:
	mov [direction],3

	
	jmp @@end
	
@@checkXYRightRed:
	cmp dx, 50
	jae @@checkXRightRed
	jmp @@end
@@checkXRightRed:
	cmp ax,181
	jbe @@checngeDirectionRightRed
	jmp @@end
@@checngeDirectionRightRed:
	mov [direction],2
	jmp @@end
	
@@reg: 
	mov [direction],0
@@end:
	


ret
endp cheangeDirectionBasedOnLiveTowersForRed

;get cx as permter to x cord
proc checkPlayerPath
	
	cmp cx, 154
	jae @@left
	jb @@right
		
@@left:
	mov cx, 181
	jmp @@end
@@right:
	mov cx,107
@@end:


ret
endp checkPlayerPath




proc checkRedLeftTowerDown
	cmp [word redTowersLife],0
	jle @@down
	jmp @@end
@@down:
	mov [towerType],'RL'
	call loadTower
	mov [redTowersLife],0
@@end:
			

	ret
endp checkRedLeftTowerDown
proc checkRedRightTowerDown
	cmp [redTowersLife+2] ,0
	jle @@down
	jmp @@end
@@down:
	mov [towerType],'RR'
	call loadTower
	mov [redTowersLife+2],0
@@end:
	ret
endp checkRedRightTowerDown

proc checkBlueLeftTowerDown
	cmp [blueTowersLife+1] ,0
	jle @@down

@@down:
	;draw down the tower
	mov [blueTowersLife+1],0
	ret
endp checkBlueLeftTowerDown

proc checkBlueRightTowerDown
	cmp [blueTowersLife] ,0
	jle @@down

@@down:
	;draw down the tower
	mov [blueTowersLife],0
	ret
endp checkBlueRightTowerDown
proc undrawTower
	push bp
	mov bp,sp
	cmp [word bp+4], 'LB'
	je @@leftBLueTower
	cmp [word bp+4], 'RB'
	je @@rightBLueTower
	cmp [word bp+4], 'LR'
	je @@LeftRedTower
	cmp [word bp+4], 'RR'
	je @@RightRedTower

@@leftBLueTower:
	jmp @@cont
@@rightBLueTower:
	jmp @@cont
@@LeftRedTower:
	jmp @@cont
@@RightRedTower:
@@cont:
	pop bp
	ret
endp undrawTower


;input [BmpTop] = y, [BmpLeft] = x, bx = index of card [direction ] = direction of movment
proc DrawPlayer
	mov ax, [BmpLeft]
	mov dx, [BmpTop]
	mov [colorPlayer],bl
	ASSUME_MAP
	MOV [mapLeft],ax
	mov [mapTop],dx

	call loadMapToScreen
	call checkPlayerType
	ret
endp DrawPlayer

proc checkDirectionAndAct
	ASSUME_MAIN
	mov al,[direction]
	cmp al, 0
	je @@up
	cmp al,1
	je @@down
	cmp al,2
	je @@left
	cmp al,3
	je @@right
	jmp @@next
@@up:
	dec [byte ptr si+4]
	jmp @@next
@@down:

	inc dx
	inc [byte ptr si+4]
	jmp @@next
@@left:
	dec ax
	dec [byte ptr si+2]
	jmp @@next
@@right:
	inc ax
	inc [byte ptr si+2]
@@next:

	ret
endp checkDirectionAndAct

;input bx = player index
proc checkPlayerType
	;add the red players!!!!1
	cmp bh, 'G'
	je @@giant
	cmp bh, 'H'
	je @@hammer
	cmp bh, 'W'
	je @@wrrior
	jmp @@end
@@giant:
	call MoveGiant
	jmp @@end
@@hammer:
	call moveBlueHmmer
	jmp @@end
@@wrrior:
mov ax, [BmpLeft]

	call moveWrriorBlue
@@end:

	ret
endp checkPlayerType
proc MoveGiant
	push ax
	push dx
	cmp [colorPlayer],'B'
	je @@blue
	cmp [colorPlayer],'R'
	je @@red
	jmp @@end
@@blue:
	mov dx, offset giant
	jmp @@next
@@red:
	mov dx, offset giantred
@@next:
	ASSUME_MAIN
	mov [BmpWidth],20
	mov [BmpHeight],20
	mov bx, dx
	xor [byte bx+6],1
	call OpenTransBmp
@@end:
	pop dx
	pop ax
ret
endp MoveGiant
proc moveWrriorBlue
	push ax
	push dx
	HIDE_MOUSE
	ASSUME_MAIN


	mov al, [wrriorBlue+4]
	cmp al,'0'
	je @@add
	cmp al,'1'
	je @@dec
@@add:
	inc al
	jmp @@run
@@dec:
	dec al

@@run:
	mov [wrriorBlue+4], al
	mov [BmpWidth],20
	mov [BmpHeight],20
	mov dx, offset wrriorBlue
	call OpenTransBmp

	SHOW_MOUSE
	pop dx
	pop ax
ret
endp moveWrriorBlue


proc moveBlueHmmer
	push ax
	push dx
	HIDE_MOUSE
	ASSUME_MAIN
	mov [BmpWidth],20
	mov [BmpHeight],20
	mov dx, offset bluehammer
	mov al, [bluehammer+5]

	cmp al,'5'
	je @@add
	cmp al,'6'
	je @@dec
@@add:
	inc al
	jmp @@run
@@dec:
	dec al

@@run:
	mov [bluehammer+5], al
	call OpenTransBmp

	SHOW_MOUSE
	pop dx
	pop ax
ret
endp moveBlueHmmer

proc moveHammerBlue

	push ax
	HIDE_MOUSE
	mov ax, [BmpTop]
	mov [BufferTop],ax
	mov ax, [BmpLeft]
	mov [BufferLeft], ax

	jmp @@start
@@load:

	call loadBuffer
@@start:
	push cx
	dec [BmpTop]
	dec [BufferTop]
	call copyBuffer
	call moveBlueHmmer

	pop cx
	loop @@load
	SHOW_MOUSE
	pop ax
	ret
endp moveHammerBlue
proc moveBlueWrrior
	push ax

	mov ax, [BmpTop]
	mov [BufferTop],ax
	mov ax, [BmpLeft]
	mov [BufferLeft], ax

	jmp @@start
@@load:

	call loadBuffer
@@start:
	push cx
	dec [BmpTop]
	dec [BufferTop]
	call copyBuffer
	call moveWrriorBlue

	pop cx
	loop @@load
	pop ax
	ret
endp moveBlueWrrior

proc checkWinner
	call checkIfLeftRedTowerDown
	cmp [dead],0
	je @@checkBlue
	call checkIfRightRedTowerDown
	cmp [dead],1
	je @@blueWin

@@checkBlue:
	call checkIfLeftBlueTowerDown
	cmp [dead],0
	je @@end
	call checkIfRightBlueTowerDown
	cmp [dead],1
	je @@redWin
	jmp @@end
@@redWin:
	mov [won],  'R'
	jmp @@end
@@blueWin:
	mov [won],  'B'

@@end:
	ret
endp checkWinner

proc drawGiantCard
ASSUME_MAIN
	mov [color],255
	mov [lineWidth],35
	mov [lineheight], 42
	mov [Yp],9
	mov [Xp],320-50
	call DrawRect

	mov dx, offset giantCard
	mov [BmpLeft],320-50
	mov [BmpTop],10
	mov [BmpHeight],41
	mov [BmpWidth],34
	call OpenTransBmp
	ret
endp drawGiantCard
proc hammerCard

	mov [color],255
	mov [lineWidth],35
	mov [lineheight], 42
	mov [Yp],60
	mov [Xp],320-50
	call DrawRect

	mov dx, offset hammerCardi
	mov [BmpLeft],320-50
	mov [BmpTop],62
	mov [BmpHeight],41
	mov [BmpWidth],34
	call OpenTransBmp
	ret
endp hammerCard

proc wrriorCard
	mov [color],255
	mov [lineWidth],35
	mov [lineheight], 42
	mov [Yp],114
	mov [Xp],320-51
	call DrawRect

	mov dx, offset wrcard
	mov [BmpLeft],320-50
	mov [BmpTop],115
	mov [BmpHeight],41
	mov [BmpWidth],34
	call OpenShowBmp
	ret
endp wrriorCard
proc loadTower
	push es
	push ds
	
	mov bp,sp
	mov ax, [word towerType]
	ASSUME_MAP
	cmp ax, 'BL'
	je @@leftBLueTower
	cmp ax, 'BR'
	je @@RightBLueTower
	cmp ax, 'RL'
	je @@leftRedTower
	cmp ax, 'RR'
	je @@RightRedTower
@@leftBLueTower:
	
	jmp @@cont
@@RightBLueTower:
	
	jmp @@cont
@@leftRedTower:
	ASSUME_MAP
	mov [widthB], 40
	mov [heightB],40
	mov [mapTop],0
	mov [mapLeft],100
	call loadMapToScreen
	mov [widthB], 30
	mov [heightB],39
	mov [mapTop],20
	mov [mapLeft],90
	call loadMapToScreen
	jmp @@cont
@@RightRedTower:

	mov [widthB], 40
	mov [heightB],40
	mov [mapTop],0
	mov [mapLeft],180
	call loadMapToScreen
	mov [widthB], 30
	mov [heightB],39
	mov [mapTop],20
	mov [mapLeft],180
	call loadMapToScreen
@@cont:
	
	pop ds
	pop es
	ret 
endp loadTower
proc loadMap
	push es
	push ds
	ASSUME_MAP
	mov ax, 0a000h
	mov es,ax

	mov di,23*320
	add di,90
	mov si, offset map


	mov cx,161
@@rows:
	push cx
	mov cx, 127
@@cols:
	mov dl ,[es:di]
	mov [si],dl
	inc si
	inc di
	loop @@cols
	pop cx

	add di,320
	sub di,127
	loop @@rows
	ASSUME_MAIN
	pop ds
	pop es
	ret
endp loadMap

proc loadMapToScreen
	push cx
	mov ax, 0a000h
	mov es, ax
	 ASSUME_MAP

	mov ax,[mapLeft]
	mov si,offset map
	mov di,0
	mov cx, [word ptr mapTop]

@@add:
	add di,320
	add si,127
	loop @@add

	sub si, 127*23
	add si, [mapLeft]
	sub si,90
	add di, [mapLeft]
	mov cx,[heightB]

@@rows:
	push cx
	mov cx,[widthB]
	rep movsb
	pop cx

	add di,320
	add si, 127
	sub di,[widthB]
	sub si,[widthB]
	loop @@rows
	ASSUME_MAIN
	pop cx

	ret
endp loadMapToScreen
proc checkCard far
	mov al, [selectORput]
	xor ah,ah
	

cmp [selectORput],0
je @@starter
jmp @@putORcancel
@@starter:
	GET_MOUSE_POSITION
	shr cx,1
	cmp cx, 320-50
	jae @@checkRight
	jmp @@end

@@checkRight:
	cmp cx, 320-50+34
	jbe @@checkChars
	jmp @@end

@@checkChars:

@@checkTopGiant:
	cmp dx, 10
	jae @@checkBottomGiant
	jmp @@checkTopHammer

@@checkBottomGiant:
	cmp dx,41
	jbe @@giant

@@checkTopHammer:
	cmp dx, 62
	jae @@checkBottomHammer
	jmp @@checkTopWrrorir

@@checkBottomHammer:
	cmp dx, 103
	jbe @@hammer

@@checkTopWrrorir:
	cmp dx, 115
	jae @@checkBottomWrrorir
	jmp @@end
@@checkBottomWrrorir:
	cmp dx, 115+34
	jbe @@wrroir
	jmp @@end
@@giant:
	call boundries
	mov [playerTypePut], 'G'
	mov [selectORput],1
	jmp @@end
@@hammer:
	call boundries
	mov [playerTypePut], 'H'
	mov [selectORput],1
	jmp @@end
@@wrroir:
	call boundries
	mov [playerTypePut], 'W'
	mov [selectORput],1
	jmp @@end

@@putORcancel:
	GET_MOUSE_POSITION
	cmp bx,1
	je @@left
	cmp bx, 2
	je @@right
	jmp @@end
@@left:
	call putPlayerInMap
	mov [selectORput],0
	jmp @@end
@@right:
	call canceldaction
	mov [selectORput],0
@@end:

	retf
endp checkCard
proc canceldaction
	push cx
	push dx
	UN_SET_MOUSE_BOUNDRIES_TO_MAP
	pop dx
	pop cx
ret
endp canceldaction
proc putPlayerInMap

	cmp [playerTypePut],'H'
	je @@hmer

	cmp [playerTypePut],'G'
	je @@giant

	cmp [playerTypePut],'W'
	je @@wriror
	jmp @@end
@@hmer:
	call putHammer
	jmp @@end
@@giant:
	call putGiant
	jmp @@end
@@wriror:
	call putWrroir

@@end:

ret
endp putPlayerInMap
proc putWrroir
	;cmp [ElixerUser],'6'
	;jb @@end
	;sub [ElixerUser], 6
	push cx
	push dx
	mov dx, 114
	mov cx, 320-51
	READ_PIXEL
	cmp al,255
	je @@changeColor
	jne @@changeWhite
	jmp @@draw
@@changeWhite:
	mov [color],255
	jmp @@draw
@@changeColor:
	mov [color],20

@@draw:
	mov [lineWidth],35
	mov [lineheight], 42
	mov [Yp],114
	mov [Xp],320-51
	call DrawRect
	call putCard
	pop dx
	pop cx
	shr cx,1
	push 'WB'
	call MovePosition

@@end:
	ret
endp putWrroir




proc putHammer
	; cmp [ElixerUser],'4'
	; jb @@end
	; sub [ElixerUser], 4
	push cx
	push dx
	mov dx, 60
	mov cx, 320-51
	READ_PIXEL
	cmp al,255
	je @@changeColor
	jne @@changeWhite
	jmp @@draw
@@changeWhite:
	mov [color],255
	jmp @@draw
@@changeColor:
	mov [color],20

@@draw:
	mov [lineWidth],35
	mov [lineheight], 42
	mov [Yp],60
	mov [Xp],320-51
	call DrawRect
	call putCard
	
	pop dx 
	pop cx
	shr cx,1
	push 'HB'
	call MovePosition
@@end:
	ret
endp putHammer

proc putGiant
	;cmp [ElixerUser],'5'
	;jb @@end
	sub [ElixerUser], 5
	PUSH CX
	PUSH DX
	mov dx, 9
	mov cx, 320-50
	READ_PIXEL
	cmp al,255
	je @@changeColor
	jne @@changeWhite
	jmp @@draw
@@changeWhite:
	mov [color],255
	jmp @@draw
@@changeColor:
	mov [color],20

@@draw:
	mov [lineWidth],35
	mov [lineheight], 42
	mov [Yp],9
	mov [Xp],320-50
	call DrawRect
	call putCard
	POP DX
	POP CX
	SHR CX,1
	PUSH CX
	PUSH DX
	push 'GB'
	call MovePosition

	POP DX
	POP CX
	SUB DX,70
	push 'GR'
	call MovePosition
@@end:
	ret
endp putGiant

proc putCard

	mov [cardX],cx
	mov [cardY],dx
	
	ret
endp putCard

;input: cx = x of player, dx = y of player
;output: si = positionIndexeder
proc MovePosition
	push bp
	mov bp,sp
	mov bx, [bp+4]


	mov si, offset playersPositions
	mov ax, [positionIndexeder]
	add si, ax
	
	;for player position in array
	mov[word si+12], ax
	
	;add x to array
	call checkPlayerPath
	mov [si+2],cx
	mov [word ptr player], cx

	;add y to array
	mov [si+4], dx
	mov [word ptr player+2], dx

	; for player index
	mov [si+6], bx
	mov [byte ptr player+4],bh
	call WritePlayer
	;for player direction
	cmp bl,'B'
	je @@reg
	jmp @@nun
@@reg:
	mov [direction],0
	jmp @@ends
@@nun:
	
	mov [direction],1
@@ends:
	mov ah,0
	mov al, [direction]	
	mov [si+8],ax

	; for player life amount
	cmp bh, 'G'
	je @@G
	cmp bh, 72
	je @@H
	cmp bh,87
	jmp @@end
@@G:
	mov [word ptr si+10], 650
	jmp @@end
@@H:
	mov [word ptr si+10], 400
	jmp @@end
@@W:
	mov [word ptr si+10], 500

@@end:
	mov [word si+14],0
	add [positionIndexeder],14
	pop bp
	ret 2
endp MovePosition
proc heandleCardPutting

	mov ax ,[cardX]
	sub ax,10
	mov [BmpLeft],ax
	mov ax ,[cardY]
	sub ax,10
	mov [BmpTop],ax
	HIDE_MOUSE
	UN_SET_MOUSE_BOUNDRIES_TO_MAP
	SET_MOUSE_POSTION_TO_CARDS
	SHOW_MOUSE
	ret
endp heandleCardPutting


proc boundries
	HIDE_MOUSE
	MOVE_MOUSE_TO_MIDDLE
	SHOW_MOUSE
	ret
endp boundries
proc asyncMouseCard
	mov ax,seg checkCard
	mov es, ax
	mov dx, offset checkCard
	mov cx, 00001010b
	mov ax, 0ch
	int 33h

	ret
endp asyncMouseCard
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

proc showTowersFacesBlue
	;54= 1-9, 53 = 1-2
	; mov dx, offset towerblue
	mov [BmpLeft],178
	mov [BmpTop],120
	mov [BmpWidth], 40
	mov [BmpHeight] ,40

	mov dx, offset towerblue
	call OpenTransBmp

	sub [BmpLeft],82
	call OpenTransBmp

	ret
endp showTowersFacesBlue

proc showTowersFacesRed
	;54= 1-9, 53 = 1-2
	; mov dx, offset towerblue
	mov [BmpLeft],180
	mov [BmpTop],0
	mov [BmpWidth], 40
	mov [BmpHeight] ,40
	mov dx, offset towerRed
	call OpenTransBmp
	mov [BmpLeft],100
	mov dx, offset towerRed
	call OpenTransBmp
	ret
endp showTowersFacesRed


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





proc OpenShowBmp near


	call OpenFile
	cmp [ErrorFile],1
	je @@ExitProc

	call ReadBmpHeader

	call ReadBmpPalette

	call CopyBmpPalette

	call ShowBMP


	call CloseFile

@@ExitProc:
	ret
endp OpenShowBmp

proc OpenTransBmp near


	call OpenFile
	cmp [ErrorFile],1
	je @@ExitProc
	push ax
	push bx
	push cx
	push dx
	call ReadBmpHeader

	call ReadBmpPalette

	call CopyBmpPalette

	call ShowTransBMP


	call CloseFile
	pop dx
	pop cx
	pop bx
	pop ax
@@ExitProc:

	ret
endp OpenTransBmp




; input dx filename to open
proc OpenFile	near
	mov ah, 3Dh
	mov al, 0
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc

@@ErrorAtOpen:
	mov [ErrorFile],al
	mov ah,10
@@ExitProc:
	ret
endp OpenFile
proc movePointerToEnd
	mov ah,42h
	mov al,2
	mov bx, [FileHandle]
	mov cx,0
	mov dx,0
	int 21h
	ret
endp movePointerToEnd

proc movePointerToStart
	mov ah,42h
	mov al,0
	mov bx, [FileHandle]
	mov cx,0
	mov dx,0
	int 21h
	ret
endp movePointerToStart

 proc OpenFilePlayer	near
	mov ah, 3Dh
	mov al, 2
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc

@@ErrorAtOpen:
	mov [ErrorFile],al
	mov ah,10
@@ExitProc:
	ret
endp OpenFileplayer

proc WritePlayer
	call movToDxoffsetOfPlayerFileType

	call OpenFilePlayer
	cmp ah,10
	je @@erOpen
@@erOpen:
	mov ah,0
	cmp ax, 2
	je @@start
	jmp @@end

@@start:
	call movePointerToEnd
	mov bx,[FileHandle]
	mov cx,7
	mov dx, offset player
	mov ah,40h
	int 21h
	jc @@erOpen
	call movePointerToEnd
	JC @@erOpen

	call CloseFile
@@end:
	ret
endp WritePlayer


proc takenImage
	mov [BmpHeight],200
	mov [BmpWidth],320
	mov [BmpTop],0
	mov [BmpLeft],0
	mov dx, offset takenIm
	call OpenShowBmp

	ret
endp takenImage
proc StartGame
	mov dx, offset availableFile
	call OpenFilePlayer
	cmp ah,10
	jNe @@errOpen
	jmp @@start
@@errOpen:
	cmp ax,5
	je @@trueTaken
	jmp @@end
@@trueTaken:
	call takenImage
	jmp @@end
@@start:
	call CloseFile
	mov dx, offset usersFile
	call OpenFilePlayer
	jc @@errOpen
	call movePointerToStart
@@read:
	call readplayer
	jc @@errOpen
	cmp [playerType],'B'
	je @@writeRed
	cmp [playerType],'R'
	je @@writeBlue

	cmp [playerType],255
	je @@startRed
	jmp @@end

@@startRed:
	call movePlayerTypeToRed
@@writeRed:
	mov [playerType],'R'
	call createFileGameByPlayerType
	jmp @@end
@@writeBlue:
	mov [playerType],'B'
	call createFileGameByPlayerType
@@end:
	ret
endp StartGame
proc movToDxoffsetOfPlayerFileType
	cmp [playerType],'B'
		je @@blue
	@@red:
		mov dx, offset red
		jmp @@cont
	@@blue:
		mov dx, offset blue

	@@cont:
ret
endp movToDxoffsetOfPlayerFileType
proc createFileGameByPlayerType

	call movToDxoffsetOfPlayerFileType
	mov cx,0
	mov ah,3ch
	int 21h
	jc @@error
	mov [FileHandle], ax
	jmp @@end

@@error:

@@end:

	ret
endp createFileGameByPlayerType


proc checkIfonline

	mov dx, offset blue
	call OpenFileplayer
	cmp ah,10
	je @@not
	call CloseFile

	mov dx, offset red
	call OpenFileplayer
	cmp ah,10
	je @@not
	call CloseFile
	mov [bothOnline],1
@@not:

	ret
endp checkIfonline
proc movePlayerTypeToRed
	mov ah,40h
	mov bx, [FileHandle]
	mov cx,1
	mov dx, offset red
	int 21h
	call CloseFile


	ret
endp movePlayerTypeToRed

proc waitPlayers
	mov [BmpHeight],200
	mov [BmpWidth],320
	mov [BmpLeft],0
	mov [BmpTop],0
	mov dx, offset notOnline
	call OpenShowBmp
ret
endp waitPlayers
proc readplayer
	mov bx, [FileHandle]
	mov cx, 1
	mov dx, offset playerType
	mov ah,03fh
	int 21h

	ret
endp readplayer


proc CloseFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseFile




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


;dx = top ax = Left
proc hitWrrior	
	push bx
	push ax
	push dx
	
	cmp bh, 'B'
	je @@blue
	jmp @@red
@@blue:
	mov bx, offset hitWrriorBim
	jmp @@cont
@@red:	
	mov bx, offset hitWrriorRim
@@cont:
	
	mov [BmpTop],dx
	mov [BmpLeft],ax
	mov[BmpWidth],20
	mov [BmpHeight],20
	xor [byte bx+4],1
	mov dx,bx
	call OpenTransBmp
	pop dx
	pop ax
	caLL _100MiliSecDelay

	ASSUME_MAP
	mov [mapLeft],ax
	mov[mapTop],dx
	mov [widthB],20
	mov [heightB],20
	call loadMapToScreen
	ASSUME_MAIN
	pop bx
ret
endp hitWrrior


;input - bh= 'R' or 'B'

proc hitHammer
	push bx
	push ax
	push dx
	cmp bh,'B'
	je @@blue
	jmp @@red
@@blue:
	mov bx, offset hitHamerBim
	jmp @@cont
@@red:
	mov bx, offset hitHammerR
@@cont:
	mov [BmpTop],dx
	mov [BmpLeft],ax
	mov[BmpWidth],20
	mov [BmpHeight],20
	
	xor [byte bx+4],1
	mov dx, bx	
	call OpenTransBmp
	pop dx
	pop ax
	call _200MiliSecDelay
	ASSUME_MAP
	mov [mapLeft],ax
	mov[mapTop],dx
	mov [widthB],20
	mov [heightB],20
	call loadMapToScreen
	ASSUME_MAIN
	pop bx
ret
endp hitHammer

;input - bh= 'R' or 'B'
proc hitGiant
	push bx
	push bx	
	push ax
	push dx
	ASSUME_MAP
		mov [mapLeft],ax
	mov[mapTop],dx
	mov [widthB],20
	mov [heightB],20
	call loadMapToScreen
	ASSUME_MAIN
	
	pop dx 
	pop ax
	pop bx
	
	cmp bh, 'B'
	je @@blue
	jmp @@red
@@blue:
	mov bx, offset gianthitB
	jmp @@cont
@@red: 
	mov bx, offset gianthitR
@@cont:
	mov [BmpTop],dx
	mov [BmpLeft],ax
	mov[BmpWidth],20
	mov [BmpHeight],20	
	
	xor [byte bx+6],1
	mov dx,bx
	call OpenTransBmp
	

	call _200MiliSecDelay
	pop bx
	

	
ret
endp hitGiant
proc pushAll
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	ret
endp pushAll
proc popAll
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp popAll
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

proc _100MiliSecDelay
	push cx

	mov cx ,1000
@@Self1:

	push cx
	mov cx,300

@@Self2:
	loop @@Self2

	pop cx
	loop @@Self1

	pop cx
	ret
endp _100MiliSecDelay
proc _20MiliSecDelay
	push cx

	mov cx ,200
@@Self1:

	push cx
	mov cx,300

@@Self2:
	loop @@Self2

	pop cx
	loop @@Self1

	pop cx
	ret
endp _20MiliSecDelay
proc copyBuffer
	push es
	push ds
	push ax
	push cx
	push si
	push di

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

	pop si
	pop di
	pop cx
	pop ax
	pop ds
	pop es
	ret
endp copyBuffer
proc RandomByCs
    push es
	push si
	push di
	push cx



	mov ax, 40h
	mov	es, ax

	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP

	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)

RandLoop: ;  generate random number
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)





	xor al, ah ; xor memory and counter



	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di

	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop

	add al,bl  ; add the lower limit to the rnd num

@@ExitP:
	pop cx
	pop di
	pop si
	pop es
	ret
endp RandomByCs
Proc MakeMask
    push bx

	mov si,1

@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc

	shl si,1 ; add 1 to si at right
	inc si

	jmp @@again

@@EndProc:
    pop bx
	ret
endp  MakeMask

proc loadBuffer
	push ax
	push si
	push es
	push cx
	push di
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

	pop di
	pop cx
	pop es
	pop si
	pop ax
	ret
endp loadBuffer







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
proc DrawHorizontalLine	near
	push si
	push cx
	push dx
DrawLine:
	cmp si,0
	jz ExitDrawLine

    mov ah,0ch
	int 10h    ; put pixel


	inc cx
	dec si
	jmp DrawLine


ExitDrawLine:
	pop dx
	pop cx
    pop si
	ret
endp DrawHorizontalLine



proc DrawVerticalLine	near
	push si
	push dx
	push cx

DrawVertical:
	cmp si,0
	jz @@ExitDrawLine

    mov ah,0ch
	int 10h    ; put pixel



	inc dx
	dec si
	jmp DrawVertical


@@ExitDrawLine:
	pop cx
	pop dx
    pop si
	ret
endp DrawVerticalLine
proc DrawRect
	mov si, [lineWidth]
	mov al, [color]
	mov cx, [Xp]
	mov dx, [Yp]

	call DrawHorizontalLine
	add dx, [lineheight]
	call DrawHorizontalLine
	mov dx, [Yp]

	mov si, [lineheight]
	inc si
	call DrawVerticalLine
	add cx, [lineWidth]
	call DrawVerticalLine

	ret
endp DrawRect




proc  SetGraphic near
	mov ax,13h   ; 320 X 200
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode
	int 10h
	START_MOUSE
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
	cmp [byte ptr si], 0
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
EndOfCsLbl:

END start

