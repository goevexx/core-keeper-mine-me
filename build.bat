Ahk2Exe.exe /in MineMeCoreKeeper.ahk /out MineMeCoreKeeper-x32.exe /bin "%AHK%\v2\AutoHotkey32.exe"
if %errorlevel% neq 0 exit /b %errorlevel%
Ahk2Exe.exe /in MineMeCoreKeeper.ahk /out MineMeCoreKeeper-x64.exe /bin "%AHK%\v2\AutoHotkey64.exe"
if %errorlevel% neq 0 exit /b %errorlevel%
