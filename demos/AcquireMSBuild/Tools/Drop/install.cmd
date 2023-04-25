@echo off

:init
set _toolURL=https://artifacts.dev.azure.com/artifactsu1/_apis/drop/client/exe 
set _toolPathRoot=%~dp0Drop.App
set _toolPath=%_toolPathRoot%\lib\net45
set _toolExe=drop.exe
set _toolFullPath=%_toolPath%\%_toolExe%

set _echo= 
set _dops=powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None

rem echo on
where %_toolExe% >nul 2>&1
if errorlevel 0 if not errorlevel 1 (
    call :echo_info Found '%_toolExe%' on PATH:
    for /f "tokens=1*" %%p in ('where.exe %_toolExe%') do call :echo_info - %%p %%q
    goto :done
)

:check_tool_downloaded
if exist %_toolFullPath% (
    call :echo_info Found '%_toolExe%' in '%_toolPath%'; updating PATH...
    set PATH=%PATH%;%_toolPath%
    goto :done
)

:download_tool
call :echo_action Downloading package for '%_toolExe%'...
curl -L %_toolURL% -o Drop.App.nupkg.zip
if errorlevel 1 call :set_error_info %ERRORLEVEL% "unable to download %_toolExe% package" & goto :fatal
call :echo_action Expanding package for '%_toolExe%'...
powershell Expand-Archive Drop.App.nupkg.zip %_toolPathRoot%
if errorlevel 1 call :set_error_info %ERRORLEVEL% "unable to expand %_toolExe% package" & goto :fatal
if not exist %_toolFullPath% call :set_error_info 1001 "internal error" & goto :fatal
call :echo_action Adding '%_toolExe%' directory to front of PATH...
set PATH=%_toolPath%;%PATH%

goto :done

:set_error_info
set _exitCode=%1
set _fatalMsg=%~2
exit /b 0

:fatal
echo FATAL: [%_exitCode%] %_fatalMsg%
exit /b %_exitCode%

:check_toolpath
if not exist "%_toolPath%" (
    md "%_toolPath%" >nul 2>&1
    if errorlevel 1 exit /b %ERRORLEVEL%
)
exit /b 0

:check_toolexe
if not exist "%_toolFullPath%" (
    echo '%_toolExe%' not found in '%_toolPath%'; PATH not updated
    exit /b 200
)
echo %_toolExe% installed in '%_toolPath%'; updating PATH
%_echo% set PATH=%PATH%;%_toolPath%
:end_check_toolexe
exit /b 0

:set_error_info
set _exitCode=%1
set _fatalMsg=%~2
exit /b 0

:fatal
echo FATAL: [%_exitCode%] %_fatalMsg%
exit /b %_exitCode%

:echo_action
set _msgId=ACTION_
goto :echo_time_message
:echo_info
set _msgId=INFO___
goto :echo_time_message
:echo_time_message
set _time=%TIME:~,8%
set _time=%_time: =0%
set _msg=[%_time% %_msgId%] %*
goto :echo_message
:echo_message
echo %_msg%
set _msgId=& set _msg=& set _time=
goto :eof

:done
exit /b 0
