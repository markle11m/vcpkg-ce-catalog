@echo off

:init
set _name=%~n0
set SET_DEMO_ENVIRONMENT=-quiet
call %~dp0set-demo-environment.cmd

:getargs
set _demoID=%~1

:start
set _fValidDemo=false
for %%d in (%$_demoList%) do (
	if /I "%%d" == "%_demoID%" set _fValidDemo=true
)
if "%_fValidDemo%" == "false" (
	echo %_name%: ERROR: invalid demo ID '%_demoID%'
	exit /b 1
)

echo Bootstrapping MSBuild environment using %_demoID%...
set _cmdT=%$_demoToolsRoot%\MSBuild\%_demoID%\install.cmd
call %_cmdT%
if /I "%_demoID%" NEQ "vcpkg" call %$_demoToolsRoot%\vcpkg\install.cmd

set PROMPT={demo:%_demoID%} ($T) [$+$P]$S
set DEMO_ID=%_demoID%

:done
rem Clear temporary environment variables
for %%v in (_cmdT) do set _%%v=
