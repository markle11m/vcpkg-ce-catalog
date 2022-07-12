@echo off

:init
if "%$_DEMO_ENVIRONMENT_INITIALIZED%" NEQ "" goto :skip_demo_env_init
call %$_vcpkgDemoRoot%\set-demo-environment.cmd CommandLine-MSBuild
set $_DEMO_ENVIRONMENT_INITIALIZED=1
set $_envvarList=VCPKG Enable INC LIB VC_
doskey reset_demo_env=set $_DEMO_ENVIRONMENT_INITIALIZED=
:skip_demo_env_init
set $_actionOptions=reset bootstrap acquire activate clean build
set $_validActivateTargets=x64 x86
set $_activateShowConfig=true
set $_action=
set $_actionArg=
set $_exitCode=
set $_cmdVcpkg=.\vcpkg-init.cmd

:process_args
set $_action=%1
set $_actionArg=%2
setlocal enabledelayedexpansion
set _fIsValidAction=false
for %%o in (%$_actionOptions%) do (
    if /I "%$_action%" == "%%o" set _fIsValidAction=true
)
if "!_fIsValidAction!" == "false" (
    echo ERROR: invalid action '%_action%' specified
    exit /b 1
)
endlocal

:start
call :%$_action% %$_actionArg%
goto :done

:reset
pushd .
echo [%TIME%] Start Reset...
set $_exitCode=0
set $cmd=%$_vcpkgDemoRoot%\reset-machine.cmd %$_vcpkgDemoName%
call :run_command - Running reset script...
set $_exitCode=%ERRORLEVEL%
echo [%TIME%] Finish Reset...
popd .
exit /b %$_exitCode%

:bootstrap
pushd .
echo [%TIME%] Start Bootstrap...
set $_exitCode=0

call :echo Installing Git...
call where.exe git.exe >nul 2>&1
if errorlevel 1 (
    set $cmd=start https://gitforwindows.org/
    call :run_command - Git not installed: please install from https://gitforwindows.org/
) else (
    echo - Git is already installed
)

call :echo Installing vcpkg...
if not exist "%$_vcpkgInstallDir%" (
    set $cmd=curl -LO https://aka.ms/vcpkg-init.cmd
    call :run_command - Downloading vcpkg...
    if exist .\vcpkg-init.cmd (
        set $cmd=.\vcpkg-init.cmd
        call :run_command - Running vcpkg-init in %CD%...
    )
) else (
    echo - Vcpkg is already installed
)

:install_vcpkg_ce_catalog
call :echo Installing vcpkg-ce-catalog (private)...
if not exist %$_vcpkgCatalogRoot% (
    rem git clone https://github.com/markle11m/vcpkg-ce-catalog.git %$_vcpkgCatalogRoot%
    set $cmd=git clone https://github.com/olgaark/vcpkg-ce-catalog.git %$_vcpkgCatalogRoot%
    call :run_command - Cloning...
    pushd %$_vcpkgCatalogRoot%
    echo - Updating to current branch...
    set $cmd=git checkout msvc-experiments
    call :run_command - - checkout...
    set $cmd=git pull
    call :run_command - - pull...
    popd
) else (
    echo - Updating to current branch...
    pushd %$_vcpkgCatalogRoot%
    set $cmd=git checkout -f
    call :run_command - - 
    set $cmd=git pull
    call :run_command - - 
    set $cmd=git checkout msvc-experiments
    call :run_command - - 
    set $cmd=git pull
    call :run_command - - 
    popd
)

:update_catalog
rem set $cmd=%$_cmdVcpkg% z-ce regenerate %$_vcpkgCatalogRoot%
rem call :run_command Updating catalog index...

:install_empty_manifest
echo Activating empty manifest to bootstrap core dependencies...
set $cmd=copy vcpkg-configuration.json-bootstrap vcpkg-configuration.json
call :run_command - copy bootstrap manifest...
set $cmd=%$_cmdVcpkg% 

call :run_command - activate 

:set_environment
call :echo Setting bootstrapped demo environment...
call setenv.cmd

:end_bootstrap
echo [%TIME%] Finish Bootstrap...
popd
exit /b %$_exitCode%

:acquire
pushd .
echo [%TIME%] Start Acquisition...
set $_exitCode=0
echo No action taken, acquisition will be done as part of the activation step.
:end_acquire
echo [%TIME%] Finish Acquisition...
popd
exit /b %$_exitCode%

:activate
set $_vcpkgActivateTarget=%1
if "%$_vcpkgActivateTarget%" == "" (
    set $_vcpkgActivateTarget=x86
    goto :start_activation
)
for %%t in (%$_validActivateTargets%) do (
    if /I "%%t" == "%$_vcpkgActivateTarget%" goto :start_activation
)
echo ERROR: cannot activate invalid target '%$_vcpkgActivateTarget%'
exit /b 400
:start_activation
pushd .
echo [%TIME%] Start Activation (--target:%$_vcpkgActivateTarget%)...
set $_exitCode=0
setlocal enabledelayedexpansion
if "%$_activateShowConfig%" == "true" (
    set /P _responseT=- show vcpkg-configuration.json? [y/n] 
    if "!_responseT:~0,1!" == "y" (
        start notepad %$_vcpkgDemoDir%\Source\MySolution\vcpkg-configuration.json
        pause
    )
)
endlocal
set $cmd=copy vcpkg-configuration.json-demo %$_vcpkgDemoDir%\Source\MySolution\vcpkg-configuration.json
call :run_command Update solution to use demo manifest...
call :show_environment activated
echo No further action taken, activation is integrated with MSBuild and will be done as part of the build step.
:end_activate
echo [%TIME%] Finish Activation...
popd
exit /b %$_exitCode%

:clean
pushd .
echo [%TIME%] Start Clean...
set $_exitCode=0
setlocal
pushd %$_vcpkgDemoDir%\Source\MySolution
set _target=%1
if "%_target%" == "" set _target=%$_vcpkgActivateTarget%
call test-project.cmd clean %$_vcpkgActivateTarget%
popd
endlocal
:end_clean
echo [%TIME%] Finish Clean...
popd
exit /b %$_exitCode%

:build
pushd .
echo [%TIME%] Start Build and Run...
set $_exitCode=0
setlocal
pushd %$_vcpkgDemoDir%\Source\MySolution
set _target=%1
if "%_target%" == "" set _target=%$_vcpkgActivateTarget%
call buildit.cmd %$_vcpkgActivateTarget%
call runit.cmd %$_vcpkgActivateTarget%
popd
endlocal
:end_build
echo [%TIME%] Finish Build...
popd
exit /b %$_exitCode%

:echo
title %*
echo [%TIME%] %*
exit /b 0

:show_environment
echo Showing environment variables (%*)...
for %%e in (%$_envvarList%) do set %%e
exit /b 0

:run_command
rem exitCode run_command(message) [$cmd]
rem Prints the message+command, runs the command (in $cmd), returns the exit code from the command
echo %* [%$cmd%]
call %$cmd%
set _exitCode=%ERRORLEVEL%
exit /b %_exitCode%

:done
exit /b 0