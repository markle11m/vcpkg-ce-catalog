@echo off

:init
set _toolID=VSBuildTools
set _toolExe=vs_BuildTools.exe
set _vsInstallDir=%~dp0
set _vsInstallDir=%_vsInstallDir:~,-1%\VSInstallDir
set _msbuildPath=%_vsInstallDir%\MSBuild\Current\Bin\amd64
set _msbuildFullPath=%_msbuildPath%\MSBuild.exe
set _echo= 
set _dops=powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None

if exist %_vsInstallDir% (
    if exist %_msbuildFullPath% (
        call :echo_info Found existing installation; adding MSBuild.exe to front of PATH...
        set PATH=%_msbuildPath%;%PATH%
        exit /b 0
    )
    call :set_error_info 1002 "incomplete VS installation found; please remove '%_vsInstallDir' and retry"
    goto :fatal
)

call %$_demoToolsRoot%\%_toolID%\install.cmd
rem where %_toolExe%
rem pause
where %_toolExe% >nul 2>&1
if errorlevel 1 call :set_error_info 100 "'%_toolExe%' not found on path" & goto :fatal

:run_installer
call :echo_action Using '%_toolExe%' to install MSBuild...
set _argAddComponents=--add Microsoft.Component.MSBuild --add Microsoft.VisualStudio.Component.VC.CoreBuildTools
set _cmdT=%_toolExe% %_argAddComponents% --path install="%_vsInstallDir%" --passive --wait
echo call %_cmdT%
call %_cmdT%
set PATH=%_vsInstallDir%\MSBuild\Current\Bin\amd64;%PATH%

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

:create_toolpath

:check_toolexe
if not exist "%_toolFullPath%" (
    echo '%_toolExe%' not found '%_toolPath%'; PATH not updated
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
