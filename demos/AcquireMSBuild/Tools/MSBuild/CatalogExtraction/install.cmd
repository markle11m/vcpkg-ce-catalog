@echo off

:init
set _toolID=CatalogExtraction
set _toolExe=CatalogExtraction.exe
set _installDir=%~dp0VSInstallDir
set _configDir=%~dp0
set _configDir=%_configDir:~,-1%
set _msbuildPath=%_installDir%\MSBuild\Current\Bin\amd64
set _msbuildFullPath=%_msbuildPath%\MSBuild.exe

set _echo= 
set _dops=powershell -NoLogo -NoProfile -Noninteractive -ExecutionPolicy Unrestricted -InputFormat None

if exist %_installDir% (
    if exist %_msbuildFullPath% (
        call :echo_info Found existing installation; adding MSBuild.exe to front of PATH...
        set PATH=%_msbuildPath%;%PATH%
        exit /b 0
    )
    call :set_error_info 1002 "incomplete installation found; please remove '%_installDir' and retry"
    goto :fatal
)

call %$_demoToolsRoot%\%_toolID%\install.cmd
rem where %_toolExe%
rem pause
where %_toolExe% >nul 2>&1
if errorlevel 1 call :set_error_info 100 "'%_toolExe%' not found on path" & goto :fatal

:run_installer
call :echo_action "Using '%_toolExe%' to install MSBuild..."
set _channelManifestURL=https://aka.ms/vs/17/release.LTSC.17.4/channel
set _channelManifestID=VisualStudio.17.Release.LTSC.17.4/17.4.7+33603.86
set _catalogID=0bb9a5f5-5481-4efe-92ab-cca29a90fa5e/3e9fed4bddaae89bad22a8e05a82a3aae88183c43886f4b06d7124c582952613
set _argCatalogUrl=--catalogUrl https://download.visualstudio.microsoft.com/download/pr/%_catalogID%/VisualStudio.vsman
set _argOutputPath=--outputPath "%_installDir%"
set _argVSConfigPath=--vsConfigPath "%_configDir%\.vsconfig" 
set _argExtractionConfigurationPath=--extractionConfigurationPath "%_configDir%\extractionConfiguration.json"
set _argsT=%_argCatalogUrl% %_argOutputPath% %_argVSConfigPath% %_argExtractionConfigurationPath%
set _cmdT=CatalogExtraction.exe %_argsT%
set _logfileT=%TEMP%\catalogextractiontool.log
call :echo_action Running installation command '%_cmdT%'
rem call %_cmdT% >%_logfileT% 2>&1
call %_cmdT%
if errorlevel 1 call :set_error_info 2000 "extraction failed [%ERRORLEVEL%], see logfile '%_logfileT%' for details" & goto :fatal 
if not exist %_msbuildFullPath% call :set_error_info 2001 "extraction succeeded, but MSBuild not found" & goto :fatal
call :echo_action Adding MSBuild to front of PATH...
set PATH=%_msbuildPath%;%PATH%
call :echo_info Installation of MSBuild using %_toolID% completed successfully, details of extraction in logfile '%_logfileT%'.
goto :done

:set_error_info
set _exitCode=%1
set _fatalMsg=%~2
exit /b 0

:fatal
echo FATAL: [%_exitCode%] %_fatalMsg%
exit /b %_exitCode%

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
exit /b 0
