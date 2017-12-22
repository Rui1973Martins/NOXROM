
REM pasmo.exe    --alocal --tap NOXTEST.asm code.tap NOXTEST.symbol
pasmo.exe -d --alocal --tap NOXTEST.asm code.tap NOXTEST.symbol

@IF errorlevel 1 GOTO error

copy /b /y Init8000.tap+code.tap test.tap > nul
del code.tap

goto exit

:error
@pause

:exit
