@echo off
@setlocal enabledelayedexpansion
goto :init

:usage
echo usage: %~nx0 ACTION [ARCH]
echo.
echo ^  ACTION      one of {clean build rebuild run}
echo ^  ARCH        target architecture to build, one of {x64, x86}
rem echo ^  CL_OPTIONS  quoted string containing additional compiler options, e.g. "/O2 /Zi"
echo.

:init
set _action=%1
set _targetArch=%2
set $_MSBuildExe=msbuild.exe

for %%a in (clean build rebuild run reset) do (
    if "%_action%" == "%%a" goto :check_targetArch
)
echo %~n0: invalid action '%_action%'& exit /b 1

:check_targetArch
if "%_targetArch%" == "" (
    echo INFO: no Platform specified - using x64
    set _targetArch=x64
) 
set _fValidArch=false
rem Note: the msbuild project/solution does not currently contain arm or arm64 configurations
for %%a in (x64 x86) do (
    set _fValidArch=true
)
if /I "%_fValidArch%" == "false" (
    echo invalid Platform architecture '%_targetArch%' - running x64 instead
    set _targetArch=x64
)
set _archOutputDir=!_targetArch!
if /I "%_targetArch%" == "x86" set _archOutputDir=Win32

:start

for %%i in (yes y true) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=true
for %%i in (no n false) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=false
if "%_pauseBeforeCommands%" == "" set _pauseBeforeCommands=true

set _msbuildConfig=Release
set _msbuildTarget=%_action%
goto :%_action%

:rebuild
echo *** Rebuilding for %_targetArch%... 
goto :common
:build
echo *** Building for %_targetArch%... 
goto :common
:clean
echo *** Cleaning build directory...
goto :common
:common
if "%$_MSBuildExe%" == "" (
    echo ERROR: unable to build - variable $_MSBuildExe not set
    echo - To install MSBuild, please run the install_vs command to download the Visual Studio installer
    echo - and install the Desktop C++ workload with only the C++ core desktop features option selected.
    echo - Then re-run the bootstrap command to update the environment.
    exit /b 1
)
set $_MSBuildArgs=/t:%_msbuildTarget% /p:Configuration=%_msbuildConfig% /p:Platform=%_targetArch% /p:EnableExperimentalVcpkgIntegration=true
echo Running %_msbuildTarget% [command=msbuild.exe %$_MSBuildArgs%]
if /I "%_pauseBeforeCommands%" == "true" pause
"%$_MSBuildExe%" %$_MSBuildArgs%
goto :done

:run
set $_exeFile=.\Outputs\%_archOutputDir%\%_msbuildConfig%\ConsoleApplication.exe
if not exist %$_exeFile% (
    echo ERROR: unable to run - '%$_exeFile%' does not exist
    exit /b 1
)
echo Running '%$_exeFile%'...
if /I "%_pauseBeforeCommands%" == "true" pause
%$_exeFile%
goto :done

:reset
set $_outputDir=.\Outputs\%_archOutputDir%
if not exist %$_outputDir% (
    echo INFO: no output directory to delete
    goto :done
)
set $cmd=rd /s /q %$_outputDir%
echo Deleting output directory [%$cmd%]...
%$cmd%

:done
exit /b 0
