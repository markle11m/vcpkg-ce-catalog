@echo off

if "%SET_DEMO_ENVIRONMENT%" NEQ "-quiet" echo Setting demo environment (variables and shortcuts)...

:set_variables
set $_vcpkgDemoRoot=%~dp0
set $_vcpkgDemoRoot=%$_vcpkgDemoRoot:~,-1%
set $_vcpkgInstallDir=%USERPROFILE%\.vcpkg
set $_vcpkgTempDir=%TEMP%\vcpkg
set $_corextNugetCache=c:\NugetCache
set $_nugetPackageCache=%USERPROFILE%\.nuget\packages

:set_shortcuts
doskey reset_machine=%$_vcpkgDemoRoot%\reset_machine.cmd
:end_set_shortcuts

:done
rem for %%e in () do set _%%e=
