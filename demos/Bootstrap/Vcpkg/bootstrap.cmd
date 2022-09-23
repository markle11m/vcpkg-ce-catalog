@echo off

:init
set $_vcpkgInstallDir=%USERPROFILE%\.vcpkg
set $_cmdVcpkg=%~dp0vcpkg-init.cmd
for %%i in (yes y true) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=true
for %%i in (no n false) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=false
if "%_pauseBeforeCommands%" == "" set _pauseBeforeCommands=true

:start
call :bootstrap_vcpkg
goto :done

:bootstrap_vcpkg
pushd .
echo [%TIME%] Start Bootstrap...
set $_exitCode=0

:install_vcpkg
call :echo Installing vcpkg...
if exist "%$_vcpkgInstallDir%" if exist .\vcpkg-init.cmd (
    echo - Vcpkg is already installed
    goto :end_install_vcpkg
)
set $cmd=curl -LO https://aka.ms/vcpkg-init.cmd
rem set $cmd=curl -LO https://github.com/microsoft/vcpkg-tool/releases/download/2022-09-20/vcpkg-init.cmd
call :run_command - Downloading vcpkg...
if exist .\vcpkg-init.cmd (
    set $cmd=.\vcpkg-init.cmd
    call :run_command - Running vcpkg-init in %CD%...
)
:end_install_vcpkg

:install_empty_manifest
echo Activating empty manifest to bootstrap core dependencies...
set $cmd=%$_cmdVcpkg% activate
call :run_command - activate 

:end_bootstrap
echo [%TIME%] Finish Bootstrap.
popd
exit /b %$_exitCode%

:install_vs
call :echo Installing VS...
rem Use internal dogfood build
set $cmd=start https://aka.ms/vs/17/intpreview/vs_community.exe
call :run_command - Downloading latest internal preview VS Community installer...
call :echo - To install MSBuild, run the installer and select the Desktop C++ workload
call :echo - with only the C++ core desktop features selected.
call :echo - Run 'appwiz.cpl' to Launch Programs and Features to verify VS installation...
echo [%TIME%] Finish Installing VS.
exit /b 0

:install_vcrt
echo [%TIME%] Installing VC runtimes...
if exist "%USERPROFILE%\Downloads\vc_redist.*.exe" (
    set $cmd=del "%USERPROFILE%\Downloads\vc_redist.*.exe"
    call :run_command - deleting existing vc_redist downloads...
)
call :echo - downloading latest VC runtime (vc_redist) installers...
for %%a in (x86 x64) do start https://aka.ms/vs/17/release/vc_redist.%%a.exe
pause
call :echo - running latest VC runtime installers...
for %%a in (x86 x64) do "%USERPROFILE%\Downloads\vc_redist.%%a.exe" /install /q
call :echo - check Programs and Features to verify install...
start appwiz.cpl
echo [%TIME%] Finish Installing VC runtimes.
exit /b 0

:run_command
rem exitCode run_command(message) [$cmd]
rem Prints the message+command, runs the command (in $cmd), returns the exit code from the command
set _cmdToEcho=%$cmd%
for /f "usebackq tokens=1*" %%i in (`echo %$cmd%`) do if "%%i" == "%$_cmdVcpkg%" set _cmdToEcho=vcpkg %%j
echo %* [command: %_cmdToEcho%]
if /I "%_pauseBeforeCommands%" == "true" pause
call %$cmd%
set _exitCode=%ERRORLEVEL%
for %%i in (_cmdToEcho _pauseBeforeCommands) do set %%i=
exit /b %_exitCode%

:echo
title %*
echo [%TIME%] %*
exit /b 0

:done
exit /b 0
