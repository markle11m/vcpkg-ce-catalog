@echo off

:getargs
set _testDir=%1
if "%_testDir%" == "" echo ERROR: please provide name of subdirectory to clone into (e.g., Foo) & goto :done

:start
set SET_DEMO_ENVIRONMENT=-quiet
call %~dp0set-demo-environment.cmd

if not exist %$_demoTestRoot% (
	echo Creating '%$_demoTestRoot%' testing root directory...
	md %$_demoTestRoot% >nul 2>&1
)

set _targetDir=%$_demoTestRoot%\%_testDir%
echo Cloning project '%$_demoRepo%' into '%_targetDir%'...
xcopy /sdvci %$_demoSourceRoot%\%$_demoRepo% %_targetDir%
pushd %_targetDir%
set DEMO_PROJECT=%_testDir%

:done
rem Clear temporary environment variables
rem for %%v in () do set _%%v=
