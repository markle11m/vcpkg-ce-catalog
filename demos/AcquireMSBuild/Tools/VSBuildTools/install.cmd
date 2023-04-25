@echo off

:init
set _toolZip=
set _toolURL=https://download.visualstudio.microsoft.com/download/pr/0bb9a5f5-5481-4efe-92ab-cca29a90fa5e/adbfb904ddfc115ae7df00098df92d4e545a5eb062ffea8a93f7b8df8d509ff3/vs_BuildTools.exe
set _toolPath=%~dp0Bin
set _toolExe=vs_BuildTools.exe
set _toolFullPath=%_toolPath%\%_toolExe%
set _echo= 
set _dops=powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None

rem echo on
where %_toolExe% >nul 2>&1
if errorlevel 0 if not errorlevel 1 (
    echo found '%_toolExe%' on PATH:
    for /f "tokens=1*" %%p in ('where.exe %_toolExe%') do @echo ^  %%p %%q
    goto :done
)

if exist %_toolPath% goto :check_installer_downloaded

:create_tools_directory
echo Creating tools directory '%_toolPath%'...    
md "%_toolPath%" >nul 2>&1
if errorlevel 1 call :set_error_info %ERRORLEVEL% "unable to create directory '%_toolPath%'" & goto :fatal

:check_installer_downloaded
if exist %_toolFullPath% (
    echo Found '%_toolExe%' in '%_toolPath%'; updating PATH...
    set PATH=%PATH%;%_toolPath%
    goto :done
)

:download_installer
echo Downloading installer '%_toolExe%'...
pushd %_toolPath%
curl -LO %_toolURL%
popd
if errorlevel 1 call :set_error_info %ERRORLEVEL% "unable to download %_toolExe%" & goto :fatal
if not exist %_toolFullPath% call :set_error_info 1001 "internal error" & goto :fatal
call :echo_action Adding '%_toolExe%' directory to PATH...
set PATH=%PATH%;%_toolPath%

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
