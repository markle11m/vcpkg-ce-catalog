@echo off

:init
set $_vcpkgInstallDir=%USERPROFILE%\.vcpkg
set $_cmdVcpkg=%~dp0vcpkg-init.cmd
for %%i in (yes y true) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=true
for %%i in (no n false) do @if /I "%_PAUSE%" == "%%i" set _pauseBeforeCommands=false
if "%_pauseBeforeCommands%" == "" set _pauseBeforeCommands=true

:start
call :bootstrap_vs
goto :done

:bootstrap_vs
call :echo Bootstrapping VisualStudio...
rem Use internal dogfood build
set $cmd=start https://aka.ms/vs/17/intpreview/vs_community.exe
call :run_command - Downloading latest internal preview VS Community installer...
call :echo - To bootstrap, run the installer with no workloads selected
call :echo - with only the C++ core desktop features selected.
call :echo - Run 'appwiz.cpl' to Launch Programs and Features to verify VS installation...
pause
echo [%TIME%] Finish bootstrapping Visual Studio.
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
echo [%TIME%] %*
exit /b 0

:done
exit /b 0
