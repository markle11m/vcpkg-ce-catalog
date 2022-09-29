@echo off
@setlocal enabledelayedexpansion
goto :init

:usage
echo usage: %~nx0 ACTION [FILE] [TARGET] [HOST] ["EXTRA-ARGS"]
echo.
echo ^  ACTION      one of {clean build rebuild run}
echo ^  FILE        name of the file to build
echo ^  TARGET      target architecture to build, one of {target:x64, target:x86}
echo ^  HOST        host architecture for the build toolset, one of {host:x64, host:x86}
echo ^  CL_OPTIONS  quoted string containing additional compiler options, e.g. "/O2 /Zi"
echo.
exit /b -100

:init
set _validActions=clean build rebuild run
set _validFiles=hello.cpp hello-MFC.cpp hello-ASAN.cpp
set _validTargets=target:x64 target:x86
set _validHosts=host:x64 host:x86
set _action=
set _filename=
set _filenameRoot=
set _targetArch=

:getargs
set _arg=%1
set _argT=%~1
if "%_argT%" == "" goto :validateargs
for %%a in (%_validActions%) do if /I "%%a" == "%_argT%" set _action=%_argT%& goto :nextarg
for %%a in (%_validFiles%) do if /I "%%a" == "%_argT%" set _filename=%_argT%& goto :nextarg
for %%a in (%_validTargets%) do if /I "%%a" == "%_argT%" set _targetArch=%_argT%& goto :nextarg
for %%a in (%_validHosts%) do if /I "%%a" == "%_argT%" set _hostArch=%_argT%& goto :nextarg
if .%_arg%. == ."%_argT%". set _extraArgs=%_extraArgs% %_argT%& goto :nextarg
echo - WARNING: ignoring unknown parameter '%_arg%'
:nextarg
shift
goto :getargs

:validateargs

:check_targetArch
if "%_targetArch%" == "" (
    echo INFO: no Platform specified - using x64
    set _targetArch=x64
) 
set _archOutputDir=!_targetArch!
if /I "%_targetArch%" == "x86" set _archOutputDir=Win32

:start
if "%_filename%" == "" echo ERROR: filename not specified & exit /b -1
if not exist %_filename% echo ERROR: file '%_filename%' does not exist & exit /b -2
for %%f in (%_filename%) do set _filenameRoot=%%~nf

for %%i in (yes y true) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=true
for %%i in (no n false) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=false
if "%_pauseBeforeCommands%" == "" set _pauseBeforeCommands=false

goto :%_action%

:clean
set $cmd=del *.exe *.obj *.pdb *.ilk
echo *** Cleaning build directory... [command=%$cmd%]
if /I "%_pauseBeforeCommands%" == "true" pause
%$cmd% >nul 2>&1
exit /b 0
goto :done

:build
set $cmd=cl.exe /EHsc /Bv %_extraArgs% %_filenameRoot%.cpp
echo *** Building for %_targetArch%... [command=%$cmd%]
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
    echo - ERROR: unable to run - '%$_exeFile%' does not exist
    exit /b 1
)
echo *** Running '%$_exeFile%'...
if /I "%_pauseBeforeCommands%" == "true" pause
%$_exeFile%
goto :done

:done
exit /b 0
