@echo off
@setlocal enabledelayedexpansion

:start
set SET_DEMO_ENVIRONMENT=-quiet
set SET_DEMO_ENVIRONMENT_CLEAN=true
call %~dp0set-demo-environment.cmd

call :remove_directory "%$_demoTestRoot%"
call :remove_directory "%$_demoToolsRoot%\MSBuild\CatalogExtraction\VSInstallDir"
call :remove_directory "%$_demoToolsRoot%\MSBuild\CloudBuild\CloudBuild.Tools.MSBuild"
call :remove_vs_directory "%$_demoToolsRoot%\MSBuild\VSBuildTools\VSInstallDir"
call :remove_directory "%$_demoToolsRoot%\CatalogExtraction\Bin"
call :remove_directory "%$_demoToolsRoot%\Drop\Drop.App"
call :remove_directory "%$_demoToolsRoot%\NuGet\Bin"
call :remove_directory "%$_demoToolsRoot%\VSBuildTools\Bin"
call :remove_file "%$_demoToolsRoot%\vcpkg\vcpkg-init.cmd"
rem call :remove_directory "%USERPROFILE%\.vcpkg"

goto :done

:remove_file
set _fileT=%~1
if not exist "%_fileT%" exit /b -1
set _cmdT=del "%_fileT%"
call :echo_action Removing file '%_fileT%'...
call %_cmdT%
exit /b %ERRORLEVEL%

rem Need to handle the VS installation directory specially since operations on it require elevation.
rem Instead of deleting the directory, run the VS installer to uninstall it.
:remove_vs_directory
set _dirT=%~1
if not exist %_dirT% exit /b -1
set _installerT="%$_demoToolsRoot%\VSBuildTools\Bin\vs_BuildTools.exe"
if not exist %_installerT% goto :remove_vs_directory_manually
set _exitCode=%ERRORLEVEL%
set _cmdT=%_installerT% uninstall --installpath "%_dirT%" --passive --wait
call :echo_action Removing directory '%_dirT%' using VS Installer...
call %_cmdT%
goto :end_remove_vs_directory
:remove_vs_directory_manually
echo No VS installer found; deleting directory manually (with elevation)
echo NYI - please open an Administrator command prompt and run 'rd /s /q "%_dirT%"'
exit /b 102
:end_remove_vs_directory
exit /b %_exitCode%

:remove_directory
set _dirT=%~1
if not exist "%_dirT%" exit /b -1
set _cmdT=rd /s /q "%_dirT%"
call :echo_action Removing directory '%_dirT%'...
call %_cmdT%
exit /b %ERRORLEVEL%

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
rem Clear temporary environment variables
rem for %%v in () do set _%%v=
for /f "delims==" %%v in ('set SET_DEMO_ENVIRONMENT') do set %%v=
