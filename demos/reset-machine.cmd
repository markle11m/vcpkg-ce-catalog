@echo off
@setlocal enabledelayedexpansion

:start
set _fMachineResetDone=false
set SET_DEMO_ENVIRONMENT=-quiet
call %~dp0\set-demo-environment.cmd %%d

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

:reset_demo_files
rem Reset per-demo files
echo Resetting per-demo files under %$_vcpkgDemoRoot%...
for %%d in (.vcpkg Outputs x64 x86 x64-debug x86-debug) do (
    for /f "usebackq" %%p in (`dir /B /S /AD %%d 2^>nul`) do (
        if "%d" NEQ "File" echo Deleting %%p... & rd /s /q "%%p" >nul 2>&1
    )
)
:end_reset_demo_files
exit /b 0

:done
echo Done.
