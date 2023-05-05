@echo off

:init
set _name=%~n0
call %~dp0set-demo-environment.cmd -quiet

:getargs
set _projectRoot=%~1

:start
if "%_projectRoot%" == "" set _projectRoot=%DEMO_PROJECT%
if "%_projectRoot%" == "" echo %_name%: ERROR: project directory not specified& exit /b 1
if not exist %$_demoTestRoot%\%_projectRoot% (
	echo %_name%: ERROR: invalid test repo '%_projectRoot%' specified
	exit /b 1
)

pushd %$_demoTestRoot%\%_projectRoot%
set _argVcpkgProps=/p:EnableVcpkgArtifactsIntegration=True /p:DisableRegistryUse=True /p:CheckMSVCComponents=False
set _argVcpkgProps=/p:UseVcpkg=True
set _argsVerbosity=/clp:minimal
set _argExeProps=/p:RuntimeLibrary=MultiThreaded /p:Configuration=Release
set _cmdT=msbuild.exe /m /t:rebuild %_argsVerbosity% %_argExeProps% %_argVcpkgProps% 
echo.
call :echo_info Building project...
call :echo_info - command: %_cmdT%
echo.
call %_cmdT%

set _exe=".\x64\Release\ConsoleApplication1.exe"
if exist %_exe% (
	echo.
	call :echo_info Running exe...
	echo.
	call %_exe%
	echo.
)

popd

goto :done

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
rem Clear temporary environment variables
rem for %%v in () do set _%%v=
