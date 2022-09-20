@echo off
@setlocal enabledelayedexpansion
goto :init

:usage
echo usage: %~nx0 [clean build rebuild run]
exit /b -100

:init
set _action=%1
set _targetArch=%2
set _extraArgs=%~3
set _filenameRoot=hello-ASAN

for %%a in (clean build rebuild run) do (
    if "%_action%" == "%%a" goto :check_targetArch
)
echo %~n0: invalid action '%_action%'& exit /b 1

:check_targetArch
if "%_targetArch%" == "" (
    echo INFO: no Platform specified - using x64
    set _targetArch=x64
) 
if /I "%_targetArch%" NEQ "x64" if /I "%_targetArch%" NEQ "x86" (
    echo invalid Platform architecture '%_targetArch%' - running x64 instead
    set _targetArch=x64
)
set _archOutputDir=!_targetArch!
if /I "%_targetArch%" == "x86" set _archOutputDir=Win32

:start

for %%i in (yes y true) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=true
for %%i in (no n false) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=false
if "%_pauseBeforeCommands%" == "" set _pauseBeforeCommands=false

goto :%_action%

:clean
set $cmd=del *.exe *.obj *.pdb *.ilk
echo Cleaning build directory... [command=%$cmd%]
if /I "%_pauseBeforeCommands%" == "true" pause
%$cmd% >nul 2>&1
exit /b 0
goto :done

:build
set $cmd=cl.exe /fsanitize=address /Zi /MD /EHsc /Bv %_filenameRoot%.cpp %_extraArgs%
echo Building for %_targetArch%... [command=%$cmd%]
if /I "%_pauseBeforeCommands%" == "true" pause
%$cmd%
exit /b 0
goto :done

:rebuild
call :clean
call :build
goto :done

:run
set $_exeFile=.\%_filenameRoot%.exe
if not exist %$_exeFile% (
    echo - error: unable to run - '%$_exeFile%' does not exist
    exit /b 1
)
echo Running '%$_exeFile%'...
if /I "%_pauseBeforeCommands%" == "true" pause
%$_exeFile%
goto :done

:done
exit /b 0
