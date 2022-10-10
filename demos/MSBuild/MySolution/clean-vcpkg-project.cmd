@echo off
@setlocal enabledelayedexpansion
@if "%_echo%" NEQ "" echo on

for %%p in (msbuild.exe mspdbsrv.exe) do (
    echo Killing %%p processes with taskkill.exe...
    call taskkill.exe /F /IM %%p
)
echo Deleting project/solution-specific vcpkg files (.vcpkg)...
rd /s /q .vcpkg >nul 2>&1
echo Deleting user's vcpkg artifact cache (%USERPROFILE%\.vcpkg\downloads\artifacts)...
rd /s /q "%USERPROFILE%\.vcpkg\downloads\artifacts" >nul 2>&1
echo Deleting project-local output files (Outputs)...
rd /s /q Outputs >nul 2>&1

:done
echo Done.

