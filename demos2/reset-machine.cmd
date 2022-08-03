@echo off
@setlocal enabledelayedexpansion

:getargs
set _demoList=%1
if "%_demoList%" == "" (
    rem Reset all demos
    set _demoList=CommandLine-CL CommandLine-MSBuild
)

:start
set _workingDir=%CD%
set _fMachineResetDone=false
set _fSkipDemoReset=false
for %%d in (%_demoList%) do (
    set SET_DEMO_ENVIRONMENT=-quiet
    call %~dp0\set-demo-environment.cmd %%d
    if errorlevel 1 set _fSkipDemoReset=true& echo WARNING: invalid demo directory '%%d' specified; skipping per-demo reset
    set SET_DEMO_ENVIRONMENT=
    rem set _echo=echo [DEBUG] command:
    set _echo=
    if "!_fMachineResetDone!" == "false" (
        call :reset_machine
        set _fMachineResetDone=true
    )
    if "!_fSkipDemoReset!" == "false" call :reset_demo %%d
)
goto :done

:reset_machine
rem Reset per-machine and per-user files
echo Resetting per-machine and per-user files...
if exist %$_vcpkgInstallDir% (
    echo Deleting vcpkg installation '%$_vcpkgInstallDir%'...
    %_echo% rd /s /q %$_vcpkgInstallDir%
)
if exist %$_vcpkgTempDir% (
    echo Deleting vcpkg temp directory '%$_vcpkgTempDir%'...
    %_echo% rd /s /q %$_vcpkgTempDir%
)
if exist %$_vcpkgCatalogsDir% (
    echo Deleting vcpkg catalogs '%$_vcpkgCatalogsDir%'...
    %_echo% rd /s /q %$_vcpkgCatalogsDir%
)
if exist %$_corextNugetCache% (
    echo Deleting CoreXT NuGet cache '%$_corextNugetCache%'...
    %_echo% rd /s /q %$_corextNugetCache%
)
if exist %$_nugetPackageCache% (
    echo Deleting NuGet package cache '%$_nugetPackageCache%'...
    %_echo% rd /s /q %$_nugetPackageCache%
)
set _VSInstalled=false
for %%p in ("Program Files" "Program Files (x86)") do (
    if exist "%%~p\Microsoft Visual Studio" (
        set _VSInstalled=true
    )
)
for %%p in (System32 SysWow64) do (
    if exist "%WINDIR%\%%p\vcruntime140.dll" (
        set _VSInstalled=true
    )
)
set _msgEmitted=false
set _appdataRoot=%USERPROFILE%\AppData\Local
for %%s in (vcpkg npm-cache) do (
    if exist %_appdataRoot%\%%s (
        if "!_msgEmitted!" == "false" (
            echo Deleting application data...
            set _msgEmitted=true
        )
        echo Deleting %%s appdata...
        %_echo% rd /s /q %_appdataRoot%\%%s
    )
)
for %%a in (no n false) do if /I "%_pause%" == "%%a" goto :skip_interactive_reset
rem VS Install resets are interactive by default
if "%_VSInstalled%" == "true" (
    echo Visual Studio directory found:
    set /P _responseT=- launch Programs and Features to uninstall? [y/n] 
    if "!_responseT:~0,1!" == "y" (
        %_echo% start appwiz.cpl
    )
    set /P _responseT=- remove VS application data? [y/n] 
    if "!_responseT:~0,1!" == "y" (
        for %%s in ("VisualStudio" "VisualStudio Services" "VSCommon" "VSApplicationInsights") do (
            set _appdataDir="%_appdataRoot%\Microsoft\%%~s"
            if exist !%_appdataDir! (
                if "!_msgEmitted!" == "false" (
                    echo Deleting application data...
                    set _msgEmitted=true
                )
                echo Deleting %%~s appdata...
                %_echo% rd /s /q !%_appdataDir!
            )
        )
    )
)
:skip_interactive_reset
exit /b 0

:reset_demo
rem Reset per-demo files
if "%$_vcpkgDemoDir%" == "" goto :end_reset_demo
echo Resetting per-demo files under %$_vcpkgDemoDir%...
:reset_jsonfiles
set _msgEmitted=false
set _tmpfile=%TEMP%\%~n0.tmp
call where.exe /r %$_vcpkgDemoDir% vcpkg-configuration.json >%_tmpfile% 2>&1
if errorlevel 0 if not errorlevel 1 (
    for /f "tokens=1*" %%f in (%_tmpfile%) do (
        if "!_msgEmitted!" == "false" (
            set _msgEmitted=true
        )
        set _fileT=%%f
        if "%%g" NEQ "" set _fileT=!_fileT! %%g
        del "!_fileT!"
    )
)
:end_reset_jsonfiles
if exist %$_vcpkgDemoDir%\Source\HelloWorld (
    set _msgEmitted=false
    for %%i in (obj exe pdb ilk) do (
        if exist %$_vcpkgDemoDir%\Source\HelloWorld\*.%%i (
            if "%_msgEmitted%" == "false" (
                echo Deleting build output in '%$_vcpkgDemoDir%\Source\HelloWorld'...
                set _msgEmitted=true
            )
            del %$_vcpkgDemoDir%\Source\HelloWorld\*.%%i
        )
    )
)
if exist %$_vcpkgDemoDir%\Source\MySolution\.vcpkg (
    echo Deleting solution-local vcpkg directories in '%$_vcpkgDemoDir%\Source\MySolution'...
    %_echo% rd /s /q %$_vcpkgDemoDir%\Source\MySolution\.vcpkg
)
if exist %$_vcpkgDemoDir%\Source\MySolution\Outputs (
    echo Deleting solution-local output directories in '%$_vcpkgDemoDir%\Source\MySolution'...
    %_echo% rd /s /q %$_vcpkgDemoDir%\Source\MySolution\Outputs
)
for %%s in (out src) do (
    if exist %$_vcpkgDemoDir%\CoreXT-Init\%%s (
        echo Deleting CoreXT-generated directory '%%s'...
        %_echo% rd /s /q %$_vcpkgDemoDir%\CoreXT-Init\%%s
    )
)
:end_reset_demo
exit /b 0

:done
cd /d %_workingDir%
echo Done.
