@echo off
@setlocal enabledelayedexpansion

set PROMPT=($T) [$+$P]$S
goto :init

:usage
echo usage: %$_name% [OPTIONS]
echo.
echo OPTIONS:
echo.
echo ^  DEMOS               List of demos to run (options=%_listDemoOptions%; default=%_listDemosDefault%)
echo ^  -dir:{DEMO-ROOT}    Copies the demo tree to {DIR} [default=%__demoRootDefault%]
echo.
exit /b -1

:init
call :initialize
if not exist "%$_logDir%" (
    md "%$_logDir%" >nul 2>&1
    if errorlevel 1 set $_errorCode=99& call :fatal_error unable to create log directory '%$_logDir%' & exit /b !$_errorCode!
)
rem TODO: add usage

:getargs
set _argT=%~1
if "%_argT%" == "" goto :start
if "%_argT:~,5%" == "-dir:" set _demoRoot=%_argT:~5%& goto :nextarg
set _listDemos=%_listDemos% %_argT%
:nextarg
shift
goto :getargs

:start

@rem Begin output
call :echo_info Running '%$_command%' from '%CD%' at %DATE% %TIME%.
call :echo_info Logfile is '%$_logFile%'

@rem Validate inputs
if "%_demoRoot%" == "" set _demoRoot=%_demoRootDefault%
if "%_listDemos%" == "" set _listDemos=%_listDemosDefault%
if exist "%_demoRoot%" (
    set _altDemoSuffix=%TIME::=%
    set _altDemoSuffix=!_altDemoSuffix:.=!
    set _altDemoRoot=%_demoRoot%-!_altDemoSuffix!
    call :echo_warning directory '%_demoRoot%' exists
    call :yesnoquit "Would you like to use '!_altDemoRoot!' instead?"
    if not errorlevel 1 (
        set $_errorCode=98& call :fatal_error directory '%_demoRoot%' already exists & exit /b !$_errorCode!
    )
    set _demoRoot=!_altDemoRoot!
)

for %%d in (%_listDemos%) do (
    set _fValidOption=false
    for %%o in (%_listDemoOptions%) do (
        if /I "%%d" == "%%o" set _fValidOption=true
    )
    if "!_fValidOption!" == "true" (
        set _listDemosToRun=!_listDemosToRun! %%d
    ) else (
        call :echo_warning '%%d' is not a supported demo, ignoring it
    )
)

@rem Execute actions

:copy_demo
rem Copy the demo directory to a temporary location. 
call :echo_action Copying demo directory tree to '%_demoRoot%'...
set $_cmdT=robocopy /MIR "%_demoSourceRoot%" "%_demoRoot%"
call :echo_command - robocopy
call %$_cmdT%
if errorlevel 2 set $_errorCode=%ERRORLEVEL%& call :fatal_error copying to '%_demoRoot%' failed & exit /b !$_errorCode!
pushd "%_demoRoot%"
call :echo_action Copying CatalogExtractionTool package...
set $_cmdT=copy /y "%_srcCatXToolZip%" "%_demoRoot%\Tools\CatalogExtraction\"
call :echo_command - copy package
call %$_cmdT%

:run_demos
for %%d in (%_listDemosToRun%) do (
    call :run_demo %%d
)
popd

:summary
call :echo_info Done.

goto :done

@rem Script-specific functions

:initialize
@rem Common variables
set $_name=%~n0
set $_command=%$_name%
if "%*" NEQ "" set _command=%$_name% %*
call :get_timestamp
@rem Logging variables
set $_logBase=%$_name%
set $_logDir=%USERPROFILE%\Temp\Logs\AcquireMSBuild-Demos\%$_logBase%.%$_timestamp%
set $_logFile=%$_logDir%\%$_name%.full.log
@rem Script-specific vars
set _demoRootDefault=C:\Demo
set _demoRoot=
set _demoSourceRoot=%~dp0
set _demoSourceRoot=%_demoSourceRoot:~,-1%
set _listDemoOptions=CatalogExtraction CloudBuild vcpkg VSBuildTools
set _listDemosToRun=
set _listDemosDefault=CatalogExtraction CloudBuild VSBuildTools
set _listDemos=
set _srcCatXToolZip=\\markle-d1\c$\Users\markle\OneDrive - Microsoft\Work\ToolsetAcquisition\CatalogExtraction\Demo\Tools\CatalogExtraction\CatalogExtractionTool-3.6.28.zip
exit /b 0

:run_demo
setlocal
set _demoID=%~1
set _demoDir=%~2
if "%_demoID%" == "" set $_errorCode=-100& call :echo_error directory no demo ID specified, cannot run demo & exit /b !$_errorCode!
if "%_demoDir%" == "" set _demoDir=%_demoID%
pushd "%_demoRoot%"
call :echo_info Running %_demoID% demo...
call :set_demo_color_scheme %_demoID%
call :echo_action - cleaning demo tree...
call clean-demo.cmd 
call :echo_action - cloning solution into directory '%_demoDir%'...
call clone-repo.cmd %_demoDir%
call :echo_action - bootstrapping %_demoID%...
call "%_demoRoot%\bootstrap-environment.cmd" %_demoID%
call :echo_action - build solution and run...
call "%_demoRoot%\build-and-run.cmd"
popd
endlocal
exit /b 0

:set_demo_color_scheme
set _idT=%~1
set _demoColorSchemes=CatalogExtraction:30 CloudBuild:20 vcpkg:60 VSBuildTools:A0
for %%s in (%_demoColorSchemes%) do (
    for /f "tokens=1,2 delims=:" %%i in ('echo %%s') do (
        if /I "%%i" == "%_idT%" color %%j
    )
)
exit /b 0

@rem Utility functions

:get_timestamp
for /f "tokens=2,3,4 delims=/ " %%x in ('echo %DATE%') do set _yyyy=%%z& set _mm=%%x& set _dd=%%y
set _tt=%TIME:~,-3%
set _tt=%_tt::=-%
set $_timestamp=%_yyyy%-%_mm%-%_dd%-%_tt%
exit /b 0

:fatal_error
set _msgId=FATAL__& set _msgErrCode=fatal error %$_errorCode%:& goto :echo_time_message
:echo_error
set _msdId=ERROR__& set _msgErrCode=error %$_errorCode%:& goto :echo_time_message
:echo_warning
set _msgId=WARNING& goto :echo_time_message
:echo_command
set _msgId=COMMAND& set _msgShowCommand=true& goto :echo_time_message
:echo_action
set _msgId=ACTION_& goto :echo_time_message
:echo_info
set _msgId=INFO___& goto :echo_date_message
:echo_time_message
set _msgTimestamp=%TIME:~,8%
set _msgTimestamp=%_msgTimestamp: =0%& goto :echo_message
:echo_date_message
set _msgTimestamp=%DATE:~4,6%%DATE:~12%& goto :echo_message
:echo_message
set _msg=%*
if "%_msgErrCode%" NEQ "" set _msg=%_msgErrCode% %_msg%
if "%_msgTimestamp%" NEQ "" set _msg=[%_msgTimestamp% %_msgId%] %_msg%
if "%_msgShowCommand%" == "true" set _msg=%_msg% (%$_cmdT%)
echo %_msg%
if "%$_logFile%" NEQ "" echo %_msg%>>"%$_logFile%"
for /f "tokens=1 delims==" %%v in ('set _msg') do set %%v=
goto :eof

:yesnoquit
@rem ;; int yesnoquit(promptString)
@rem ;; Echoes 'promptString [y/n/q]' to console and reads the user response.
@rem ;; Returns 1 for yes, 0 for no, -1 for quit; default is yes.
@rem ;; Looks only at the first character of the response.
set _promptT=%~1
set _responseT=
set /P _responseT=%_promptT% [y/n/q] 
if not defined _responseT exit /b 1
if /I "%_responseT:~0,1%" == "y" exit /b 1
if /I "%_responseT:~0,1%" == "n" exit /b 0
if /I "%_responseT:~0,1%" == "q" exit /b -1
exit /b 1

:done



