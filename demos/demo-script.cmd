@echo off
@rem Script/commands for vcpkg artifacts demos
call :set_common_macros
set _shellCount=5
if "%1" == "" echo no demo# specified; please provide a number between 0 and %_shellCount%
set demo0=
for /l %%n in (0,1,5) do if "%1" == "%%n" goto :setup_shell_%%n
echo invalid demo# '%1' specified; please provide a number between 0 and %_shellCount%
goto :done

@rem Demo #0 - Machine setup
@rem ----------------
:setup_shell_0
title Vcpkg artifacts demo machine prep
set _fInteractiveMode=true
call :yesorno "Do you want an interactive install (prompted for optional steps?"
if errorlevel 1 set _fInteractiveMode=false

@rem Install git [if needed]
@rem Git homepage: start https://git-scm.com/
@rem Git for Windows download: start https://git-scm.com/download/win
@rem alternate Git for Windows: start https://gitforwindows.org/

set $_demoRoot=c:\VcpkgDemos
set PROMPT=($D $T) [$+$P]$S
set _demoSetupStart=%DATE% %TIME%
echo Begin setting up demo at %_demoSetupStart%...
echo Creating demo directory %$_demoRoot%...
if exist %$_demoRoot% rd /s /q %$_demoRoot%
md %$_demoRoot%
pushd %$_demoRoot%
echo Getting demo sources...
git clone https://github.com/markle11m/vcpkg-ce-catalog.git %$_demoRoot%\msvc-experiments-demos
pushd %$_demoRoot%\msvc-experiments-demos
git checkout msvc-experiments-demos
popd
echo Resetting machine...
pushd %$_demoRoot%\msvc-experiments-demos\demos
call reset-machine.cmd
echo Getting local demo catalog...
git clone https://github.com/markle11m/vcpkg-ce-catalog.git %$_demoRoot%\catalogs\vcpkg-ce-catalog.demo
pushd %$_demoRoot%\catalogs\vcpkg-ce-catalog.demo
git checkout msvc-experiments
popd

@rem Install latest VS internal dogfood build with default Desktop C++ workload
:install_vs
set _fInstallingVS=false
if "%_fInteractiveMode%" == "false" goto :end_install_vs
call :yesorno "Install VS (latest internal dogfood build)?"
if not errorlevel 1 (
    echo - Please install the Desktop C++ workload:
    echo ^  - for the C++ toolset and MSBuild, use default options
    echo ^  - for MSBuild components only, select just 'C++ core desktop features'
    rem %_echo% start https://aka.ms/vs/17/intpreview/vs_community.exe
    pushd %TEMP%
    %_echo% curl -LO https://aka.ms/vs/17/intpreview/vs_community.exe
    if exist .\vs_community.exe start vs_community.exe
    set _fInstallingVS=true
    popd
)
:end_install_vs

@rem Install .NET SDKs
:install_dotnetsdks
set _fInstallingDotNetSDKS=false
if "%_fInteractiveMode%" == "false" goto :end_install_dotnetsdks
call :yesorno "Install .NET SDKs?"
if not errorlevel 1 (
    setlocal enabledelayedexpansion
    echo - Please install:
    echo ^  - .NET Core 6.0 and 7.0: Visual Studio 2022 SDKs for x64
    echo ^  - .NET Framework 4.7.2:  Developer Pack
    pushd %TEMP%
    rem .NET SDKs: https://dotnet.microsoft.com/en-us/download/visual-studio-sdks
    start https://dotnet.microsoft.com/en-us/download/visual-studio-sdks
    set _fInstallingDotNetSDKS=true
    popd
    endlocal
)
:end_install_dotnetsdks

@rem Install and bootstrap vcpkg
@rem To install a particular release of the vcpkg tool (by release date)
@rem curl -LO https://github.com/microsoft/vcpkg-tool/releases/download/2022-09-20/vcpkg-init.cmd
echo Installing and boostrapping vcpkg...
curl -LO https://aka.ms/vcpkg-init.cmd
call vcpkg-init.cmd
echo - adding vcpkg to PATH...
set PATH.0=%PATH%
set PATH=%PATH%;%VCPKG_ROOT%
call :show_where vcpkg
set $_vcpkgCmd="%VCPKG_ROOT%\vcpkg-init.cmd"
cd Bootstrap\Vcpkg
set _PAUSE=no
call bootstrap.cmd
set _PAUSE=

@rem If installing VS, pause here and continue when the VS install completes (to report accurate finish time).
if "%_fInstallingVS%" == "true" pause
set _demoSetupFinish=%DATE% %TIME%
echo Finished installing demo at %_demoSetupFinish%.
echo.
echo Summary:
echo - setup started:	%_demoSetupStart%
echo - setup finished:	%_demoSetupFinish%
echo.
title Vcpkg demo installation complete
goto :done

@rem Demo #1 - MSBuild ConsoleApplication (VSDevCmd)
@rem Shows msbuild integration, VS/vcpkg coexistence, switching target- and host-architectures
@rem Does not show switching MSVC versions (can show switching WinSDK versions)
:setup_shell_1
set _vsdevcmd=
for %%s in (Preview Enterprise Professional Community) do (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\%%s\Common7\Tools\VsDevCmd.bat" (
        set _vsdevcmd=C:\Program Files\Microsoft Visual Studio\2022\%%s\Common7\Tools\VsDevCmd.bat
    )
)
if "%_vsdevcmd%" == "" (
    echo *** WARNING ***
    echo Unable to find a VS installation and/or VsDevCmd.bat; this console will not work
    echo *** WARNING ***
) else (
    call "%_vsdevcmd%" -arch=x64
)
call :demo_common
pushd MSBuild\MultiLangSolution
set $_msbuildUseVcpkg=
call :msbuild_demo_common
goto :done

@rem 2. Demo #2 - MSBuild ConsoleApplication (vcpkg)
@rem Same as Demo #1, but using vcpkg artifacts
:setup_shell_2
title Demo #2 - MSBuild ConsoleApplication (vcpkg)
call :demo_common
call :setup_vcpkg
call :add_msbuild
set $_msbuildUseVcpkg=/p:EnableVcpkgArtifactsIntegration=True /p:DisableRegistryUse=True /p:CheckMSVCComponents=False
call :msbuild_demo_common
pushd MSBuild\MultiLangSolution
goto :done

@rem 3. Demo #3 - MSBuild NativeProjectsSolution (vcpkg)
@rem Similar to Demo #2, but a more complex solution
:setup_shell_3
title Demo #3 - MSBuild NativeProjectsSolution (vcpkg)
call :demo_common
call :setup_vcpkg
call :add_msbuild
set $_msbuildUseVcpkg=
set demo0=MSBuild restore
doskey d0=for %%s in ("Demo0: MSBuild restore" "msbuild /t:restore") do @echo %%~s
doskey r0=msbuild /t:restore
call :msbuild_demo_common
pushd MSBuild\NativeProjectsSolution 
goto :done

@rem 5. Demo #5 - MSBuild MultiLangSolution (vcpkg)
@rem Similar to Demo #3, but a full multi-language solution (vcpkg)
:setup_shell_5
title Demo #5 - MSBuild MultiLangSolution (vcpkg)
call :demo_common
set _CL_=
call :setup_vcpkg
call :add_msbuild
set $_msbuildUseVcpkg=/p:UseVcpkg=true /p:NoVSInstall=true
set demo0=MSBuild restore
doskey d0=for %%s in ("Demo0: MSBuild restore" "msbuild /t:restore") do @echo %%~s
doskey r0=msbuild /t:restore
call :msbuild_demo_common
pushd MSBuild\MultiLangSolution 
goto :done

@rem Demo #4 - Command Shell builds
@rem Shows activations, switching MSVC & WinSDK versions, adding features (MFC, ASAN)
@rem Available versions:
@rem - 4 MSVC toolsets (14.28.29915, 14.29.30037, 14.30.30705, 14.32.31328)
@rem - 4 WinSDKs (10.0.17763, 18362, 19041, 22621)
@rem Compilation options:
@rem - /MT=static release; /MD=dynamic release
@rem - /MTd=static debug; /MDd=dynamic debug
:setup_shell_4
title Demo #4 - Command Shell builds
:launch_appwiz
set _fLaunchAppWiz=false
if "%_fInteractiveMode%" == "false" goto :end_launch_appwiz
call :yesorno "Launch 'Programs and Features' to uninstall or modify VS?"
if not errorlevel 1 (
    set _fLaunchAppWiz=true    
    start appwiz.cpl
    pause
)
:end_launch_appwiz
call :demo_common
pushd ShellEnv\HelloWorld
call :setup_vcpkg
call :where_vcpkg_tools
echo.
for %%e in (LIB INCLUDE) do @set %%e
set _clean="del *.obj *.exe *.pdb"
doskey d1=for %%s in ("Demo1: target x86" %_clean% "vcpkg activate --target:x86" "cl.exe /EHsc /Bv /MD hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
doskey d2=for %%s in ("Demo2: target x64, x86-hosted tools" %_clean% "vcpkg activate --target:x64 --x86" "cl.exe /EHsc /Bv /MD hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
doskey d3=for %%s in ("Demo3: target x86, x64-hosted tools" %_clean% "vcpkg activate --target:x86 --x64" "cl.exe /EHsc /Bv /MTd hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
doskey d4=for %%s in ("Demo4: add ATL/MFC" "add crts/microsoft/atl to vcpkg-configuration.json" %_clean% "vcpkg activate --target:x64" "cl.exe /EHsc /Bv hello-ATL.cpp" "hello-ATL.exe" "vcpkg deactivate") do @echo %%~s
doskey d5=for %%s in ("Demo5: add ASAN" "add crts/microsoft/asan to vcpkg-configuration.json" %_clean% "vcpkg activate --target:x64 --x86" "cl.exe /EHsc /Bv /MD /Zi /fsanitize=address hello-ASAN.cpp" "hello-ASAN.exe" "vcpkg deactivate") do @echo %%~s
doskey d6=for %%s in ("Demo6: target arm64" %_clean% "vcpkg activate --target:arm64" "cl.exe /EHsc /Bv /MT hello.cpp" "vcpkg deactivate") do @echo %%~s
doskey d7=for %%s in ("Demo7: change toolset version to 14.32.31328 and rerun demo1" "update vcpkg-configuration.json" %_clean% "vcpkg activate --target:x64" "cl.exe /EHsc /Bv /MT hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
doskey d8=for %%s in ("Demo8: change Windows SDK version to 10.0.17763 and rerun demo1" "update vcpkg-configuration.json" %_clean% "vcpkg activate --target:x64" "cl.exe /EHsc /Bv /MT hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
echo.
echo Demos:
echo 1. Target x86, dynamic linkage
echo 2. Target x86, x64-hosted tools, dynamic linkage
echo 3. Target x64, x86-hosted tools
echo 4. Target x64, using ATL
echo 5. Target x86, using ASAN
echo 6. Target arm64
echo 7. Change toolset version to 14.28.29915 and repeat demo1
echo 8. Change Windows SDK version to 10.0.17763 and repeat demo1
echo.
exit /b 0

:demo_common
@rem Set compiler environment variables
@rem - /Bv = show compiler versions
@rem - /Be = show environment variables (LIB, INCLUDE) being used by the compiler
set _CL_=/nologo /Bv /Be
set PROMPT=($D $T) [$+$P]$S
set $_demoRoot=c:\VcpkgDemos
rem Remove all .vcpkg subdirectories
doskey rmdir_vcpkg=echo Removing .vcpkg directories... ^& for /F "delims=" %%d in ('dir "*vcpkg" /AD /B /S 2^^^>nul') do @if "%%~nxd" == ".vcpkg" rd /s /q "%%~d"
doskey report_demo_tools=echo Scanning msbuild.log... ^& (for /f "tokens=1*" %%i in ('findstr /i "cl.exe" msbuild.log ^^^| findstr "@"') do @for /f "tokens=1 delims=@" %%p in ('echo "%%i %%j"') do @echo %%~p) ^& for /f "tokens=1 delims=/" %%i in ('findstr /i "csc.exe vbc.exe" msbuild.log') do @for /f "tokens=1*" %%j in ('echo %%i') do @echo %%j %%k
doskey run_demo_exes=if "$*" == "" (echo Please specify prefixes of .exes to run; e.g.: Hello MFC) else (for %%p in ($*) do @for /f "" %%e in ('where /r . %%p*.exe ^^^| findstr Release ^^^| findstr /iv obj') do @%%e)
doskey show_demo_exes=for %%p in (Hello MFC) do @for /f "" %%e in ('where /r . %%p*.exe ^^^| findstr Release ^^^| findstr /iv obj') do @echo %%e
doskey show_demo_macros=echo Macros for vcpkg demos: ^& for /f "usebackq tokens=1 delims==" %%m in (`doskey /macros ^^^| findstr _ ^^^| findstr /i "demo vcpkg"`) do @echo ^  %%m
doskey show_demo_vars=echo Environment variables for vcpkg demos: ^^^& set $
doskey where_demo_tools=for %%t in (vcpkg dotnet msbuild cl csc vbc) do @for /f "tokens=1 delims=" %%p in ('where.exe %%t 2^^^>^^^&1') do @if "%%p" == "INFO: Could not find files for the given pattern(s)." (echo Where is %%t?:) else (echo Where is %%t?:  %%p)

pushd %$_demoRoot%\msvc-experiments-demos\demos
exit /b 0

:setup_vcpkg
if "%PATH.0%" == "" set PATH.0=%PATH%
if not exist .\vcpkg-init.cmd curl -LO https://aka.ms/vcpkg-init.cmd
call vcpkg-init.cmd
echo Adding vcpkg to PATH...
set PATH=%PATH%;%VCPKG_ROOT%
set $_vcpkgCmd="%VCPKG_ROOT%\vcpkg-init.cmd"
rem call :show_where vcpkg.exe
doskey reset_vcpkg_artifact_cache=echo Killing processes... ^& taskkill /IM mspdbsrv.exe /F ^& taskkill /IM msbuild.exe /F ^& taskkill /IM vbcscompiler.exe /F ^& for %%p in (.vcpkg .\Outputs %USERPROFILE%\.vcpkg\downloads\artifacts) do @if exist %%p echo Deleting %%p... ^& @rd /s /q %%p ^>nul
exit /b 0

:add_msbuild
echo Adding msbuild to PATH...
for %%s in (Preview Enterprise Professional Community) do (
    if exist "C:\Program Files\Microsoft Visual Studio\2022\%%s\MSBuild\Current\Bin\amd64" (
        set PATH=%PATH%;C:\Program Files\Microsoft Visual Studio\2022\%%s\MSBuild\Current\Bin\amd64
    )
)
exit /b 0

:msbuild_demo_common
rem call :show_where dotnet.exe
rem call :show_where msbuild.exe
call :where_vcpkg_tools
set $_msbuildCommonArgs=/m /t:rebuild
set $_msbuildArgs=%$_msbuildCommonArgs% %$_msbuildUseVcpkg%
doskey d1=for %%s in ("Demo1: MSBuild default" "msbuild %$_msbuildArgs%") do @echo %%~s
doskey d2=for %%s in ("Demo2: MSBuild release x86, default tools host-architecture" "msbuild %$_msbuildArgs% /p:Configuration=Release /p:Platform=x86") do @echo %%~s
doskey d3=for %%s in ("Demo3: MSBuild release x64, x86-hosted tools" "msbuild %$_msbuildArgs% /p:Configuration=Release /p:Platform=x64 /p:PreferredToolArchitecture=x86") do @echo %%~s
doskey r1=msbuild %$_msbuildArgs%
doskey r2=msbuild %$_msbuildArgs% /p:Configuration=Release /p:Platform=x86
doskey r3=msbuild %$_msbuildArgs% /p:Configuration=Release /p:Platform=x64 /p:PreferredToolArchitecture=x86
echo.
echo Demos:
if "%demo0%" NEQ "" echo 0. %demo0%
echo 1. MSBuild with default properties for configuration, target platform and host toolset architecture (Debug, x64, x64)
echo 2. MSBuild for x86, Release config
echo 3. MSBuild for x64, using x86-hosted tools, Release config
echo.
exit /b 0

:where_vcpkg_tools
echo. 
for %%t in (vcpkg dotnet msbuild cl csc vbc) do @for /f "tokens=1 delims=" %%p in ('where.exe %%t 2^>^&1') do @if "%%p" == "INFO: Could not find files for the given pattern(s)." (echo Where is %%t?:) else (echo Where is %%t?:  %%p)
exit /b 0

:show_where
echo Where is %~1?:
where.exe %1
exit /b 0

:yesorno
set _prompt=%~1
set /P _responseT=%~1 [y/n] 
if /I "%_responseT:~0,1%" == "y" exit /b 0
exit /b 1

:set_common_macros
doskey cd=pushd $*
exit /b 0

:done
