IDEAL
MODEL small
stack 256
PUBLIC Maximum
Maximum=100h


DATASEG
	PUBLIC counter
	counter db 'a'



CODESEG
	
	PUBLIC myproc
	proc myproc
	ret
	
	endp myproc
END