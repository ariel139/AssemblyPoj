@echo off


tasm /zi base.asm

set /p  h="hello: "

tlink /v base

td base

exit 

echo opening debugger...

