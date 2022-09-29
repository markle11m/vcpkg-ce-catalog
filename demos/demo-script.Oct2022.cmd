@echo off
@rem Script/commands for vcpkg artifacts demos
set _shellCount=3
if "%1" == "" echo no demo# specified; please provide a number between 0 and %_shellCount%
set demo0=
for %%n in (0 1 2 3) do if "%1" == "%%n" goto :setup_shell_%%n
echo invalid demo# '%1' specified; please provide a number between 0 and %_shellCount%
goto :done

@rem Demo #0 - Machine setup
@rem ----------------
:setup_shell_0
title Vcpkg artifacts demo machine prep
appwiz.cpl
set PAUSE=no

@rem Install git [if needed]
@rem Git homepage: start https://git-scm.com/
@rem Git for Windows download: start https://git-scm.com/download/win
@rem alternate Git for Windows: start https://gitforwindows.org/

set $_demoRoot=c:\VcpkgDemos
set PROMPT=($D $T) [$+$P]$S
echo Begin setting up demo at %DATE% %TIME%...
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
echo Getting latest VS installer (internal dogfood build); please install default Desktop C++ workload
start https://aka.ms/vs/17/intpreview/vs_community.exe

@rem Install and bootstrap vcpkg
@rem To install a particular release of the vcpkg tool (by release date)
@rem curl -LO https://github.com/microsoft/vcpkg-tool/releases/download/2022-09-20/vcpkg-init.cmd
echo Installing and boostrapping vcpkg...
curl -LO https://aka.ms/vcpkg-init.cmd
call vcpkg-init.cmd
echo - adding vcpkg to PATH...
set PATH.0=%PATH%
set PATH=%PATH%;%VCPKG_ROOT%
where.exe vcpkg
set $_vcpkgCmd="%VCPKG_ROOT%\vcpkg-init.cmd"
cd Bootstrap\Vcpkg
call bootstrap.cmd

pause
echo Finished installing demo prereqs at %DATE% %TIME%.
goto :done

@rem Demo #1 - MSBuild ConsoleApplication (VSDevCmd)
@rem Shows msbuild integration, VS/vcpkg coexistence, switching target- and host-architectures
@rem Does not show switching MSVC versions (can show switching WinSDK versions)
:setup_shell_1
set _vsdevcmd="C:\Program Files\Microsoft Visual Studio\2022\Preview\Common7\Tools\VsDevCmd.bat"
call %_vsdevcmd%
call :demo_common
pushd VSTemplate\ConsoleApplication1
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
pushd VSTemplate\ConsoleApplication1
set $_msbuildUseVcpkg=/p:EnableVcpkgArtifactsIntegration=True /p:DisableRegistryUse=True /p:CheckMSVCComponents=False
call :msbuild_demo_common
goto :done

@rem 3. Demo #3 - MSBuild NativeProjectsSolution (vcpkg)
@rem Similar to Demo #2, but a more complex solution
:setup_shell_3
title Demo #3 - MSBuild NativeProjectsSolution (vcpkg)
call :demo_common
call :setup_vcpkg
call :add_msbuild
pushd MSBuild\NativeProjectsSolution
set $_msbuildUseVcpkg=
set demo0=MSBuild restore
doskey demo0=for %%s in ("msbuild /t:restore") do @echo %%~s
call :msbuild_demo_common
goto :done

@rem Demo #4 - Command Shell builds
@rem Shows activations, switching MSVC & WinSDK versions, adding features (MFC, ASAN)
@rem Available versions:
@rem - 3 MSVC toolsets (14.28.29915, 14.29.30037, 14.32.31328) 
@rem - 4 WinSDKs (10.0.17763, 18362, 19041, 22621)
@rem Compilation options:
@rem - /MT=static release; /MD=dynamic release
@rem - /MTd=static debug; /MDd=dynamic debug
:setup_shell_4
title Demo #4 - Command Shell builds
echo Uninstall MSVC tools from VS...
appwiz.cpl
pause
call :demo_common
pushd ShellEnv\HelloWorld
call :setup_vcpkg
for %%e in (LIB INCLUDE) do @set %%e
doskey demo1=for %%s in ("Demo1: target x86" "vcpkg activate --target:x86" "cl.exe /EHsc /Bv /MD hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
doskey demo2=for %%s in ("Demo2: target x64, x86-hosted tools" "vcpkg activate --target:x64 --x86" "cl.exe /EHsc /Bv /MD hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
doskey demo3=for %%s in ("Demo3: target x86, x64-hosted tools" "vcpkg activate --target:x86 --x64" "cl.exe /EHsc /Bv /MTd hello.cpp" "hello.exe" "vcpkg deactivate") do @echo %%~s
doskey demo4=for %%s in ("Demo4: add MFC" "vcpkg activate --target:x64" "cl.exe /EHsc /Bv hello-MFC.cpp" "hello-MFC.exe" "vcpkg deactivate") do @echo %%~s
doskey demo5=for %%s in ("Demo5: add ASAN" "vcpkg activate --target:x64 --x86" "cl.exe /EHsc /Bv /MD /Zi /fsanitize=address hello-ASAN.cpp" "hello-ASAN.exe" "vcpkg deactivate") do @echo %%~s
doskey demo6=for %%s in ("Demo6: target arm64" "vcpkg activate --target:arm64" "cl.exe /EHsc /Bv /MT hello.cpp" "vcpkg deactivate") do @echo %%~s
doskey demo7=for %%s in ("Demo7: change toolset version to 14.28.19915 and rerun demo1" "vcpkg activate --target:arm64" "cl.exe /EHsc /Bv /MT hello.cpp" "vcpkg deactivate") do @echo %%~s
doskey demo8=for %%s in ("Demo8: change Windows SDK version to 10.0.17763 and rerun demo1" "vcpkg activate --target:arm64" "cl.exe /EHsc /Bv /MT hello.cpp" "vcpkg deactivate") do @echo %%~s
echo.
echo Demos:
echo 1. Target x86, dynamic linkage
echo 2. Target x86, x64-hosted tools, dynamic linkage
echo 3. Target x64, x86-hosted tools
echo 4. Target x64, using MFC
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
pushd %$_demoRoot%\msvc-experiments-demos\demos
exit /b 0

:setup_vcpkg
if "%PATH.0%" == "" set PATH.0=%PATH%
if not exist .\vcpkg-init.cmd curl -LO https://aka.ms/vcpkg-init.cmd
call vcpkg-init.cmd
echo Adding vcpkg to PATH...
set PATH=%PATH%;%VCPKG_ROOT%
set $_vcpkgCmd="%VCPKG_ROOT%\vcpkg-init.cmd"
where vcpkg.exe
doskey reset_vcpkg_artifact_cache=echo Killing processes... ^& taskkill /IM mspdbsrv.exe /F ^& taskkill /IM msbuild.exe /F ^& for %%p in (.vcpkg .\Outputs %USERPROFILE%\.vcpkg\downloads\artifacts) do @if exist %%p echo Deleting %%p... ^& @rd /s /q %%p ^>nul
exit /b 0

:add_msbuild
echo Adding msbuild to PATH...
set PATH=%PATH%;C:\Program Files\Microsoft Visual Studio\2022\Preview\MSBuild\Current\Bin\amd64
exit /b 0

:msbuild_demo_common
where msbuild.exe
set $_msbuildCommonArgs=/m /t:rebuild
set $_msbuildArgs=%$_msbuildCommonArgs% %$_msbuildUseVcpkg%
doskey demo1=for %%s in ("msbuild %$_msbuildArgs%") do @echo %%~s
doskey demo2=for %%s in ("msbuild %$_msbuildArgs% /p:Configuration=Release /p:Platform=x86") do @echo %%~s
doskey demo3=for %%s in ("msbuild %$_msbuildArgs% /p:Configuration=Release /p:Platform=x64 /p:PreferredToolArchitecture=x86") do @echo %%~s
echo.
echo Demos:
if "%demo0%" NEQ "" echo 0. %demo0%
echo 1. MSBuild with default properties for configuration, target platform and host toolset architecture (Debug, x64, x64)
echo 2. MSBuild for x86, Release config
echo 3. MSBuild for x64, using x86-hosted tools, Release config
echo.
exit /b 0

:done
