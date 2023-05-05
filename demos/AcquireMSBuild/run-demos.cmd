@echo off
@setlocal enabledelayedexpansion

set PROMPT=($T) [$+$P]$S
color 60
goto init

:usage
echo usage: %_name% [OPTIONS]
echo.
echo OPTIONS:
echo.
echo ^  DEMOS               List of demos to run (options=%_listDemos%; default=all)
echo ^  -dir:{DEMO-ROOT}    Copies the demo tree to {DIR} [default=%__demoRootDefault%]
echo.
exit /b -1

:init
call :initialize
rem TODO: add usage

:getargs
set _demoRoot=%~1

:start

@rem Begin output
call :echo_info Running '%$_command%' from '%CD%' at %DATE% %TIME%.
call :echo_info Logfile is '%$logfile%'

@rem Validate inputs
if "%_demoRoot%" == "" set _demoRoot=%_demoRootDefault%
if exist "%_demoRoot%" set $_errorCode=100& call :fatal_error "directory '%_demoRoot%' already exists" & exit /b !$_errorCode!

@rem Execute actions

:copy_demo
rem Copy the demo directory to a temporary location. 
call :echo_action Copying demo directory tree to '%_demoRoot%'...
set $_cmdT=robocopy /MIR "%~dp0" "%_demoRoot%"
call :echo_command - robocopy
call %$_cmdT%
if errorlevel 1 set $_errorCode=%ERRORLEVEL%& call :fatal_error "copying to '%_demoRoot%' failed " & exit /b !$_errorCode!

pushd "%_demoRoot%"
call :echo_action Copying CatalogExtractionTool package...
set $_cmdT=copy /y "%_srcCatXToolZip%" "%_demoRoot%\Tools\CatalogExtraction\"
call :echo_command - copy
call %$_cmdT%

:run_demos
call :run_demo vcpkg vcpkg1
call :run_demo CatalogExtraction cx1
call :run_demo CloudBuild cb1
call :run_demo VSBuildTools vs1
popd

:summary
call :echo_info Done.

goto :done

@rem Script-specific functions

:initialize
@rem Common variables
set $_name=%~n0
set $_command='%_name%'
if "%*" NEQ "" set _command='%_name% %*'
call :get_timestamp
@rem Logging variables
set $_logBase=%_name%
set $_logDir=%USERPROFILE%\Temp\Logs\AcquireMSBuild-Demos\%_logBase%.%$_timestamp%
set $_logFile=%$_logDir%\%_name%.full.log
@rem Script-specific vars
set _demoRootDefault=C:\Temp
set _demoRoot=
set _listDemos=CatalogExtraction CloudBuild vcpkg VSBuildTools
set _srcCatXToolZip=\\markle-d1\c$\Users\markle\OneDrive - Microsoft\Work\ToolsetAcquisition\CatalogExtraction\Demo\Tools\CatalogExtraction\CatalogExtractionTool-3.6.28.zip
exit /b 0

:run_demo
setlocal
set _demoID=%~1
set _demoDir=%~2
if "%_demoID%" == "" set _errorMsg=run_demo: no demo ID specified, cannot run demo& set _errorCode=-20& call :error & exit /b !_errorCode!
if "%_demoDir%" == "" set _errorMsg=run_demo: no demo directory specified, cannot run demo& set _errorCode=-21& call :error & exit /b !_errorCode!
set _outputLog=%$_logDir%\output.%_demoID%.%_timestamp%.log
pushd "%_demoRoot%"
call :echo_info Running %_demoID% demo...
call :echo_action - cleaning demo tree...
call clean-demo.cmd >> %_outputLog% 2>&1
call :echo_action - cloning solution into directory '%_demoDir%'...
call clone-repo.cmd %_demoDir% >> %_outputLog% 2>&1
call :echo_action - bootstrapping %_demoID%...
call "%_demoRoot%\bootstrap-environment.cmd" %_demoID% >> %_outputLog% 2>&1
call :echo_action - build solution and run...
call "%_demoRoot%\build-and-run.cmd" >> %_outputLog% 2>&1
popd
endlocal
exit /b 0

@rem Utility functions

:get_timestamp
for /f "tokens=2,3,4 delims=/ " %%x in ('echo %DATE%') do set _yyyy=%%z& set _mm=%%x& set _dd=%%y
set _tt=%TIME:~,-3%
set _tt=%_tt::=-%
set $_timestamp=%_yyyy%-%_mm%-%_dd%-%_tt%
exit /b 0

:echo_error
set _msdId=ERROR__
:echo_command
set _msgId=COMMAND
goto :echo_time_message
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
if "%_msgID%" == "COMMAND" if "%$_cmdT%" NEQ "" set _msg=%_msg% (%$_cmdT%)
if "%$_logFile%" NEQ "" echo %_msg%>>"%$_logFile%"
set _msgId=& set _msg=& set _time=
goto :eof

:done



