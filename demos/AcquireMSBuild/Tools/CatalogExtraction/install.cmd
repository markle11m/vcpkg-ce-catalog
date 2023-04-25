@echo off

:init
set _toolZip=CatalogExtractionTool-3.6.28.zip
set _toolPath=%~dp0Bin
set _toolExe=CatalogExtraction.exe
set _toolFullPath=%_toolPath%\%_toolExe%
set _echo= 
set _dops=powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None

where %_toolExe% >nul 2>&1
if errorlevel 1 (
    call :check_toolpath
    if errorlevel 1 (
        call :expand_toolzip
        if errorlevel 1 set _exitCode=%ERRORLEVEL%& set _fatalMsg=unable to install %_toolExe% & goto :fatal
    )
    call :check_toolpath
    if errorlevel 1 set _exitCode=%ERRORLEVEL%& set _fatalMsg=tools directory '%_toolPath%' not found & goto :fatal
    call :check_toolexe    
    if errorlevel 1 set _exitCode=%ERRORLEVEL%& set _fatalMsg=unable to find '%_toolExe%' & goto :fatal
    where %_toolExe% >nul 2>&1
    if errorlevel 1 set _exitCode=300& set _fatalMsg=internal error: PATH not updated correctly & goto :fatal
) else (
    call :echo_info %_toolExe% already on PATH
)

goto :done

:fatal
echo FATAL: [%_exitCode%] %_fatalMsg%
exit /b %_exitCode%

:check_toolpath
if not exist "%_toolPath%" exit /b 1
exit /b 0

:check_toolexe
if not exist "%_toolFullPath%" (
    echo '%_toolExe%' not found in '%_toolPath%'; PATH not updated
    exit /b 200
)
call :echo_info %_toolExe% installed in '%_toolPath%'; updating PATH
%_echo% set PATH=%PATH%;%_toolPath%
:end_check_toolexe
exit /b 0

:expand_toolzip
if not exist "%~dp0%_toolZip%" (
    echo ERROR: '%_toolZip%' not found
    exit /b 100
)
call :echo_action Expanding %_toolZip% file into '%_toolPath%'...
%_echo% %_dops% Expand-Archive "%~dp0%_toolZip%" "%_toolPath%"
if not exist "%_toolPath%" (
    echo ERROR: expanding '%_toolZip%' did not create '%_toolPath%'
    exit /b 101
)
:end_expand_toolzip
exit /b 0

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
