@echo off
@setlocal enabledelayedexpansion

set _scriptCopy=%TEMP%\demo.tmp.cmd
set $_rootArg=%~1
if "%$_rootArg%" == "" (set $_root=%~dp0) else (set $_root=%$_rootArg%)
if "%0" == "%_scriptCopy%" goto :start
copy /y "%0" "%_scriptCopy%" >nul 2>&1
call %_scriptCopy% %$_root%
goto :done

:start
set PROMPT=($T) [$+$P]$S

set $_isVSDevCmdPrompt=false
if defined VSINSTALLDIR if defined VSCMD_VER set $_isVSDevCmdPrompt=true
if "%$_isVSDevCmdPrompt%" == "true" (
    call :vsdevcmd_demo
    goto :done
)

where.exe /r " C:\Program Files\Microsoft Visual Studio" VSDevCmd.bat >nul 2>&1
if errorlevel 1 (
    rem VS not installed
    call :vcpkg_only_demo
) else (
    rem VS installed
    call :hybrid_vs_vcpkg_demo
)

goto :done

:vsdevcmd_demo
rem call :list_vcpkg_configs
rem call :show_props_files
call :clean_demo_workspace
call :build_solution
call :show_msbuild_logs
call :report_demo_tools
call :show_demo_exes
call :run_demo_exes "Hello MFC"
exit /b 0

:hybrid_vs_vcpkg_demo
call :clean_demo_workspace
call :build_solution "/p:UseVcpkg=true"
call :show_msbuild_logs
call :report_demo_tools
call :show_demo_exes
call :add_asan_runtime_files
call :run_demo_exes "Hello MFC"
call :list_vcpkg_configs
call :open_vcpkg_configs
call :open_msbuild_response_file
call :build_solution "/p:UseVcpkg=true /p:Platform=x86"
call :show_demo_exes
call :report_demo_tools
call :add_asan_runtime_files
call :run_demo_exes "Hello MFC"
call :update_toplevel_vcpkg_config
if errorlevel 1 (
    call :build_native_project HelloCpp-Vcpkg2-Nested "/p:UseVcpkg=true /p:Platform=x86"
    call :show_demo_exes
    call :report_demo_tools
    call :run_demo_exes "Hello"
)
call :restore_solution "/p:UseVcpkg=true"

exit /b 0

:vcpkg_only_demo
where msbuild.exe >nul 2>&1
if errorlevel 1 (
    echo MSBuild not found. Please run these commands to activate and verify the environment:
    echo.
    echo pushd Native
    echo vcpkg activate --tag:msbuild-bootstrap
    echo where_demo_tools
    echo popd
) else (
    call :clean_demo_workspace
    call :build_solution "/p:UseVcpkg=true"
    call :show_msbuild_logs
    call :report_demo_tools
    call :show_demo_exes
    call :add_asan_runtime_files
    call :run_demo_exes "Hello MFC"
)
exit /b 0

@rem 
@rem Demo functions
@rem 

:list_vcpkg_configs
call :yesorno "Show vcpkg configuration files?"
if errorlevel 1 (
    pushd %$_root%
    where /r Native vcpkg-configuration.json
    popd
)
:end_list_vcpkg_configs
exit /b 0

:open_vcpkg_configs
call :yesorno "Open vcpkg configuration files?"
if errorlevel 1 (
    pushd %$_root%
    for /f "" %%f in ('where /r Native vcpkg-configuration.json') do (
        call :yesorno_skip_line_echo "- %%f?"
        if errorlevel 1 start notepad %%f
    )
    popd
)
:end_open_vcpkg_configs
exit /b 0

:show_props_files
:end_show_props_files
exit /b 0

:clean_demo_workspace
call :yesorno "Clean demo workspace?"
if errorlevel 1 (
    pushd %$_root%\..\..
    call :run_command "git checkout -f"
    call :run_command "git clean -df"
    call :run_command "git status"
    popd
)
:end_clean_demo_workspace
exit /b 0

:restore_solution
set _msbuildArgs=%~1
call :yesorno "Restore solution?"
if errorlevel 1 (
    pushd %$_root%
    call :rmdir_vcpkg
    call :run_command "msbuild.exe /t:restore MultiLangSolution.sln %_msbuildArgs% /p:Platform=x64"
    call :run_command "msbuild.exe /t:restore MultiLangSolution.sln %_msbuildArgs% /p:Platform=x86"
    popd
)
:end_
exit /b 0

:build_solution
set _msbuildArgs=%~1
call :yesorno "Build solution?"
if errorlevel 1 (
    pushd %$_root%
    call :rmdir_vcpkg
    call :run_command "msbuild.exe /t:rebuild MultiLangSolution.sln %_msbuildArgs%"
    popd
)
:end_
exit /b 0

:build_native_project
set _projectName=%~1
set _msbuildArgs=%~2
set _exitCode=0
set _projectFile=
for /f "" %%p in ('where /r Native %_projectName%.vcxproj') do set _projectFile=%%~p
if "%_projectFile%" == "" echo *** ERROR: %_projectFile% not found & exit /b 1
call :yesorno "Build project %_projectName%?"
if errorlevel 1 (
    pushd %$_root%
    call :rmdir_vcpkg
    call :run_command "msbuild.exe /t:rebuild !_projectFile! %_msbuildArgs%"
    popd
)
:end_build_native_project
exit /b %_exitCode%

:show_msbuild_logs
call :yesorno "Show MSBuild logfiles?"
if errorlevel 1 (
    pushd %$_root%
    call :run_command "dir msbuild*"
    set _fileIsEmpty=true
    for /F %%l in (msbuild.err) do @if "%%l" NEQ "" set _fileIsEmpty=false
    if "!_fileIsEmpty!" == "false" (
        call :yesorno "Open msbuild.err?"
        if errorlevel 1 start notepad msbuild.err
    )
    popd
)
:show_msbuild_logs
:end_
exit /b 0

:report_demo_tools
call :yesorno "Show compilers used to build?"
if errorlevel 1 (
    pushd %$_root%
    echo Scanning msbuild.log... 
    for /f "tokens=1*" %%i in ('findstr /i "cl.exe" msbuild.log ^| findstr "@"') do (
        for /f "tokens=1 delims=@" %%p in ('echo "%%i %%j"') do @echo %%~p 
    )
    for /f "tokens=1 delims=/" %%i in ('findstr /i "csc.exe vbc.exe" msbuild.log') do (
        for /f "tokens=1*" %%j in ('echo %%i') do @echo %%j %%k
    )
    popd
)
:end_report_demo_tools

exit /b 0

:show_demo_exes
call :yesorno "Show demo binaries built?"
if errorlevel 1 (
    pushd %$_root%
    for %%p in (Hello MFC) do (
        for /f "" %%e in ('where /r . %%p*.exe ^| findstr Release ^| findstr /iv obj') do echo %%e
    )
    popd
)
:end_show_demo_exes
exit /b 0

:run_demo_exes
set _prefixList=%~1
if "%_prefixList%" == "" echo Please specify prefixes of .exes to run; e.g.: Hello MFC & exit /b 1
call :yesorno "Run demo binaries?"
if errorlevel 1 (
    pushd %$_root%
    for %%p in (%_prefixList%) do (
        for /f "" %%e in ('where /r . %%p*.exe ^| findstr Release ^| findstr /iv obj') do %%e
    )
    popd
)
:end_
exit /b 0

:rmdir_vcpkg
dir ".vcpkg" /AD /B /S >nul 2>&1
if not errorlevel 1 (
    call :yesorno_skip_line_echo "Remove .vcpkg directories?"
    pushd %$_root%
    for /F "delims=" %%d in ('dir "*vcpkg" /AD /B /S 2^>nul') do (
        if "%%~nxd" == ".vcpkg" (
            call :run_command " rd /s /q %%~d"
        )
    )
    popd
)
:end_rmdir_vcpkg
exit /b 0

:add_asan_runtime_files
call :yesorno "Add ASAN runtime DLLs to the environment?"
if errorlevel 1 (
    pushd %VCPKG_ROOT%
    set _redistDir=%$_demoRoot%\redist
    if not exist !_redistDir! md !_redistDir! >nul 2>&1
    set PATH=%PATH%;%!_redistDir!
    rem add clang_rt.asan*dynamic-*.dll for both x64 (x86_64) and x86 (i386)
    for %%t in (x64 x86) do (
        for /f "usebackq" %%f in (`where /r downloads\artifacts clang_rt.asan*_dynamic-*.dll ^| findstr /i asan.%%t ^| findstr /i Host%%t`) do (
	        copy /y %%f !_redistDir!\%%~nxf >nul 2>&1
        )
    )
    call :run_command "where clang*.dll"
    popd
)
:end_add_asan_runtime_files
exit /b 0

:open_msbuild_response_file
call :yesorno "Update msbuild response file (Directory.Build.rsp)?"
if errorlevel 1 (
    pushd %$_root%
    notepad Directory.Build.rsp
    popd
)
:end_open_msbuild_response_file
exit /b 0

:update_toplevel_vcpkg_config
set _exitCode=0
call :yesorno "Change top-level compiler and Windows SDK versions?"
if errorlevel 1 (
    pushd %$_root%
    call :run_command "copy VcpkgSampleFiles\vcpkg-configuration.json-uncached Native\vcpkg-configuration.json"
    set _exitCode=1
    popd
)
:end_update_toplevel_vcpkg_config
exit /b %_exitCode%

:template
call :yesorno "{action}?"
if errorlevel 1 (
    pushd %$_root%
    popd
)
:end_
exit /b 0

@rem 
@rem Helper functions
@rem 

:run_command
set _cmdT=%~1
echo Running '%_cmdT%'...
call %_cmdT%
exit /b %ERRORLEVEL%

:yesorno
echo.
call :yesorno_helper %1
exit /b %ERRORLEVEL%

:yesorno_skip_line_echo
call :yesorno_helper %1
exit /b %ERRORLEVEL%

:yesorno_helper
rem Return 1 for yes, 0 for no; default is yes
set _prompt=%~1
set _responseT=
set /P _responseT=%~1 [y/n] 
if not defined _responseT exit /b 1
if /I "%_responseT:~0,1%" == "y" exit /b 1
exit /b 0

:done
exit /b 0
