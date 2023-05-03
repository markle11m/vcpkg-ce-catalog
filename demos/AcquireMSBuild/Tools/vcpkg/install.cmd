@echo off

:init
set _toolZip=
set _toolURL=https://aka.ms/vcpkg-init.cmd
set _toolPath=%~dp0
set _toolPath=%_toolPath:~,-1%
set _toolExe=vcpkg-init.cmd
set _toolFullPath=%_toolPath%\%_toolExe%
set _echo= 
set _dops=powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None

if defined VCPKG_ROOT if exist "%VCPKG_ROOT%\%_toolExe%" (
    doskey /macros | findstr /i /c:"vcpkg=" >nul 2>&1
    if errorlevel 1 (
        call :echo_info Found vcpkg installation...
        call :install_into_shell "%VCPKG_ROOT%\%_toolExe%"
        if errorlevel 1 goto :fatal
    ) else (
        call :echo_info No action taken; vcpkg already installed and integrated into this shell
    )
    goto :success
)

where %_toolExe% >nul 2>&1
if errorlevel 0 if not errorlevel 1 (
    call :echo_info Found '%_toolExe%' on PATH:
    for /f "tokens=1*" %%p in ('where.exe %_toolExe%') do @call :echo_info - %%p %%q
    call :install_into_shell "%_toolExe%"
    if errorlevel 1 goto :fatal
    goto :success
)

:check_installer_downloaded
if exist %_toolFullPath% (
    call :echo_info Found '%_toolExe%' in '%_toolPath%'; integrating into shell...
    call :install_into_shell "%_toolFullPath%"
    if errorlevel 1 goto :fatal
    goto :success
)

:download_installer
call :echo_action Downloading installer '%_toolExe%'...
pushd %_toolPath%
curl -LO %_toolURL%
popd
if errorlevel 1 call :set_error_info %ERRORLEVEL% "unable to download %_toolExe%" & goto :fatal
if not exist %_toolFullPath% call :set_error_info 1001 "internal error" & goto :fatal

:run_installer
call :install_into_shell "%_toolFullPath%"
if errorlevel 1 goto :fatal
goto :success

goto :done

:success
call :echo_info Installation of vcpkg and shell integration complete.
exit /b 0

:install_into_shell
set _cmdT=%~1
call :echo_action Installing vcpkg into current shell ("%_cmdT%")...
call "%_cmdT%"
if "%VCPKG_ROOT%" == "" call :set_error_info 300 "vcpkg installation into shell failed" & exit /b 300
call :echo_action Adding vcpkg.exe to PATH...
set PATH=%PATH%;%VCPKG_ROOT%
exit /b 0

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

:expand_toolzip
if not exist "%~dp0%_toolZip%" (
    echo ERROR: '%_toolZip%' not found
    exit /b 100
)
echo Expanding %_toolZip% file into '%_toolPath%'...
%_echo% %_dops% Expand-Archive %_toolsZip% %_toolPath%
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
