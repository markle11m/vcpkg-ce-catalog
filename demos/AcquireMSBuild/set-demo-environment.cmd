@echo off

set _fEcho=true
if "%SET_DEMO_ENVIRONMENT%" NEQ "-quiet" set _fEcho=false
if "%_fEcho%" == "true" echo Setting demo environment (variables and shortcuts)...

:set_variables
set $_demoRoot=%~dp0
set $_demoRoot=%$_demoRoot:~,-1%
for %%i in (Source Tools Test) do set $_demo%%iRoot=%$_demoRoot%\%%i
set $_demoRepo=ConsoleApplication1

rem List of MSBuild acquisition demos (how to obtain MSBuild)
rem - VSBuildTools = VS Build Tools SKU installer
rem - CoreXT = MSBuild.CoreXT .nupkg installed via CoreXT (init.cmd)
rem - CloudBuild = CloudBuild.Tools.MSBuild .nupkg downloaded via drop.exe
rem - CatalogExtraction = VS Setup's CatalogExtraction tool
rem - vcpkg = vcpkg artifacts private registry
set $_demoList=VSBuildTools CoreXT CloudBuild CatalogExtraction vcpkg

:set_shortcuts
rem Insert doskey macro definitions here
doskey bootstrap=%$_demoRoot%\bootstrap-environment.cmd $*
doskey build=%$_demoRoot%\build-and-run.cmd $*
doskey clone_repo=echo Cloning project '%$_demoRepo%'into 'Test\$1'... ^& xcopy /sdvci %$_demoSrcRoot%\%$_demoRepo% %$_demoTestRoot%\$1 ^& pushd %$_demoTestRoot%\$1
:end_set_shortcuts

:verify_directories
if "%SET_DEMO_ENVIRONMENT_CLEAN%" == "" (
    if not exist %$_demoTestRoot% (
        if "%_fEcho%" == "true" echo Creating demo test directory root...
        md %$_demoTestRoot% >nul 2>&1
    )
)

:done
rem Clear temporary environment variables
rem for %%v in () do set _%%v=
